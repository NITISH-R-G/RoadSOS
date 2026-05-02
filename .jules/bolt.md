## 2024-05-24 - Isolate expensive shaders in AnimatedBuilder

**Learning:** Rebuilding expensive visual properties (like `SweepGradient` shaders) inside an `AnimatedBuilder`'s builder function on every tick can cause significant performance bottlenecks in Flutter.
**Action:** Extract static visual subtrees containing expensive paints or shaders into the `child` parameter of `AnimatedBuilder` and restrict the `builder` function strictly to applying cheap transformations like `Transform.rotate` or `Transform.translate`. Ensure `CustomPainter` instances involved return `false` for `shouldRepaint` when their parameters do not dynamically change.
