import 'dart:convert';
import 'dart:io' as io;
import 'dart:ui' as ui;

import 'package:file/file.dart' as fs;
import 'package:file/local.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:numi/features/exam/data/exam_image_cache.dart';

const _base =
    'https://example.s3.us-west-2.amazonaws.com/question-images/picture.png';
String _signed(String signature, {String extra = ''}) =>
    '$_base?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=test'
    '&X-Amz-Date=$signature&X-Amz-Expires=3600&X-Amz-SignedHeaders=host'
    '&X-Amz-Signature=$signature&x-id=GetObject$extra';

void main() {
  for (final exitWhileLoading in [false, true]) {
    testWidgets(
      'set assets stay pinned and clear after exit (loading: $exitWhileLoading)',
      (tester) async {
        final previousManager = ExamImageCache.managerOverride;
        final manager = _RecordingManager();
        final imageSource = _ControlledProvider();
        ExamImageCache.managerOverride = manager;
        ExamImageCache.providerOverride = (_, dimension) => imageSource;
        final firstUrl = _signed('pin-first');
        final nextUrl = _signed('pin-next');
        late BuildContext context;
        await tester.pumpWidget(
          Builder(
            builder: (value) {
              context = value;
              return const SizedBox();
            },
          ),
        );
        final recorder = ui.PictureRecorder();
        ui.Canvas(recorder)
            .drawColor(const Color(0xFF00AA88), ui.BlendMode.src);
        final picture = recorder.endRecording();
        final image = picture.toImageSync(1, 1);
        picture.dispose();
        addTearDown(() async {
          await ExamImageCache.release(firstUrl);
          await ExamImageCache.release(nextUrl);
          ExamImageCache.providerOverride = null;
          ExamImageCache.managerOverride = previousManager;
          image.dispose();
        });
        ExamImageCache.retain(firstUrl, 512);
        final loading = ExamImageCache.prepare(firstUrl, context);
        await tester.pump();
        expect(imageSource.completer.pinned, isTrue);
        Future<void>? clearing;
        if (exitWhileLoading) {
          clearing = ExamImageCache.release(firstUrl);
          await tester.pump();
          expect(manager.removed, isEmpty);
        }
        imageSource.completer.emit(image);
        await tester.pump();
        await loading;
        if (!exitWhileLoading) {
          expect(ExamImageCache.isReady(firstUrl), isTrue);
          ExamImageCache.retain(nextUrl, 512);
          await ExamImageCache.release(firstUrl);
          expect(imageSource.completer.pinned, isTrue);
          expect(manager.removed, isEmpty);
          clearing = ExamImageCache.release(nextUrl);
        }
        await clearing;
        expect(imageSource.completer.pinned, isFalse);
        expect(manager.removed, [ExamImageCache.keyFor(firstUrl)]);
        expect(ExamImageCache.isReady(firstUrl), isFalse);
      },
    );
  }

  test(
    'renewed S3 signatures share the disk and decoded image cache key',
    () async {
      final first = _signed('first');
      final resumed = _signed('resumed');
      expect(ExamImageCache.keyFor(first), _base);
      expect(ExamImageCache.keyFor(resumed), _base);
      expect(
        await ExamImageCache.provider(first)
            .obtainKey(ImageConfiguration.empty),
        await ExamImageCache.provider(resumed)
            .obtainKey(ImageConfiguration.empty),
      );
      expect(
        ((ExamImageCache.provider(first) as ResizeImage).imageProvider
                as CachedNetworkImageProvider)
            .url,
        first,
      );
      expect(
        ((ExamImageCache.provider(resumed) as ResizeImage).imageProvider
                as CachedNetworkImageProvider)
            .url,
        resumed,
      );
    },
  );

  test('object versions, paths, hosts and unrelated query parameters stay distinct', () {
    expect(
      ExamImageCache.keyFor(_signed('one', extra: '&versionId=1')),
      isNot(ExamImageCache.keyFor(_signed('two', extra: '&versionId=2'))),
    );
    expect(
      ExamImageCache.keyFor(
        _signed('one').replaceFirst('picture.png', 'other.png'),
      ),
      isNot(ExamImageCache.keyFor(_signed('two'))),
    );
    expect(
      ExamImageCache.keyFor(
        _signed('one').replaceFirst('example.s3', 'another.s3'),
      ),
      isNot(ExamImageCache.keyFor(_signed('two'))),
    );
    const external =
        'https://example.test/image.png?X-Amz-Signature=token&width=100';
    expect(ExamImageCache.keyFor(external), external);
  });

  test(
    'last set owner removes the file and resume downloads it again',
    () async {
      final directory = await io.Directory.systemTemp.createTemp(
        'exam-image-cache-test-',
      );
      final service = _FileService();
      CacheManager createManager() => CacheManager(
        Config(
          'exam-image-test',
          repo: JsonCacheInfoRepository(path: '${directory.path}/cache.json'),
          fileSystem: _FileSystem(directory.path),
          fileService: service,
        ),
      );
      final first = createManager();
      final previousManager = ExamImageCache.managerOverride;
      ExamImageCache.managerOverride = first;
      try {
        ExamImageCache.retain(_signed('first'), 512);
        final file = await first.getSingleFile(
          _signed('first'),
          key: ExamImageCache.keyFor(_signed('first')),
        );
        expect(await file.readAsBytes(), _FileService.bytes);
        expect(service.requests, 1);
        ExamImageCache.retain(_signed('shared'), 512);
        await ExamImageCache.release(_signed('first'));
        expect(await first.getFileFromCache(_base), isNotNull);
        await ExamImageCache.release(_signed('shared'));
        expect(await first.getFileFromCache(_base), isNull);
      } finally {
        ExamImageCache.managerOverride = previousManager;
        await first.dispose();
      }
      final resumed = createManager();
      try {
        final file = await resumed.getSingleFile(
          _signed('resumed'),
          key: ExamImageCache.keyFor(_signed('resumed')),
        );
        expect(await file.readAsBytes(), _FileService.bytes);
        expect(
          service.requests,
          2,
          reason: 'exiting clears the set; resume prepares its images again',
        );
      } finally {
        await resumed.dispose();
        await directory.delete(recursive: true);
      }
    },
  );
}

class _RecordingManager implements BaseCacheManager {
  final removed = <String>[];
  @override
  Future<void> removeFile(String key) async {
    removed.add(key);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ControlledCompleter extends ImageStreamCompleter {
  bool get pinned => hasListeners;
  void emit(ui.Image image) => setImage(ImageInfo(image: image.clone()));
}

class _ControlledProvider extends ImageProvider<_ControlledProvider> {
  final completer = _ControlledCompleter();
  @override
  Future<_ControlledProvider> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);
  @override
  ImageStreamCompleter loadImage(
    _ControlledProvider key,
    ImageDecoderCallback decode,
  ) => completer;
}

class _FileSystem implements FileSystem {
  _FileSystem(this.path);
  final String path;
  @override
  Future<fs.File> createFile(String name) async =>
      const LocalFileSystem().file('$path/$name');
}

class _FileService extends FileService {
  static final bytes = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4z8DwHwAFgAI/ScLbtAAAAABJRU5ErkJggg==',
  );
  int requests = 0;
  @override
  Future<FileServiceResponse> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    requests++;
    return _Response();
  }
}

class _Response implements FileServiceResponse {
  @override
  Stream<List<int>> get content => Stream.value(_FileService.bytes);
  @override
  int get contentLength => _FileService.bytes.length;
  @override
  int get statusCode => 200;
  @override
  String? get eTag => 'picture-v1';
  @override
  String get fileExtension => '.png';
  @override
  DateTime get validTill => DateTime.now().add(const Duration(days: 7));
}
