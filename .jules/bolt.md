## 2024-11-20 - AnimatedBuilder Optimization
**Learning:** In Flutter, passing the static child widget to the `child` parameter of `AnimatedBuilder` prevents the framework from recreating the widget tree inside the `builder` function on every frame tick, saving significant CPU cycles and object allocations.
**Action:** Always use the `child` parameter in `AnimatedBuilder` for widget subtrees that do not depend on the animation's current value.
