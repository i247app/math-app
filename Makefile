# Makefile for Math AI App
# 
# Available commands:
#   make apk-debug          - Build debug APK
#   make apk-release        - Build release APK  
#   make release-android    - Build Android App Bundle
#   make release-ios        - Build iOS release
#   make icons              - Generate launcher icons from assets/logos/logo.png
#   make models             - Generate JSON serialization models
#   make clean              - Clean Flutter and iOS build files
#   make pub                - Upgrade and get pub dependencies
#   make project            - Full project setup (clean + pub + models + pods)

.PHONY: build project pods pub clean icons

apk-debug: project
	flutter build apk --debug

apk-release: project
	flutter build apk --release

release-android: project
	flutter build appbundle --release

release-ios:    project
	flutter build ios --release 

build: project
#	@echo "prep release quickfix..."
#	flutter build ios --config-only --release
#	@echo "prep release quickfix done"

project: clean pub models pods

pods:
	cd ios && pod update

models:
	dart run build_runner build --delete-conflicting-outputs

icons:
	dart run flutter_launcher_icons
	@echo "Launcher icons generated successfully!"

pub:
	flutter pub upgrade
	flutter pub get

clean:
	flutter clean
	@echo "cleaning g.dart files..."
	find . -name "*.g.dart" -type f -print0 | xargs -0 rm -v
	@echo "cleaning g.dart done"
	@echo "cleaning ios files..."
	rm -rf ios/Podfile.lock ios/Pods ios/.symlinks ios/Flutter/Flutter.framework
	@echo "cleaning ios done"

build-release-android:
	flutter build appbundle --release
	open build/app/outputs/bundle/release/

# Icon Generation:
# Run 'make icons' to generate launcher icons for Android, iOS, and Web
# This uses the logo from assets/logos/logo.png as configured in pubspec.yaml

# generate-upload-keystore:
#	keytool -genkey -v -keystore /tmp/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
