# Android Photo Picker Migration Guide

This guide explains the changes made to comply with Google Play's Photo and Video Permissions policy.

## Overview

To comply with [Google Play's Photo and Video Permissions policy](https://support.google.com/googleplay/android-developer/answer/14115180), we have migrated the image and video attachment functionality to use Android's built-in photo picker instead of requesting broad media access permissions.

## Changes Made

### 1. StreamAttachmentHandler Modifications

Modified `packages/stream_chat_flutter/lib/src/attachment/handler/stream_attachment_handler_io.dart`:

- Added Android platform detection
- Implemented conditional logic to use Android photo picker for gallery access
- Added fallback to regular image picker for camera and non-Android platforms
- Added method channel communication for Android photo picker

### 2. Android Native Implementation

Modified `packages/stream_chat_flutter/example/android/app/src/main/kotlin/com/example/example/MainActivity.kt`:

- Implemented `ActivityResultContracts.PickVisualMedia` for image and video selection
- Added method channel handler for Flutter communication
- Separate launchers for image and video picking

### 3. Android Manifest Changes

Modified `packages/stream_chat_flutter/example/android/app/src/main/AndroidManifest.xml`:

- Removed `READ_MEDIA_IMAGES` and `READ_MEDIA_VIDEO` permissions
- Added service declaration for Google Play Services photo picker module
- Added tools namespace for lint ignoring

### 4. Build Configuration

Modified `packages/stream_chat_flutter/example/android/app/build.gradle`:

- Added `androidx.activity:activity-ktx:1.8.0` dependency for photo picker support

## How It Works

1. **Platform Detection**: When `pickImage()` or `pickVideo()` is called with `ImageSource.gallery` on Android, the app uses the Android photo picker
2. **Native Photo Picker**: Uses `ActivityResultContracts.PickVisualMedia` which provides access to selected media without requiring broad permissions
3. **Fallback Support**: Falls back to regular image picker if photo picker fails or on non-Android platforms
4. **Camera Support**: Camera functionality continues to use the regular image picker

## Benefits

- ✅ Complies with Google Play's Photo and Video Permissions policy
- ✅ Enhanced user privacy (no broad media access required)
- ✅ Better user experience with system photo picker
- ✅ Backward compatibility with fallback mechanism
- ✅ Works on Android 4.4+ (with Google Play Services backport)

## Testing

1. Build and run the example app on an Android device
2. Navigate to attachment picker
3. Select "Photos" or "Videos" option
4. Verify that the system photo picker opens instead of requesting broad media permissions
5. Select media files and confirm they are properly attached

## Migration for Other Apps

To apply these changes to your own Stream Chat Flutter app:

1. Copy the MainActivity.kt implementation to your Android app
2. Update your AndroidManifest.xml with the service declaration
3. Remove READ_MEDIA_IMAGES and READ_MEDIA_VIDEO permissions
4. Add the androidx.activity:activity-ktx dependency
5. The Flutter side changes are automatically included with the library update

## Compatibility

- **Android 13+**: Native photo picker
- **Android 4.4-12**: Google Play Services backported photo picker
- **iOS/Web/Desktop**: Uses existing image picker implementation
- **Camera**: Uses existing image picker for all platforms
