#!/usr/bin/env bash

echo "🚀 Bootstrapping RoadSOS Local Environment..."

# Check dependencies
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter ^3.11.0"
    return 1 2>/dev/null || true
fi

echo "📦 Fetching Flutter dependencies..."
flutter pub get

echo "🔑 Checking for .env file..."
if [ ! -f .env ]; then
    echo "⚠️ .env file missing. Copying from .env.example..."
    cp .env.example .env
fi

echo "🪝 Setting up git hooks..."
mkdir -p .git/hooks
cat << 'HOOK' > .git/hooks/pre-commit
#!/usr/bin/env bash
echo "🔍 Running Flutter Analyze..."
flutter analyze || exit 1
echo "🧪 Running tests..."
flutter test || exit 1
echo "🧹 Checking formatting..."
dart format --output=none --set-exit-if-changed . || exit 1
HOOK
chmod +x .git/hooks/pre-commit

echo "✅ Environment ready! You can now run: flutter run"
