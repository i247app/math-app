import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
// Google Fonts exposes this manifest override for testing font loading.
// ignore: implementation_imports
import 'package:google_fonts/src/google_fonts_base.dart' as font_loading;

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final configFile = File('.dart_tool/package_config.json');
  final config =
      jsonDecode(await configFile.readAsString()) as Map<String, dynamic>;
  final flutterPackage = (config['packages'] as List)
      .cast<Map<String, dynamic>>()
      .firstWhere((package) => package['name'] == 'flutter');
  final flutterRoot = Directory.fromUri(
    configFile.uri.resolve(flutterPackage['rootUri'] as String),
  ).parent.parent;
  // Use SDK Roboto as a deterministic stand-in for network-free widget tests.
  // App builds still download the actual Andika, Nunito and Bagel Fat One fonts.
  final sdkFont =
      Directory(
        '${flutterRoot.path}/bin/cache/artifacts/material_fonts',
      ).listSync().whereType<File>().firstWhere(
        (file) =>
            file.uri.pathSegments.last.toLowerCase() == 'roboto-regular.ttf',
      );
  final bytes = await sdkFont.readAsBytes();
  final testFont = ByteData.sublistView(bytes);
  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
  font_loading.assetManifest = _TestFontManifest(manifest);
  GoogleFonts.config.allowRuntimeFetching = false;

  void installTestAssets() {
    binding.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', (
      message,
    ) async {
      final key = utf8.decode(
        message!.buffer.asUint8List(
          message.offsetInBytes,
          message.lengthInBytes,
        ),
      );
      if (key.startsWith('_widget_test_fonts/')) return testFont;
      // Complete asset reads synchronously inside the widget-test fake clock.
      final assetFile = File('build/unit_test_assets/$key');
      if (assetFile.existsSync()) {
        return ByteData.sublistView(assetFile.readAsBytesSync());
      }
      return binding.defaultBinaryMessenger.delegate.send(
        'flutter/assets',
        message,
      );
    });
  }

  installTestAssets();
  setUp(installTestAssets);
  await testMain();
}

class _TestFontManifest implements AssetManifest {
  _TestFontManifest(this.original);

  final AssetManifest original;

  @override
  List<String> listAssets() => [
    ...original.listAssets(),
    for (final family in ['Andika', 'Nunito', 'BagelFatOne'])
      for (final variant in [
        'Regular',
        'Italic',
        'Thin',
        'ThinItalic',
        'ExtraLight',
        'ExtraLightItalic',
        'Light',
        'LightItalic',
        'Medium',
        'MediumItalic',
        'SemiBold',
        'SemiBoldItalic',
        'Bold',
        'BoldItalic',
        'ExtraBold',
        'ExtraBoldItalic',
        'Black',
        'BlackItalic',
      ])
        '_widget_test_fonts/$family-$variant.ttf',
  ];

  @override
  List<AssetMetadata>? getAssetVariants(String key) =>
      original.getAssetVariants(key);
}
