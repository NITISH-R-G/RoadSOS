## 2024-05-03 - Optimize SweepGradient in AnimatedBuilder
**Learning:** In Flutter, recreating an expensive `SweepGradient` shader inside an `AnimatedBuilder` on every frame (using `GradientRotation`) causes significant CPU overhead.
**Action:** Replace `AnimatedBuilder` with `RotationTransition` wrapping a static `CustomPaint` containing the shader. This prevents rebuilding the shader on each tick and delegates the rotation to the rendering engine.
## 2024-05-24 - Optimize AnimatedBuilder with ScaleTransition
**Learning:** In Flutter, using `AnimatedBuilder` with `Transform.scale` requires custom widget building on each frame.
**Action:** Replace `AnimatedBuilder` with `ScaleTransition` when possible. This delegates the transformation to the rendering engine and prevents costly widget rebuilds on every frame, improving UI performance during continuous animations.
## 2024-05-10 - Asynchronous Speech-to-Text resolution
**Learning:** Using `Future.delayed` for maximum timeout length in speech recognition causes severe latency, holding system resources (microphone) and delaying UI responses even if the command was recognized in the first 500ms.
**Action:** Replace arbitrary `Future.delayed` fallbacks with `Completer<T>` combined with `future.timeout()`. Complete the future immediately in the text recognition callback upon a match and explicitly stop the listening engine (`_stt.stop()`) to release hardware resources.
