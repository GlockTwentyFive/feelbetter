# Feel Better

<p align="center">
  <img src="assets/icon/app_icon.png" alt="Feel Better app icon" width="160" />
</p>

Feel Better is a cross-platform emotional support toolkit built with Flutter. It helps people track moods, explore evidence-informed coping strategies, and build healthier habits with a gentle, science-backed interface.

## Table of contents

1. [Features](#features)
2. [Architecture](#architecture)
3. [Theming](#theming)
4. [Screenshots](#screenshots)
5. [Prerequisites](#prerequisites)
6. [Getting started](#getting-started)
7. [Development scripts](#development-scripts)
8. [Testing](#testing)
9. [Contributing](#contributing)
10. [License](#license)

## Features

- **Emotion-first onboarding** – Quickly log what you are feeling and surface the most relevant support paths.
- **Curated strategy library** – Immediate, short-term, long-term, and interpersonal tools organised by emotion.
- **Quick strategy flows** – One-tap access to grounding techniques when feeling overwhelmed or low.
- **Guided breathwork** – Built-in Breathe view for quick parasympathetic resets.
- **Journaling & history** – Capture reflections, review past logs, and maintain streaks that reinforce positive habits.
- **Analytics dashboard** – Visualise emotion trends to identify triggers and patterns over time.
- **Multi-theme support** – Seven evidence-informed themes (light/dark pairs) designed to reduce cognitive load and respect accessibility.

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

- Flutter SDK >= 3.12
- Dart >= 3.2
- A recent version of Android Studio, VS Code, or another Flutter-capable IDE
- For desktop builds, ensure the relevant platform tooling is installed (see [Flutter desktop docs](https://docs.flutter.dev/desktop)).

## Getting started

```bash
# clone the repository
git clone https://github.com/<your-account>/feel-better.git
cd feel-better/"Flutter App"

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
