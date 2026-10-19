# Clash Command - Useful project commands

ANDROID_HOME ?= $(HOME)/android-sdk
ANDROID_SDK_ROOT ?= $(HOME)/android-sdk
PATH := $(HOME)/flutter/bin:$(ANDROID_HOME)/platform-tools:$(ANDROID_HOME)/cmdline-tools/latest/bin:$(PATH)
PORT ?= 8080
HOST ?= 0.0.0.0

.DEFAULT_GOAL := help

.PHONY: help doctor devices deps test analyze run run-chrome run-chrome-port run-linux run-web-local run-web-network run-web-ip clean build-apk-debug build-apk-release build-appbundle

help: ## Show available commands and descriptions
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_0-9-]+:.*## / {printf "\033[36m%-25s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

default: help

doctor: ## Check Flutter and Android environment
	flutter doctor

devices: ## List connected devices and emulators
	flutter devices

deps: ## Install Flutter package dependencies
	flutter pub get

test: ## Run the project's tests
	flutter test

analyze: ## Run static analysis
	flutter analyze

run: ## Run the app on the default device
	flutter run

run-chrome: ## Run the app in Chrome
	flutter run -d chrome

run-chrome-port: ## Run Chrome on a custom port, e.g. PORT=8081
	flutter run -d chrome --web-port $(PORT)

run-linux: ## Run the app on the Linux desktop target
	flutter run -d linux

run-web-local: ## Run the web app on a local custom port, e.g. PORT=8081
	flutter run -d web-server --web-port $(PORT) --web-hostname 127.0.0.1

run-web-network: ## Expose the web app on your machine IP, e.g. PORT=8080 HOST=0.0.0.0
	flutter run -d web-server --web-port $(PORT) --web-hostname $(HOST)

run-web-ip: ## Print your machine IP and run the web app on it
	@IP=$$(hostname -I | awk '{print $$1}'); echo "Open http://$$IP:$(PORT)"; flutter run -d web-server --web-port $(PORT) --web-hostname $(HOST)

clean: ## Remove build artifacts and generated files
	flutter clean

build-apk-debug: ## Build a debug APK
	flutter build apk --debug

build-apk-release: ## Build a release APK
	flutter build apk --release

build-appbundle: ## Build an Android App Bundle for Play Store upload
	flutter build appbundle --release
