# Mood2GO

Mood2GO is a Flutter application that helps people discover places and activities based on their mood, interests, and preferences. Users can receive personal recommendations or create a group with friends to find an option that works for everyone.

The application is being developed as a semester project by a three-person team.

## Project goal

Mood2GO aims to give a quick, personalized answer to the questions “Where should we go?” and “What should we do?”. It collects user preferences and ranks suitable places and activities.

## Planned features

- User registration and sign-in
- User profiles and preferences
- Recommendations based on mood and interests
- Place and activity discovery
- Menus, restaurant history, and chef information
- Ingredient and allergen information
- Group creation and friend invitations
- Group recommendations based on shared preferences
- Option evaluation and ranking with Jev
- A chatbot for questions about food and places
- A sample in-app ordering flow

## Completed features

- Welcome screen
- Sign-in screen
- Registration screen
- Form validation
- Password visibility controls
- Navigation with GoRouter
- Supabase authentication
- Basic home screen and sign-out
- White and pastel green visual design

## Technology

| Technology | Purpose |
| --- | --- |
| Flutter | Android, iOS, and web interface |
| Dart | Application development language |
| GoRouter | Navigation between screens |
| Supabase | Authentication, database, and file storage |
| Jev | Planned personal and group recommendation ranking |

## Running the project

### Requirements

- Flutter SDK
- Dart SDK
- Chrome, an Android emulator, or an iOS simulator

Check your development environment:

```bash
flutter doctor
```

Install the project dependencies:

```bash
flutter pub get
```

Run the application in Chrome:

```bash
flutter run -d chrome
```

List available devices:

```bash
flutter devices
```

## Project structure

```text
lib/
├── main.dart
├── pages/
│   ├── home_page.dart
│   ├── login_page.dart
│   └── register_page.dart
└── widgets/
    └── mood2go_wordmark.dart
```

As the project grows, screens, shared components, models, and services will be organized into their own folders.

## Roadmap

- [x] Create the Flutter project
- [x] Build the welcome screen
- [x] Build the sign-in and registration screens
- [x] Add form validation
- [x] Configure GoRouter
- [x] Connect Supabase authentication
- [x] Add the first home screen
- [ ] Build the preference questionnaire
- [ ] Build discovery and recommendation screens
- [ ] Add place and activity details
- [ ] Add group creation and invitations
- [ ] Integrate Jev recommendations
- [ ] Add the chatbot
- [ ] Add the sample ordering flow
- [ ] Complete testing and the final presentation

## Team

Mood2GO is being developed by a three-person student team. Responsibilities will be divided among interface development, data management, and the recommendation system.

## Status

The project is under active development. Authentication and the first user interface flow are complete. Preference collection is the next planned feature.
