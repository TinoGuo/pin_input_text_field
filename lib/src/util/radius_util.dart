import 'dart:math' as math;
import 'dart:ui';

// Get inner radius of providing outerRadius and stroke.
// https://graphicdesign.stackexchange.com/questions/8919/how-to-compute-the-radii-radiuses-of-corners-for-concentric-rounded-rects
Radius getInnerRadius(Radius outerRadius, double strokeWidth) {
  var x = math.max(outerRadius.x - strokeWidth / 2, 0.0);
  var y = math.max(outerRadius.y - strokeWidth / 2, 0.0);
  return Radius.elliptical(x, y);
}
