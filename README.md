# Book Tracker

A Flutter app for tracking your reading list with Google Books API integration.

## Features

- 📚 Search for books using Google Books API
- 📖 Add books to your personal reading list
- 💾 Local storage with Drift database
- 🖼️ Book cover images
- 🔍 Real-time search

## Setup

### 1. Get Google Books API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable Google Books API
4. Create credentials → API Key
5. Restrict the key to Google Books API only

### 2. Environment Configuration

1. Copy the environment template:
   ```bash
   cp .env.example .env
   ```

2. Add your API key to `.env`:
   ```
   GOOGLE_BOOKS_API_KEY=your_actual_api_key_here
   ```

### 3. Run the App

```bash
flutter pub get
flutter run
```

## Security

- ✅ `.env` file is gitignored (never committed)
- ✅ API key is restricted to Google Books API only
- ✅ Template file (`.env.example`) is safe to commit

## Architecture

- **Clean Architecture** with domain, data, and presentation layers
- **Repository Pattern** for data access
- **Provider** for state management
- **Drift** for local database
- **Dio** for HTTP requests
