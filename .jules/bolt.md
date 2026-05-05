## 2024-05-03 - Optimize SweepGradient in AnimatedBuilder
**Learning:** In Flutter, recreating an expensive `SweepGradient` shader inside an `AnimatedBuilder` on every frame (using `GradientRotation`) causes significant CPU overhead.
**Action:** Replace `AnimatedBuilder` with `RotationTransition` wrapping a static `CustomPaint` containing the shader. This prevents rebuilding the shader on each tick and delegates the rotation to the rendering engine.
## $(date +%Y-%m-%d) - Replace AnimatedBuilder with ScaleTransition
**Learning:** In Flutter, recreating the widget tree inside an `AnimatedBuilder` for simple scaling animations causes unnecessary rendering overhead.
**Action:** Replace `AnimatedBuilder` that wraps `Transform.scale` with a `ScaleTransition`. This pushes the animation directly to the rendering layer and prevents continuous widget rebuilds.
