import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/network/api_metadata.dart';
import 'package:numi/core/network/auth_token_store.dart';
import 'package:numi/core/network/network_client.dart';
import 'package:numi/core/utils/avatar/avatar_upload.dart';
import 'package:numi/features/auth/data/auth_api.dart';
import 'package:numi/features/classroom/data/classroom_api.dart';
import 'package:numi/features/profile/data/profile_api.dart';

// 3x2 JPEG with orientation=6 and synthetic GPS EXIF (not a real photo).
const _gpsJpeg =
    '/9j/4AAQSkZJRgABAQAAAQABAAD/4QC4RXhpZgAATU0AKgAAAAgAAwEOAAIAAAAYAAAAMgESAAMAAAABAAYAAIglAAQAAAABAAAASgAAAABHUFNfUFJJVkFURV9URVNUX01BUktFUgAABAABAAIAAAACTgAAAAACAAUAAAADAAAAgAADAAIAAAACRQAAAAAEAAUAAAADAAAAmAAAAAAAAAAKAAAAAQAAABQAAAABAAAAHgAAAAEAAABqAAAAAQAAACgAAAABAAAAMgAAAAH/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAACAAMDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwDi6KKK+ZP3E//Z';

class _TokenStore implements AuthTokenStore {
  @override
  Future<String?> readToken() async => null;
  @override
  Future<void> writeToken(String value) async {}
  @override
  Future<void> clearToken() async {}
}

class _Metadata implements ApiMetadataProvider {
  @override
  Future<Map<String, Object>> buildMetadata() async => {};
}

Future<Uint8List> _bytes(MultipartFile file) async => Uint8List.fromList(
  await file.finalize().fold<List<int>>([], (a, b) => a..addAll(b)),
);

List<String> _pngChunks(Uint8List bytes) {
  final result = <String>[];
  final data = ByteData.sublistView(bytes);
  for (var i = 8; i < bytes.length;) {
    result.add(ascii.decode(bytes.sublist(i + 4, i + 8)));
    i += data.getUint32(i) + 12;
  }
  return result;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory temp;
  late File source;
  setUp(() async {
    temp = await Directory.systemTemp.createTemp('avatar-privacy-');
    source = await File(
      '${temp.path}/private-location.jpg',
    ).writeAsBytes(base64Decode(_gpsJpeg));
  });
  tearDown(() async => temp.delete(recursive: true));

  test(
    'removes GPS/EXIF and original filename, preserves image orientation',
    () async {
      final upload = await sanitizedAvatarUpload(source.path);
      expect(upload.filename, 'avatar.png');
      expect(upload.contentType.toString(), 'image/png');
      final bytes = await _bytes(upload);
      expect(bytes.take(8), [137, 80, 78, 71, 13, 10, 26, 10]);
      expect(
        _pngChunks(bytes),
        isNot(contains(anyOf('eXIf', 'tEXt', 'iTXt', 'zTXt'))),
      );
      expect(latin1.decode(bytes), isNot(contains('GPS_PRIVATE_TEST_MARKER')));
      final codec = await ui.instantiateImageCodec(bytes);
      final image = (await codec.getNextFrame()).image;
      expect([image.width, image.height], [2, 3]);
      image.dispose();
      codec.dispose();
      expect(await source.readAsBytes(), base64Decode(_gpsJpeg));
    },
  );

  test('PNG keeps alpha and only re-encodes pixels', () async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawRect(
      const ui.Rect.fromLTWH(0, 0, 1, 1),
      ui.Paint()..color = const ui.Color(0x80ff0000),
    );
    final picture = recorder.endRecording();
    final image = await picture.toImage(2, 2);
    final png = (await image.toByteData(format: ui.ImageByteFormat.png))!;
    await source.writeAsBytes(png.buffer.asUint8List());
    final bytes = await _bytes(await sanitizedAvatarUpload(source.path));
    final codec = await ui.instantiateImageCodec(bytes);
    final decoded = (await codec.getNextFrame()).image;
    final pixels = (await decoded.toByteData())!;
    expect(pixels.getUint8(3), closeTo(128, 1));
    expect(pixels.getUint8(15), 0);
    decoded.dispose();
    codec.dispose();
    image.dispose();
    picture.dispose();
  });

  test(
    'account, profile and classroom uploads sanitize; bad images never reach HTTP',
    () async {
      final uploads = <MultipartFile>[];
      final paths = <String>[];
      final dio = Dio();
      final client = NetworkClient(
        baseUrl: 'https://example.test',
        dio: dio,
        authTokenStore: _TokenStore(),
        guestTokenStore: _TokenStore(),
        metadataProvider: _Metadata(),
      );
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            paths.add(options.path);
            uploads.add((options.data as FormData).files.single.value);
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'mstatus': 200},
              ),
            );
          },
        ),
      );
      final auth = AuthApi(networkClient: client);
      final profiles = ProfileApi(networkClient: client);
      await auth.updateUser(userId: 1, name: 'Test', avatarPath: source.path);
      await profiles.createProfile(
        userId: 1,
        schoolId: 1,
        name: 'Test',
        avatarPath: source.path,
      );
      await profiles.updateProfile(profileId: 1, avatarPath: source.path);
      await ClassroomApi(networkClient: client).createClassroom(
        profileId: 1,
        name: 'Test',
        programIds: [1],
        gradeId: 1,
        schoolId: 1,
        filePath: source.path,
      );
      expect(paths, [
        '/users/update',
        '/profiles/create',
        '/profiles/update',
        '/classrooms/create',
      ]);
      for (final file in uploads) {
        expect(file.filename, 'avatar.png');
        expect(_pngChunks(await _bytes(file)), isNot(contains('eXIf')));
      }
      await source.writeAsString('not an image, GPS_PRIVATE_TEST_MARKER');
      await expectLater(
        auth.updateUser(userId: 1, name: 'Test', avatarPath: source.path),
        throwsA(anything),
      );
      expect(paths.length, 4);
    },
  );
}
