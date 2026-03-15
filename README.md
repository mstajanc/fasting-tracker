# 🕐 Fasting Tracker

A beautiful, privacy-first intermittent fasting tracker built with Flutter for GrapheneOS — no Google dependencies, no internet required, all data stays on your device.

![Flutter](https://img.shields.io/badge/Flutter-3.27.4-blue?logo=flutter)
![Android](https://img.shields.io/badge/Android-8.0%2B%20(API%2026%2B)-green?logo=android)
![License](https://img.shields.io/badge/License-MIT-yellow)
![GrapheneOS](https://img.shields.io/badge/GrapheneOS-Compatible-teal)

---

## Features

- ⏱️ **Fasting Timer** — Start and stop your fast with one tap
- 🔵 **Circular Progress Ring** — Visual progress toward your fasting goal
- 🎨 **Color Coding** — Red (early phase) → Yellow (approaching goal) → Green (goal reached)
- 🎯 **Fasting Goals** — Choose from 16h, 18h, 20h, or 24h presets
- 📋 **Fasting History** — Scrollable log of all completed fasts
- ✏️ **Manual Editing** — Adjust start and end time of any fast
- 🌙 **Dark Theme** — Clean, modern dark UI with smooth animations
- 🔒 **100% Private** — All data stored locally, no internet required

---

## Privacy & Security

This app was built specifically for **GrapheneOS** users who value privacy:

| Feature | Status |
|---|---|
| Google Services | ❌ None |
| Firebase | ❌ None |
| Internet permission | ❌ Not requested |
| Analytics / Tracking | ❌ None |
| Local storage only | ✅ Yes (Hive) |
| Works without Play Services | ✅ Yes |

---

## Installation

### Option A — Install APK directly (recommended)

1. Download the latest APK from [Releases](https://github.com/mstajanc/fasting-tracker/releases)
2. Transfer to your GrapheneOS device
3. Enable **Install unknown apps** for your file manager
4. Tap the APK to install

### Option B — Build from source

#### Requirements
- [Flutter SDK 3.27+](https://flutter.dev/docs/get-started/install)
- Android SDK (API 26+)
- Java 17+

#### Steps

```bash
# Clone the repository
git clone https://github.com/mstajanc/fasting-tracker.git
cd fasting-tracker

# Install dependencies
flutter pub get

# Run on connected device
flutter run --release

# Or build APK
flutter build apk --release
```

The APK will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## Project Structure

```
lib/
├── main.dart                  # App entry point, theme, routing
├── models/
│   ├── fast_record.dart       # FastRecord data model
│   └── fast_record.g.dart     # Hive type adapter (generated)
├── screens/
│   ├── home_screen.dart       # Active timer + goal selector
│   ├── history_screen.dart    # List of completed fasts
│   └── edit_fast_screen.dart  # Manual time editing
├── services/
│   └── storage_service.dart   # Hive local storage service
└── widgets/
    ├── fasting_ring.dart       # Circular progress ring widget
    └── goal_selector.dart      # Fasting goal selector widget
```

---

## Tech Stack

| Technology | Purpose |
|---|---|
| [Flutter](https://flutter.dev) | UI framework |
| [Hive](https://pub.dev/packages/hive) | Local database |
| [hive_flutter](https://pub.dev/packages/hive_flutter) | Flutter integration for Hive |
| [path_provider](https://pub.dev/packages/path_provider) | App storage directory |
| [intl](https://pub.dev/packages/intl) | Date/time formatting |

---

## Fasting Goals

| Goal | Description |
|---|---|
| **16:8** | Fast 16 hours, eat within 8-hour window |
| **18:6** | Fast 18 hours, eat within 6-hour window |
| **20:4** | Fast 20 hours, eat within 4-hour window |
| **24h** | Full 24-hour fast |

---

## Minimum Requirements

- Android 8.0 (API Level 26) or higher
- ~16 MB storage space
- No internet connection required

---

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## Acknowledgements

- Built with [Flutter](https://flutter.dev)
- Local storage powered by [Hive](https://docs.hivedb.dev)
- Designed for [GrapheneOS](https://grapheneos.org) users
