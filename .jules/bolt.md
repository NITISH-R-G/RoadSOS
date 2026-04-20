## 2024-05-18 - AnimatedBuilder Optimization
**Learning:** Found a codebase-specific performance issue where `SweepGradient` shaders and `CustomPaint` were being recreated inside `AnimatedBuilder` callbacks for radar animations (60FPS). `SweepGradient` with dynamic `GradientRotation` is expensive to instantiate continuously.
**Action:** Always move static, expensive subtrees (like `Container` with gradients or `CustomPaint` with shaders) to the `child` parameter of `AnimatedBuilder`. Limit the `builder` function strictly to applying `Transform.rotate` to the pre-rendered child.
