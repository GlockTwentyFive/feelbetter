# Feel Better

<p align="center">
  <img src="assets/icon/app_icon.png" alt="Feel Better app icon" width="160" />
</p>

Feel Better is a cross-platform emotional repair toolkit built with Flutter. It stays fully offline, puts your privacy first, and delivers minimal, science-backed workflows for settling your nervous system and repairing relationships when things feel heavy.

## Table of contents

1. [Features](#features)
2. [Philosophy](#philosophy)
3. [Architecture](#architecture)
4. [Theming](#theming)
5. [Screenshots](#screenshots)
6. [Prerequisites](#prerequisites)
7. [Getting started](#getting-started)
8. [Development scripts](#development-scripts)
9. [Testing](#testing)
10. [Contributing](#contributing)
11. [License](#license)

## Features

- **Minimal, responsive calm home** – Compact quick-action hero that works beautifully on phones, tablets, and desktops.
- **Evidence-rich strategy library** – Emotion pages surface immediate, short-term, long-term, relationship-support, and self-repair plans with source badges.
- **Guided breathwork** – Built-in Breathe view provides quick parasympathetic resets.
- **Journaling & history** – Capture reflections, review past logs, and maintain streaks that reinforce positive habits.
- **Analytics dashboard** – Visualise emotion trends to identify triggers and patterns over time.
- **Multi-theme support** – Seven evidence-informed themes (light/dark pairs) designed to reduce cognitive load and respect accessibility.
- **Totally offline** – No accounts, no tracking, and all data stored locally.

## Philosophy

The `About this app` button exposes a fully scrollable philosophy dialog that captures the project’s promises:

- **Free forever** – No paywalls or data monetisation.
- **Private** – Journal entries, history, and strategies remain on-device.
- **Ad-free** – A calming space with no distractions.

## Architecture

| Layer | Description |
| --- | --- |
| `lib/app.dart`, `lib/main.dart` | Entry point and navigation shell using `MaterialApp` with provider-based state. |
| State management | `ChangeNotifier` via `provider` package in `lib/providers/app_state.dart`. |
| Data models | Plain Dart models under `lib/models/` with JSON parsing helpers. |
| Storage | `shared_preferences` for persisting emotion categories, logs, journal entries, and theme choice. |
| UI | Views under `lib/views/` and reusable widgets in `lib/widgets/`. |
| Theming | Custom `ThemeExtension` in `lib/theme/app_theme.dart` to expose design tokens to widgets. |

## Theming

Feel Better ships with the following theme families:

- **Calm Light / Dusk Dark** – Default lavender-based palette for serene focus.
- **Serene Light / Serene Dark** – Warm neutrals optimised for evening reflection.
- **Forest Light / Forest Dark** – Verdant greens emphasising restoration.
- **Tide Dark** – Oceanic deep blues for night-time usage.

Each theme defines colour tokens for surface backgrounds, typography, elevation, and emotion-specific accents. Components consume these tokens exclusively through the `FeelBetterTheme` extension to ensure consistency and smooth runtime switching.

## Screenshots

> _Add screenshots or animated GIFs here once captures are available._

## Prerequisites

- Flutter SDK >= 3.35.0 (stable channel recommended)
- Dart >= 3.2
- A recent version of Android Studio, VS Code, or another Flutter-capable IDE
- For desktop builds, ensure the relevant platform tooling is installed (see [Flutter desktop docs](https://docs.flutter.dev/desktop)).

## Getting started

```bash
# clone the repository
git clone https://github.com/<your-account>/feel-better.git
cd feel-better/Flutter_App

# fetch dependencies
flutter pub get

# run the app (pick one target)
flutter run                # auto-detects a connected device
flutter run -d web-server  # web
flutter run -d macos       # macOS desktop
flutter run -d windows     # Windows desktop
flutter run -d linux       # Linux desktop
```

### Environment variables

No secret keys are required for the default build. If you extend the app with networked services, create a `.env` file and load it via your chosen configuration approach.

## Development scripts

```bash
flutter pub run build_runner build   # if you add code generation
flutter format lib test              # format code
flutter analyze                      # static analysis
dart run tool/generate_app_icon.dart # regenerates the source icon (optional)
flutter pub run flutter_launcher_icons # rebuilds platform launcher icons
```

## Testing

```bash
flutter test
```

Add widget and integration tests as you grow the feature set. Prioritise coverage for emotion logging flows, quick strategy actions, and journal persistence.

## Contributing

1. Fork the repository and create a feature branch.
2. Follow the existing code style (`flutter format`).
3. Open a descriptive pull request with screenshots for UI-affecting changes.
4. Ensure all tests pass (`flutter test`, `flutter analyze`).

## License

This project is released under the GNU General Public License v3.0. See [LICENSE](LICENSE) for the full text and usage terms.
