# Contributing to Fasting Tracker

Thank you for your interest in contributing! This document explains how to get started.

---

## Code of Conduct

Be respectful and constructive. All contributions are welcome regardless of experience level.

---

## How to Contribute

### Reporting Bugs

1. Check [existing issues](https://github.com/mstajanc/fasting-tracker/issues) first
2. Open a new issue with:
   - Device model and Android version
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshot if applicable

### Suggesting Features

Open an issue with the `enhancement` label and describe:
- What the feature does
- Why it would be useful
- Any UI mockup or example

### Submitting Code

1. **Fork** the repository
2. **Create a branch** from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes** following the guidelines below
4. **Test** on a real device (GrapheneOS preferred)
5. **Commit** with a clear message:
   ```bash
   git commit -m "feat: add your feature description"
   ```
6. **Push** and open a **Pull Request** against `main`

---

## Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/fasting-tracker.git
cd fasting-tracker

# Install dependencies
flutter pub get

# Run in debug mode
flutter run -d YOUR_DEVICE_ID
```

---

## Guidelines

### Privacy First
- **No Google dependencies** — no Firebase, no Play Services, no Google APIs
- **No internet requests** — the app must work fully offline
- **No analytics or tracking** of any kind

### Code Style
- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter analyze` before submitting — zero warnings required
- Keep widgets small and focused
- Add comments for non-obvious logic

### Commit Messages
Use conventional commits format:
```
feat: add new fasting goal option
fix: correct timer display after midnight
docs: update README installation steps
refactor: simplify storage service
```

---

## What We Won't Accept

- Any Google Services integration (Firebase, Analytics, etc.)
- Internet permissions or network calls
- Third-party analytics or crash reporting SDKs
- Features that compromise user privacy

---

## Questions?

Open an issue and tag it with `question`. We're happy to help!
