#!/bin/bash

# Set Java environment
export JAVA_HOME=/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home
export PATH="$JAVA_HOME/bin:$PATH"

# Set Android environment
export ANDROID_HOME=/Users/sino/Library/Android/sdk
export ANDROID_SDK_ROOT=$ANDROID_HOME

# Gradle options
export GRADLE_OPTS="-Dorg.gradle.java.home=$JAVA_HOME"

# Disable NDK
export GRADLE_USER_HOME=/Users/sino/.gradle

echo "Environment setup complete!"
echo "JAVA_HOME: $JAVA_HOME"
echo "Java version:"
java -version

echo ""
echo "Cleaning and building APK..."
cd android
./gradlew clean
cd ..

echo ""
echo "Building APK without NDK..."
flutter build apk --release --no-shrink

echo ""
echo "Build completed!"
echo "APK location: build/app/outputs/flutter-apk/app-release.apk"
