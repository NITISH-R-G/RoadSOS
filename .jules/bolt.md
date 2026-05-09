## 2024-05-03 - Optimize SweepGradient in AnimatedBuilder
**Learning:** In Flutter, recreating an expensive `SweepGradient` shader inside an `AnimatedBuilder` on every frame (using `GradientRotation`) causes significant CPU overhead.
**Action:** Replace `AnimatedBuilder` with `RotationTransition` wrapping a static `CustomPaint` containing the shader. This prevents rebuilding the shader on each tick and delegates the rotation to the rendering engine.
## 2024-05-24 - Optimize AnimatedBuilder with ScaleTransition
**Learning:** In Flutter, using `AnimatedBuilder` with `Transform.scale` requires custom widget building on each frame.
**Action:** Replace `AnimatedBuilder` with `ScaleTransition` when possible. This delegates the transformation to the rendering engine and prevents costly widget rebuilds on every frame, improving UI performance during continuous animations.
## 2024-06-25 - Pre-compute Search Haystack
**Learning:** Mapping JSON into a strongly typed object and pre-computing lowercased fields during initialization avoids redundant string allocations and `.toLowerCase()` calls in a search loop.
**Action:** Optimize search functions to use pre-computed lowercased fields on a dedicated data class rather than converting map values on every keystroke.
