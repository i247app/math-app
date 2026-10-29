# Built-in Kotlin compatibility patches

## Flutter TTS 4.2.5

`flutter_tts` is pinned to 4.2.5. Its Android project is redirected through
the same version/hash check below. `flutter_tts/android/src`, LICENSE and
pubspec metadata are copied unchanged from the published package. The local
Gradle script removes the legacy Kotlin plugin/buildscript and explicit Kotlin
stdlib dependency, registers Kotlin sources with AGP's built-in compiler, and
keeps the upstream namespace, SDK requirements and Java/Kotlin target (11).
Dart, iOS and other platforms still use the official package.

To upgrade, review the upstream build script, replace the copied sources and
license, and update the version and LF-normalized SHA-256 in `patches.json`
together with the root dependency pin. Remove the patch when upstream supports
built-in Kotlin. Do not edit the shared Pub Cache.

## Firebase Core

The host uses Flutter 3.47+, AGP 9.1 and `android.builtInKotlin=true`.
Firebase Core 5.1.0 still contains a conditional legacy Kotlin plugin application
that Flutter's static scanner reports even when the branch does not execute.

`android/settings.gradle.kts` loads this directory's `settings.gradle` after
Flutter includes its plugins. The script checks each resolved package version
and the SHA-256 of its upstream Gradle script (normalized to LF), then redirects
only its Android project to the local copy. A dependency upgrade stops the build
until the patch is reviewed. Dart and other platforms keep resolving upstream;
the shared Pub Cache is never modified.

The Firebase Core Android runtime sources, manifest, helper scripts, Firebase
BOM properties, license and pubspec metadata are copied unchanged from 5.1.0.
The local pubspec supplies the version to Firebase's user-agent build script;
it is not a Dart dependency override. Only `android/build.gradle` is migrated:

- Remove the legacy Kotlin plugin application and empty buildscript block.
- Register Kotlin files with `android.sourceSets.main.kotlin`.
- Set `kotlin.compilerOptions.jvmTarget` to the package's Java target (17)
  using AGP's built-in Kotlin compiler.

The root `pubspec.yaml` pins `firebase_core` to exactly `5.1.0` to match
`patches.json`. `pubspec.lock` stays ignored by Git. On another machine, use
Flutter 3.47+ / Dart 3.13+, run `flutter pub get`, then build normally. The app's
Android minimum SDK (24) and iOS deployment target (15.0) meet the new packages'
requirements.

When upgrading `firebase_core`:

1. Inspect its changelog and Android Gradle script. If it no longer needs a patch,
   remove its entry from `patches.json` and the local package directory.
2. Otherwise refresh the unchanged files from the resolved package, reapply the
   Gradle migration, and update the version and normalized upstream hash. Also
   update the exact `firebase_core` version in the root `pubspec.yaml`.
3. Run `flutter pub get`, then `flutter build apk --profile --no-pub` and verify
   that the KGP warning is absent.

`android.newDsl=false` remains for legacy Android DSL compatibility; it does not
disable built-in Kotlin.

References:

- https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-plugin-authors
- https://github.com/flutter/flutter/issues/189770
