
## 2024-05-18 - Avoid Expensive Shaders in AnimatedBuilder Rebuilds
**Learning:** Found a performance anti-pattern in radar animations (`mesh_radar.dart`, `bystander_radar.dart`). Putting expensive `SweepGradient` shaders inside the `builder` of an `AnimatedBuilder` causes the gradient to be recalculated and recreated on every single frame. This heavily taxes the GPU and drops frames.
**Action:** When rotating complex UI or gradients, always extract the static element (e.g., the `Container` with the gradient or the `CustomPaint`) to the `child` parameter of `AnimatedBuilder`. Limit the `builder` function strictly to applying `Transform.rotate` to the pre-rendered `child`.
