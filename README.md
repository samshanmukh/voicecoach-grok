# 🏋️ VoiceCoach by Grok

The world's first AI personal trainer that analyzes posture, fatigue, and injury risk from your voice alone. No camera, no wearables, just real-time savage coaching powered by Grok and the xAI API.

## ✨ Features

- **🎤 Voice-Only Analysis**: No cameras or wearables needed - just your voice
- **🤖 Powered by Grok**: Advanced AI analysis using xAI's Grok API
- **📊 Real-Time Feedback**: Get instant coaching during your workouts
- **🔍 Multi-Factor Analysis**:
  - Posture detection from voice characteristics
  - Fatigue level monitoring
  - Injury risk assessment
- **📈 Session Tracking**: Track your progress across workout sessions
- **⚡ Real-Time Coaching**: Savage but safety-focused feedback

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- An xAI API key (get one at https://console.x.ai)
- Android Studio / Xcode for mobile development

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/samshanmukh/voicecoach-grok.git
   cd voicecoach-grok
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For Android
   flutter run

   # For iOS
   flutter run -d ios

   # For a specific device
   flutter devices  # List available devices
   flutter run -d <device-id>
   ```

### Configuration

1. **Get your xAI API Key**
   - Visit https://console.x.ai
   - Sign in or create an account
   - Navigate to the API Keys section
   - Create a new API key
   - Copy the key

2. **Configure the app**
   - Launch the app
   - Tap the Settings icon (⚙️)
   - Enter your xAI API key
   - Tap "Save API Key"

## 📱 How to Use

1. **Start a Workout**
   - Tap the "Start Workout" button
   - Grant microphone permissions when prompted
   - Begin your exercise routine

2. **During Your Workout**
   - Speak naturally while exercising
   - The app records short voice segments every 5 seconds
   - Grok analyzes your voice for signs of:
     - Poor posture
     - Fatigue
     - Injury risk

3. **Receive Real-Time Feedback**
   - View Grok's savage but helpful coaching messages
   - Check your posture, fatigue, and injury risk scores
   - Adjust your form based on the feedback

4. **Track Your Progress**
   - View session statistics
   - Monitor average scores across the workout
   - Review analysis history

## 🏗️ Project Structure

```
voicecoach-grok/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/
│   │   └── coaching_response.dart # Data models
│   ├── services/
│   │   ├── xai_service.dart      # xAI API integration
│   │   └── audio_service.dart    # Voice recording
│   ├── providers/
│   │   └── workout_provider.dart # State management
│   ├── screens/
│   │   ├── home_screen.dart      # Main workout screen
│   │   └── settings_screen.dart  # Configuration
│   └── widgets/
│       ├── coaching_feedback_card.dart
│       └── stats_display.dart
├── android/                       # Android configuration
├── ios/                          # iOS configuration
└── pubspec.yaml                  # Dependencies
```

## 🔧 Technologies Used

- **Flutter**: Cross-platform mobile framework
- **Dart**: Programming language
- **xAI Grok API**: AI-powered analysis
- **Provider**: State management
- **record**: Audio recording
- **permission_handler**: Runtime permissions
- **http/dio**: API communication

## 🎯 How It Works

1. **Voice Capture**: The app continuously records short voice segments (3-5 seconds) during your workout
2. **Audio Analysis**: Each segment is analyzed for characteristics like:
   - Amplitude patterns
   - Breathing irregularities
   - Voice strain indicators
3. **AI Processing**: Metadata is sent to Grok for intelligent analysis
4. **Feedback Generation**: Grok returns:
   - Personalized coaching feedback
   - Posture status and recommendations
   - Fatigue level assessment
   - Injury risk warnings

## 📊 Understanding the Scores

- **Posture Score (0-100)**
  - 80-100: Good posture
  - 60-79: Needs improvement
  - 0-59: Poor posture

- **Fatigue Score (0-100)**
  - 0-25: Low fatigue
  - 26-50: Moderate fatigue
  - 51-75: High fatigue
  - 76-100: Extreme fatigue

- **Injury Risk Score (0-100)**
  - 0-25: Low risk
  - 26-50: Moderate risk
  - 51-75: High risk
  - 76-100: Critical risk

## 🔐 Privacy & Security

- All voice recordings are temporary and processed locally
- Audio segments are deleted after analysis
- Your xAI API key is stored securely on your device
- No voice data is stored permanently

## 🛠️ Development

### Running in Debug Mode
```bash
flutter run --debug
```

### Building for Production
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

### Running Tests
```bash
flutter test
```

## 📝 License

This project is licensed under the terms specified in the LICENSE file.

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest features
- Submit pull requests

## 🙏 Acknowledgments

- Built with [Flutter](https://flutter.dev)
- Powered by [xAI Grok](https://x.ai)
- Inspired by the future of AI-powered fitness coaching

## 📞 Support

For issues, questions, or feedback:
- Open an issue on GitHub
- Contact the development team

---

**Note**: This app requires an active xAI API key. Voice analysis quality depends on ambient noise levels and microphone quality.
