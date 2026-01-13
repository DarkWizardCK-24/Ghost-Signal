# 🕵️ GhostSignal - Secret Message Decoder


A Flutter app for encoding, decoding, and cracking secret messages with a beautiful dark neon hacker theme. Dive into the world of cryptography with intuitive tools and challenging puzzles, all powered by a responsive UI and secure backend.

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com/)

## ✨ Features

### 1️⃣ Morse Code Auto Decoder
- **Smart Pattern Recognition**: Handles imperfect Morse input, including missing spaces or incorrect separators.
- **Encode & Decode**: Seamlessly convert text to Morse code and vice versa.
- **Confidence Scoring**: Provides reliability scores for decoded messages.
- **Auto-spacing Detection**: Intelligently identifies and separates Morse characters.

### 2️⃣ Caesar Cipher Cracker
- **Brute Force All 25 Shifts**: Automatically tests every possible shift for decryption.
- **Smart Ranking**: Uses language detection to prioritize readable English outputs.
- **Score System**: Displays confidence percentages for each attempt.
- **Best Match Highlighting**: Highlights the most probable correct decryption.

### 3️⃣ Steganography (5 Methods!)
Hide messages in plain sight with varying security levels. Encoding and decoding are supported, but advanced techniques remain proprietary for security.

- 🔓 **Last Word (Low Security)**: Conceals message in the last word of each line.
- 🔓 **First Letter (Low Security)**: Uses an acrostic pattern where first letters form the message.
- 🔒 **Jigsaw Pattern (Medium Security)**: Employs a diagonal word selection pattern.
- 🔒🔒 **Advanced Jigsaw (High Security)**: Incorporates variable structures with added noise for obfuscation.
- 🔒🔒🔒 **Semantic Scatter (Maximum Security)**: Disperses words using a mathematical pattern, buried in natural-looking text for near-undetectability.

### 4️⃣ Daily Challenges
- **Timed Morse Puzzles**: Challenge your decoding speed under time pressure.
- **Difficulty Levels**:
  - **Easy**: Clear spacing (25 points).
  - **Medium**: Reduced spacing (50 points).
  - **Hard**: No spaces with added noise (100 points).
- **Score System**: Earn points plus bonuses for quick completions.

## 🎨 Design Features
- **Dark Mode Theme**: Neon accents in green, purple, blue, and pink for a hacker vibe.
- **Beautiful Animations**: Fade-in, slide-up, and glow pulse effects.
- **Glassmorphism Effects**: Glowing borders and translucent elements.
- **Font Family**: Inter from Google Fonts for a modern look.
- **Responsive UI**: Adapts to all screen sizes.
- **Animated Cards**: Interactive method selection with animations.
- **Security Indicators**: Color-coded levels for quick reference.


## 🛠️ Tech Stack
GhostSignal is built with a modern, cross-platform tech stack for performance and scalability:

- **Frontend**: Flutter (using Dart) for building the native mobile app. Flutter enables a single codebase for iOS and Android, with rich widgets for the neon-themed UI and animations.
- **Backend**: Python with FastAPI for handling server-side logic, such as secure message processing, challenge generation, and API endpoints for encoding/decoding. FastAPI provides high-performance asynchronous APIs, making it ideal for real-time features like daily challenges.
- **Additional Dependencies**:
  - Flutter packages: `flutter_animate` for animations, `google_fonts` for typography, and `http` for API communication.
  - Python libraries: Integrated with FastAPI for RESTful services, potentially using `pydantic` for data validation and `uvicorn` for deployment.
- **Why This Stack?** Flutter ensures a smooth, responsive user experience across devices, while FastAPI offers efficient backend support for cryptographic computations without compromising speed.


Made with 💚 by DarkWizard
