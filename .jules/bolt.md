## 2024-06-25 - Extracted AnimatedBuilder children to static subtrees
**Learning:** AnimatedBuilder is commonly misused by placing expensive UI layouts (like CustomPaint with sweep shaders or complex Containers) directly in the builder function. This causes the entire subtree to be rebuilt and repainted every single frame.
**Action:** When animating transformations like rotations or translations, strictly pass the heavy UI components to the `child` parameter. The `builder` should only return a lightweight widget like `Transform.rotate(angle: ..., child: child)`.
