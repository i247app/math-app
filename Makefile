.PHONY: build project pods pub clean

run:
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

project: clean pub models pods

pods:
	cd ios && pod install

models:
	dart run build_runner build

pub:
	flutter pub upgrade
	flutter pub get

clean:
	flutter clean
	@echo "cleaning g.dart files..."
	find . -name "*.g.dart" -type f -print0 | xargs -0 rm -fv
	@echo "cleaning dart_tool files..."
	rm -rf .dart_tool/
	@echo "cleaning lock files..."
	rm -fv pubspec.lock
	rm -rf ios/Podfile.lock
	rm -rf macos/Podfile.lock
	@echo "cleaning ios files..."
	rm -rf ios/Pods ios/.symlinks ios/Flutter/Flutter.framework
	@echo "cleaning ios done"

build-release-android:
	flutter build appbundle --release $(DART_DEFINE)
	open build/app/outputs/bundle/release/

# generate-upload-keystore:
#	keytool -genkey -v -keystore /tmp/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
