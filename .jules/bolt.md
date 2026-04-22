## 2025-02-09 - AnimatedBuilder Optimization
**Learning:** AnimatedBuilder without passing a `child` rebuilds the entire widget tree inside its `builder` function on every tick. For complex paints or subtrees, this causes excessive CPU and GPU load.
**Action:** Always extract the static parts of an AnimatedBuilder to the `child` parameter so they are passed back into the `builder` function and avoid rebuilding.
