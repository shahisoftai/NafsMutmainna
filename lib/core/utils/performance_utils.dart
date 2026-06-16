import 'dart:async';

import 'package:flutter/widgets.dart';

/// Performance optimization utilities
class PerformanceUtils {
  /// Debounce function calls to reduce frequent updates
  static Debouncer debounce({Duration delay = const Duration(milliseconds: 300)}) {
    return Debouncer(delay: delay);
  }

  /// Throttle function calls to limit frequency
  static Throttler throttle({Duration delay = const Duration(milliseconds: 300)}) {
    return Throttler(delay: delay);
  }

  /// Memoize expensive computations
  static Memoizer memoize<T>(T Function() compute) {
    return Memoizer(compute);
  }
}

/// Debouncer for reducing rapid function calls
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    cancel();
  }
}

/// Throttler for limiting function call frequency
class Throttler {
  final Duration delay;
  DateTime? _lastRun;

  Throttler({required this.delay});

  void run(void Function() action) {
    final now = DateTime.now();
    if (_lastRun == null || now.difference(_lastRun!) >= delay) {
      _lastRun = now;
      action();
    }
  }

  void reset() {
    _lastRun = null;
  }
}

/// Memoizer for caching expensive computations
class Memoizer<T> {
  final T Function() _compute;
  T? _cachedValue;
  bool _hasComputed = false;

  Memoizer(this._compute);

  T get value {
    if (!_hasComputed) {
      _cachedValue = _compute();
      _hasComputed = true;
    }
    return _cachedValue as T;
  }

  void invalidate() {
    _hasComputed = false;
    _cachedValue = null;
  }
}

/// Lazy loading utility for deferring expensive initialization
class LazyLoader<T> {
  final T Function() _factory;
  T? _value;
  bool _initialized = false;

  LazyLoader(this._factory);

  T get value {
    if (!_initialized) {
      _value = _factory();
      _initialized = true;
    }
    return _value as T;
  }

  bool get isInitialized => _initialized;
}

/// Image optimization helpers
class ImageOptimizationUtils {
  /// Calculate optimal image dimensions maintaining aspect ratio
  static Size calculateOptimalSize(
    Size originalSize, {
    double maxWidth = 1920,
    double maxHeight = 1080,
  }) {
    if (originalSize.width <= maxWidth && originalSize.height <= maxHeight) {
      return originalSize;
    }

    final widthRatio = maxWidth / originalSize.width;
    final heightRatio = maxHeight / originalSize.height;
    final ratio = widthRatio < heightRatio ? widthRatio : heightRatio;

    return Size(
      originalSize.width * ratio,
      originalSize.height * ratio,
    );
  }

  /// Estimate memory usage for an image
  static int estimateMemorySize(int width, int height, {int bytesPerPixel = 4}) {
    return width * height * bytesPerPixel;
  }
}

/// Widget rendering optimization
class WidgetOptimizationUtils {
  /// Check if widget should be repainted based on conditions
  static bool shouldRepaint({
    required Object? oldWidget,
    required Object? newWidget,
    bool forceRepaint = false,
  }) {
    if (forceRepaint) return true;
    return oldWidget != newWidget;
  }

  /// Create a repaint boundary when conditions are met
  static Widget wrapWithRepaintBoundary(Widget child, {bool shouldWrap = false}) {
    if (!shouldWrap) return child;
    return RepaintBoundary(child: child);
  }
}

/// List view optimization helpers
class ListOptimizationUtils {
  /// Calculate item visibility for virtualization
  static bool isItemVisible({
    required int index,
    required double itemHeight,
    required double scrollOffset,
    required double viewportHeight,
    double cacheExtent = 200,
  }) {
    final itemTop = index * itemHeight;
    final itemBottom = itemTop + itemHeight;
    final viewportTop = scrollOffset - cacheExtent;
    final viewportBottom = scrollOffset + viewportHeight + cacheExtent;

    return itemBottom >= viewportTop && itemTop <= viewportBottom;
  }

  /// Determine optimal list item count for initial load
  static int calculateInitialItemCount({
    required double viewportHeight,
    required double itemHeight,
    int overscan = 5,
  }) {
    final visibleCount = (viewportHeight / itemHeight).ceil();
    return visibleCount + overscan * 2;
  }
}