## 2024-06-11 - AnimatedBuilder Performance Pattern

**Learning:** This codebase frequently uses `AnimatedBuilder` for continuous UI effects like rotating radar sweeps in `MeshRadar` and `BystanderRadar`. Previously, expensive widgets like `Container` with `SweepGradient` or `CustomPaint` were being instantiated and painted inside the `builder` function, causing unnecessary repaints on every animation frame. The proper optimization is to pass the expensive static subtrees to the `child` parameter and restrict the `builder` to only apply transformations (like `Transform.rotate`).

**Action:** Whenever reviewing `AnimatedBuilder` usage, immediately check if static widgets are being rebuilt inside the `builder` callback. If so, extract them to the `child` parameter to reduce UI thread load. Always remember to add explanatory comments detailing the "What, Why, Impact" of the optimization.
