.PHONY: help setup env pub-get run analyze format generate models create-model test clean doctor create-platforms

help:
	@echo "NUMI Flutter app commands"
	@echo ""
	@echo "Setup:"
	@echo "  make setup             Create .env, install packages, generate models"
	@echo "  make env               Copy env.example to .env if .env is missing"
	@echo "  make pub-get           Run flutter pub get"
	@echo "  make generate          Run build_runner for generated Dart models"
	@echo "  make models            Alias for make generate"
	@echo "  make create-model      Alias for make generate"
	@echo ""
	@echo "Development:"
	@echo "  make run               Run the app"
	@echo "  make analyze           Run flutter analyze"
	@echo "  make format            Format lib and test"
	@echo "  make test              Run flutter test"
	@echo "  make clean             Run flutter clean"
	@echo "  make doctor            Run flutter doctor"
	@echo "  make create-platforms  Regenerate iOS/Android platform folders"

setup: env pub-get generate

env:
	@if [ ! -f .env ]; then cp env.example .env && echo "Created .env from env.example"; else echo ".env already exists"; fi

pub-get:
	flutter pub get

run:
	flutter run

analyze:
	flutter analyze

format:
	dart format lib test

generate:
	dart run build_runner build --delete-conflicting-outputs

test:
	flutter test

clean:
	flutter clean

doctor:
	flutter doctor

create-platforms:
	flutter create --platforms=ios,android .
