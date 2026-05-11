## 2024-05-03 - Optimize SweepGradient in AnimatedBuilder
**Learning:** In Flutter, recreating an expensive `SweepGradient` shader inside an `AnimatedBuilder` on every frame (using `GradientRotation`) causes significant CPU overhead.
**Action:** Replace `AnimatedBuilder` with `RotationTransition` wrapping a static `CustomPaint` containing the shader. This prevents rebuilding the shader on each tick and delegates the rotation to the rendering engine.
## 2024-05-24 - Optimize AnimatedBuilder with ScaleTransition
**Learning:** In Flutter, using `AnimatedBuilder` with `Transform.scale` requires custom widget building on each frame.
**Action:** Replace `AnimatedBuilder` with `ScaleTransition` when possible. This delegates the transformation to the rendering engine and prevents costly widget rebuilds on every frame, improving UI performance during continuous animations.
## 2024-05-24 - Typed Models & Pre-computing Search Strings
**Learning:** In Dart, calling `.toLowerCase()` and accessing dynamic `Map<String, dynamic>` fields inside a search loop (like autocomplete) creates unnecessary String allocations and type-checking overhead, slowing down performance.
**Action:** Parse raw JSON into strongly-typed classes (e.g., `_FirstAidEntry`) during initialization and pre-compute lowercased fields for search loops to eliminate redundant allocations and map access overhead.
