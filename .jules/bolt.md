## 2023-10-25 - CustomPainter Repaint Argument for Flutter Animations
**Learning:** For continuous complex animations like sweeping radar beams or pulsing glows in Flutter, wrapping widgets with `RotationTransition` or `AnimatedBuilder` causes expensive widget tree rebuilds on every frame.
**Action:** Refactor the animation by passing the `AnimationController` directly to the `CustomPainter`'s `repaint` argument. This delegates positioning, pulsing, and rotation logic entirely to the canvas layer, completely bypassing widget diffs and significantly improving performance.
