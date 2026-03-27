#!/bin/bash

# Set Java environment
export JAVA_HOME=/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home
export PATH="$JAVA_HOME/bin:$PATH"

# Set Android environment
export ANDROID_HOME=/Users/sino/Library/Android/sdk
export ANDROID_SDK_ROOT=$ANDROID_HOME

# Gradle options
export GRADLE_OPTS="-Dorg.gradle.java.home=$JAVA_HOME"

# Clear Gradle cache
cd android
./gradlew clean
cd ..

echo "Environment setup complete!"
echo "JAVA_HOME: $JAVA_HOME"
echo "Java version:"
java -version

echo ""
echo "Building APK..."
flutter build apk --release

echo ""
echo "Build completed!"
echo "APK location: build/app/outputs/flutter-apk/app-release.apk"
