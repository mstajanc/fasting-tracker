# Changelog

All notable changes to Fasting Tracker will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [1.0.0] - 2026-03-15

### Added
- **HomeScreen** with active fasting timer and start/stop button
- **Circular progress ring** with animated fill showing elapsed vs goal time
- **Color coding**: red (early phase) → yellow (approaching goal) → green (goal reached)
- **Fasting goal selector**: 16h, 18h, 20h, 24h presets
- **HistoryScreen**: scrollable list of all completed fasts with date, start time, end time and duration
- **EditFastScreen**: manual adjustment of start and end time for any past fast
- **Hive local storage**: all data stored on-device, no cloud sync
- **Dark theme**: clean modern UI optimized for OLED displays
- **Smooth animations**: progress ring and screen transitions
- GrapheneOS compatibility — zero Google dependencies
- Minimum Android SDK 26 (Android 8.0)

### Technical
- Pure Flutter implementation
- Hive database for local persistence
- No internet permission required
- No Google Services, Firebase or Play Services
- APK size: ~16 MB
