import 'package:flutter/material.dart';

// This value is an eyeball estimation of the time it takes for the iOS cursor
// to ease in and out.
const _kDefaultFadeDuration = Duration(milliseconds: 250);

// The time it takes for the cursor to fade from fully opaque to fully
// transparent and vice versa. A full cursor blink, from transparent to opaque
// to transparent, is twice this duration.
const _kDefaultBlinkHalfPeriod = Duration(milliseconds: 500);

// The time the cursor is static in opacity before animating to become
// transparent.
const _kDefaultBlinkWaitForStart = Duration(milliseconds: 150);

const _kZeroDuration = Duration();

const _kDefaultRadius = Radius.zero;

/// Cursor data class.
class Cursor {
  /// Width of cursor.
  final double? width;

  /// Height of cursor.
  final double? height;

  /// Radius of cursor, default is [
  final Radius radius;

  /// Color of cursor.
  final Color color;

  /// This value is an eyeball estimation of the time it takes for the iOS cursor
  /// to ease in and out.
  final Duration fadeDuration;

  /// The time it takes for the cursor to fade from fully opaque to fully
  /// transparent and vice versa. A full cursor blink, from transparent to opaque
  /// to transparent, is twice this duration.
  final Duration blinkHalfPeriod;

  /// The time the cursor is static in opacity before animating to become
  /// transparent.
  final Duration blinkWaitForStart;

  /// Whether to show cursor, if the value is false, would ignore any other property setter.
  final bool enabled;

  /// The orientation of cursor
  final Orientation orientation;

  /// The offset from center
  final double offset;

  Cursor.disabled()
      : width = 0.0,
        height = 0.0,
        radius = _kDefaultRadius,
        color = Colors.black,
        fadeDuration = _kDefaultFadeDuration,
        blinkHalfPeriod = _kDefaultBlinkHalfPeriod,
        blinkWaitForStart = _kDefaultBlinkWaitForStart,
        orientation = Orientation.vertical,
        offset = 0.0,
        enabled = false;

  const Cursor({
    this.width,
    this.height,
    this.radius = _kDefaultRadius,
    required this.color,
    this.fadeDuration = _kDefaultFadeDuration,
    this.blinkHalfPeriod = _kDefaultBlinkHalfPeriod,
    this.blinkWaitForStart = _kDefaultBlinkWaitForStart,
    this.orientation = Orientation.vertical,
    this.offset = 0.0,
    this.enabled = false,
  })  : assert(width != null || height != null),
        assert(width == null || width >= 0.0),
        assert(height == null || height >= 0.0),
        assert(fadeDuration > _kZeroDuration),
        assert(blinkHalfPeriod > _kZeroDuration),
        assert(blinkWaitForStart > _kZeroDuration);

  Cursor copyWith({
    double? width,
    double? height,
    Radius? radius,
    Color? color,
    Duration? fadeDuration,
    Duration? blinkHalfPeriod,
    Duration? blinkWaitForStart,
    Orientation? orientation,
    double? offset,
    bool? enabled,
  }) =>
      Cursor(
        width: width ?? this.width,
        height: height ?? this.height,
        radius: radius ?? this.radius,
        color: color ?? this.color,
        fadeDuration: fadeDuration ?? this.fadeDuration,
        blinkHalfPeriod: blinkHalfPeriod ?? this.blinkHalfPeriod,
        blinkWaitForStart: blinkWaitForStart ?? this.blinkWaitForStart,
        orientation: orientation ?? this.orientation,
        offset: offset ?? this.offset,
        enabled: enabled ?? this.enabled,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cursor &&
          runtimeType == other.runtimeType &&
          width == other.width &&
          height == other.height &&
          radius == other.radius &&
          color == other.color &&
          fadeDuration == other.fadeDuration &&
          blinkHalfPeriod == other.blinkHalfPeriod &&
          blinkWaitForStart == other.blinkWaitForStart &&
          enabled == other.enabled &&
          orientation == other.orientation &&
          offset == other.offset;

  @override
  int get hashCode =>
      width.hashCode ^
      height.hashCode ^
      radius.hashCode ^
      color.hashCode ^
      fadeDuration.hashCode ^
      blinkHalfPeriod.hashCode ^
      blinkWaitForStart.hashCode ^
      enabled.hashCode ^
      orientation.hashCode ^
      offset.hashCode;

  @override
  String toString() {
    return 'Cursor{width: $width, height: $height, radius: $radius, color: $color, fadeDuration: $fadeDuration, blinkHalfPeriod: $blinkHalfPeriod, blinkWaitForStart: $blinkWaitForStart, enabled: $enabled, orientation: $orientation, offset: $offset}';
  }
}

/// Whether in portrait or landscape.
enum Orientation {
  horizontal,
  vertical,
}
