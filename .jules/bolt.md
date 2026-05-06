## 2024-05-03 - Optimize SweepGradient in AnimatedBuilder
**Learning:** In Flutter, recreating an expensive `SweepGradient` shader inside an `AnimatedBuilder` on every frame (using `GradientRotation`) causes significant CPU overhead.
**Action:** Replace `AnimatedBuilder` with `RotationTransition` wrapping a static `CustomPaint` containing the shader. This prevents rebuilding the shader on each tick and delegates the rotation to the rendering engine.
## 2024-05-06 - Replacing AnimatedBuilder + Transform.scale with ScaleTransition
**Learning:** Rebuilding a complex widget tree inside an `AnimatedBuilder` purely for scaling causes unnecessary CPU overhead in Flutter, specifically documented in this codebase's rules.
**Action:** Replace `AnimatedBuilder` that returns a `Transform.scale` with `ScaleTransition` natively. Always include an explanatory comment ("⚡ Bolt Optimization: ...") above the optimized block, and check for accidental dependency downgrades in `pubspec.lock` after running tests locally.
