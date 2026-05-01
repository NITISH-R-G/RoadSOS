
## 2024-05-18 - AnimatedBuilder Subtree Caching
**Learning:** In Flutter, passing a builder function to `AnimatedBuilder` that constructs complex static layout or painting objects (like `BoxDecoration` with `BoxShadow`, or `CustomPaint` with heavy shaders) on every frame can cause significant GC pressure and performance drops.
**Action:** Always extract the static parts of an animation into the `child` argument of `AnimatedBuilder`. Keep the `builder` function focused strictly on the parts that change (e.g. `Transform.translate` or `Transform.rotate`). Removed dynamic pulse that was forcing the recreation of `Color` and `BoxShadow` instances in continuous animations.
