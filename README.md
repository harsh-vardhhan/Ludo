# Ludo Zone 🎲

[![Flutter CI](https://github.com/harsh-vardhhan/Ludo/actions/workflows/flutter_ci.yml/badge.svg)](https://github.com/harsh-vardhhan/Ludo/actions/workflows/flutter_ci.yml)
[![Get it on Google Play](https://img.shields.io/badge/Google_Play-Get_it_on-black?logo=googleplay&logoColor=white)](https://play.google.com/store/apps/details?id=com.trakbit.ludozone)
[![Flutter Version](https://img.shields.io/badge/Flutter-%5E3.29.1-blue?logo=flutter)](https://flutter.dev)

A lightweight, high-performance (up to 120 FPS) Ludo board game built with **Flutter** and the **Flame Engine**. Ludo Zone is built for speed, zero friction, and offline play, reaching over **10,000+ downloads** on the Google Play Store.

---

## 🌟 Key Features

- **2 & 4 Player Modes:** Local pass-and-play matches.
- **Offline Play:** Play anywhere without requiring an internet connection.
- **Ad-Free Experience:** No pop-ups or interrupts—just pure gameplay.
- **High-Performance Rendering:** Runs smoothly at up to 120 FPS using the Flame game engine.
- **Ultra-lightweight:** Installs at less than 20MB, making it compatible with budget-friendly devices.

---

## 📖 Deep Dive & Tech Blog
Read about the technical journey of building this game at 120 FPS in the official [Medium Blog Post](https://harsh-vardhhan.medium.com/i-built-a-120-fps-game-using-flutter-c01ef1d46c1a).

---

## 🏗️ Architecture & Codebase Design

The project follows clean architecture guidelines to separate presentation from business rules:

- **Centralized Game Controller (`GameState`):** Separates the business logic, turns, and rule resolutions from Flame rendering widgets.
- **Self-Registering Layout Registry (`HomeSpotManager`):** Manages board coordinates cleanly without fragile widget-tree traversals.
- **Decoupled Components:** `LudoDice` and `Token` act as visual-only rendering nodes, receiving actions from the controller and playing animations.
- **Strict Lint Rules:** Verified with strict static analysis (`flutter analyze`) for reliable compile-time security.

---

## 🛠️ Getting Started

### Prerequisites
Ensure you have the Flutter SDK installed on your system.
- Flutter version: `^3.29.1`
- Dart SDK: `^3.7.0`

### Run Locally
1. **Clone the repository:**
   ```bash
   git clone https://github.com/harsh-vardhhan/Ludo.git
   cd Ludo
   ```
2. **Fetch dependencies:**
   ```bash
   flutter pub get
   ```
3. **Run the application:**
   - On a connected emulator/device:
     ```bash
     flutter run
     ```
   - On macOS Desktop:
     ```bash
     flutter run -d macos
     ```

### Build Signed Release Bundle (AAB)
To package the app for publishing to the Google Play Store:
```bash
flutter build appbundle --release
```

---

## 📐 Board Layout Design

<img width="815" alt="ludo" src="https://github.com/user-attachments/assets/a9cc4093-eef7-4abf-9757-8abf74a1916a">

---

## 📲 Download

Get the official app on the Google Play Store:

<a href="https://play.google.com/store/apps/details?id=com.trakbit.ludozone">
  <img src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png" alt="Get it on Google Play" height="60"/>
</a>
