## 2024-05-24 - AnimatedBuilder Optimization
**Learning:** This codebase uses expensive `SweepGradient` shaders inside `CustomPaint`. Rebuilding these every frame inside an `AnimatedBuilder` is a performance anti-pattern.
**Action:** Always extract static subtrees (like `CustomPaint` with gradients) to the `child` parameter of `AnimatedBuilder` and restrict the `builder` function strictly to applying fast transformations like `Transform.rotate` to avoid shader recreation overhead.
