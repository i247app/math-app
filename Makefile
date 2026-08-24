.DEFAULT_GOAL := run

ifeq ($(OS),Windows_NT)
HOST_OS := windows
else
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
HOST_OS := macos
else ifeq ($(UNAME_S),Linux)
HOST_OS := linux
else
HOST_OS := unknown
endif
endif

PROJECT_DEPENDENCIES := clean pub models
ifeq ($(HOST_OS),macos)
PROJECT_DEPENDENCIES += pods
endif

.PHONY: run apk-debug apk-release release-android release-ios build project \
	pods models pub clean build-release-android host-os

host-os:
	@echo "Detected operating system: $(HOST_OS)"

run:
	@echo "Running Flutter on $(HOST_OS)..."
	flutter run

apk-debug: project
	flutter build apk --debug

apk-release: project
	flutter build apk --release

release-android: project
	flutter build appbundle --release

release-ios: project
	flutter build ios --release

build: project

project: $(PROJECT_DEPENDENCIES)

pods:

ifeq ($(HOST_OS),macos)
	cd ios && pod install
else
	@echo "Skipping CocoaPods: pod install is only required on macOS."
endif

models:
	dart run build_runner build

pub:
	flutter pub upgrade
	flutter pub get

clean:
	flutter clean
	@echo "cleaning g.dart files..."

ifeq ($(HOST_OS),windows)
	powershell.exe -NoProfile -Command "Get-ChildItem -Path . -Recurse -File -Filter '*.g.dart' | Remove-Item -Force -Verbose"
	@echo "cleaning dart_tool files..."
	powershell.exe -NoProfile -Command "if (Test-Path -LiteralPath '.dart_tool') { Remove-Item -LiteralPath '.dart_tool' -Recurse -Force }"
	@echo "cleaning lock files..."
	powershell.exe -NoProfile -Command "@('pubspec.lock', 'ios/Podfile.lock', 'macos/Podfile.lock') | Where-Object { Test-Path -LiteralPath $$_ } | ForEach-Object { Remove-Item -LiteralPath $$_ -Force }"
	@echo "cleaning ios files..."
	powershell.exe -NoProfile -Command "@('ios/Pods', 'ios/.symlinks', 'ios/Flutter/Flutter.framework') | Where-Object { Test-Path -LiteralPath $$_ } | ForEach-Object { Remove-Item -LiteralPath $$_ -Recurse -Force }"
else
	find . -name "*.g.dart" -type f -print0 | xargs -0 rm -fv
	@echo "cleaning dart_tool files..."
	rm -rf .dart_tool/
	@echo "cleaning lock files..."
	rm -fv pubspec.lock
	rm -rf ios/Podfile.lock
	rm -rf macos/Podfile.lock
	@echo "cleaning ios files..."
	rm -rf ios/Pods ios/.symlinks ios/Flutter/Flutter.framework
endif
	@echo "cleaning ios done"

build-release-android:
	flutter build appbundle --release $(DART_DEFINE)

ifeq ($(HOST_OS),windows)
	explorer.exe build\app\outputs\bundle\release
else ifeq ($(HOST_OS),macos)
	open build/app/outputs/bundle/release/
else
	xdg-open build/app/outputs/bundle/release/
endif

# generate-upload-keystore:
#	keytool -genkey -v -keystore /tmp/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
