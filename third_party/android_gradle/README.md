# Android built-in Kotlin compatibility

`flutter_tts` is pinned to 4.2.5. After Flutter includes its plugins,
`android/settings.gradle.kts` loads `settings.gradle` from this directory. It
checks the resolved TTS version and LF-normalized SHA-256 of the upstream
Gradle script against `patches.json`, then redirects the Android project to
this local copy. Dart and other platforms still use the official package.

The vendored Android sources, license and pubspec metadata are copied from the
published package. The local Gradle script removes the legacy Kotlin plugin
and explicit Kotlin stdlib dependency, registers Kotlin sources with AGP's
built-in compiler, and keeps the upstream namespace, SDK requirements and
Java/Kotlin target (11).

When upgrading `flutter_tts`, review the upstream Android build script. If it
supports built-in Kotlin, remove the patch. Otherwise refresh the copied files,
reapply the Gradle migration, and update `patches.json` and both pubspec pins
together. Run `flutter pub get` and `flutter build apk --profile --no-pub` to
verify the Android build. Do not edit the shared Pub Cache.

Firebase Core uses the upstream Android project as of 5.2.0, which supports
built-in Kotlin. `android.newDsl=false` keeps the legacy Android DSL available
while built-in Kotlin is enabled.

[Flutter migration guide](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-plugin-authors)
