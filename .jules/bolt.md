# 2024-05-24

## Title
Fixing discarded_futures without ignore

## Learning
When resolving `discarded_futures` linter warnings, use `unawaited(Future)` from `dart:async` instead of using `// ignore: discarded_futures` comments to properly document the intentional execution of an unawaited future without suppressing the lint globally.

## Action
Added `unawaited(FirstAidStore.getVerifiedAdvice(query))` in `first_aid_screen.dart`.
