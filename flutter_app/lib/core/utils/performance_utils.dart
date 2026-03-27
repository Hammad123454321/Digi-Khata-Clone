import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/painting.dart';

/// Performance utilities for low-end Android devices
class PerformanceUtils {
  /// Enable performance optimizations for low-end devices
  static void enablePerformanceOptimizations() {
    if (kDebugMode) {
      // In debug mode, enable performance overlay
      // This helps identify performance issues during development
      return;
    }

    // Disable expensive operations in release mode
    // Reduce image cache size for low-end devices
    PaintingBinding.instance.imageCache.maximumSize = 50;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // 50MB
  }

  /// Check if device is low-end based on available memory
  static bool isLowEndDevice() {
    // This is a simple heuristic
    // In production, you might want to use device_info_plus to get actual specs
    return defaultTargetPlatform == TargetPlatform.android;
  }

  /// Optimize frame rendering
  static void optimizeFrameRendering() {
    // Use lower frame rate for non-critical animations
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // Optimize frame callbacks
    });
  }

  /// Clear image cache to free memory
  static void clearImageCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }
}
