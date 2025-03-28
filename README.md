# Live Summarize AI

A Flutter mobile application that records live audio, converts speech to text, and summarizes key points using AI.

## Features

- **Audio Recording**: Record live audio sessions with high-quality audio
- **Speech-to-Text**: Convert recorded audio to text using AI-powered speech recognition
- **Key Point Summarization**: Generate concise summaries with key points from the transcribed text
- **History Management**: Save, view, and manage past summaries
- **Dark Mode Support**: Toggle between light and dark themes

## Project Architecture

This project follows a clean architecture pattern with GetX for state management:

- **Domain Layer**: Contains the core business logic and entities
- **Data Layer**: Contains repositories and data providers
- **Presentation Layer**: Contains UI elements and controllers for state management

## Technologies Used

- **Flutter**: Cross-platform UI framework
- **GetX**: State management and dependency injection
- **record**: Audio recording functionality
- **flutter_screenutil**: Responsive UI
- **shared_preferences**: Local storage for summaries

## Getting Started

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart SDK 2.12.0 or higher

### Installation

1. Clone the repository:
```
git clone https://github.com/yourusername/flutter_live_summarize_ai.git
```

2. Navigate to the project directory:
```
cd flutter_live_summarize_ai
```

3. Install dependencies:
```
flutter pub get
```

4. Run the app:
```
flutter run
```

## Usage

1. **Start Recording**: Tap the recording button on the home screen to start a new recording session
2. **Stop Recording**: Tap the stop button to end the recording and begin processing
3. **View Summary**: After processing, the app displays key points extracted from the recording
4. **Manage History**: Access past summaries from the history tab
5. **Settings**: Adjust app settings, including theme, from the settings tab

## Project Structure

```
lib/
  ├── core/           # Core functionality
  │   ├── bindings/   # Dependency injection
  │   ├── constants/  # App constants
  │   ├── error/      # Error handling
  │   ├── helpers/    # Utility functions
  │   ├── routes/     # App navigation
  │   └── theme/      # App theming
  ├── data/           # Data layer
  │   ├── models/     # Data models
  │   ├── providers/  # Data providers
  │   └── repositories/ # Repositories
  ├── domain/         # Domain layer
  │   ├── entities/   # Domain entities
  │   └── usecases/   # Domain use cases
  └── presentation/   # Presentation layer
      ├── controllers/ # Controllers for state management
      ├── views/      # UI screens
      └── widgets/    # Reusable UI components
```

## Future Enhancements

- Real integration with Speech-to-Text APIs (Google Cloud, OpenAI Whisper)
- Real integration with Text Summarization APIs (GPT-4, BART)
- Multi-language support
- Export options (PDF, Word, etc.)
- Cloud synchronization

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- GetX library for simplifying state management
- All third-party packages used in this project
