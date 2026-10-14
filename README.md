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
- Persistent sessions and protected routes
- Preference questionnaire stored in Supabase user metadata
- Server-side Google Places discovery agent
- White and pastel green visual design

## Technology

| Technology | Purpose |
| --- | --- |
| Flutter | Android, iOS, and web interface |
| Dart | Application development language |
| GoRouter | Navigation between screens |
| Supabase | Authentication, database, and file storage |
| Google Places API | Live place and activity discovery |
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
│   ├── preferences_page.dart
│   └── register_page.dart
├── models/
│   ├── discovered_place.dart
│   └── user_preferences.dart
├── services/
│   ├── auth_notifier.dart
│   ├── place_discovery_service.dart
│   └── preferences_service.dart
└── widgets/
    ├── mood2go_wordmark.dart
    └── mood_surface.dart
supabase/functions/
└── discover-places/
    └── index.ts
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
- [x] Build the preference questionnaire
- [x] Build the server-side place discovery agent
- [x] Build live place discovery screen with filters and pagination
- [x] Add local preference-based recommendation ranking with reasons
- [x] Add basic place details and Google Maps link copying
- [ ] Add curated menus and activity details
- [ ] Add group creation and invitations
- [x] Implement the Jev API adapter and batched scoring
- [ ] Configure TypeSafe access and validate real Jev rankings
- [ ] Add the chatbot
- [ ] Add the sample ordering flow
- [ ] Complete testing and the final presentation

## Team

Mood2GO is being developed by a three-person student team. Responsibilities will be divided among interface development, data management, and the recommendation system.

## Status

Discovery now calls a server-side live Google Places search, limited to ten
candidates per search with no pagination. The server-side Jev adapter is ready
for TypeSafe's decision model, with batched preference scoring and visible
ranking status. Live deployment and verified account allowances are still needed.
No real Google or Jev calls were made during implementation.

## Setup and spending limits

Follow [the live discovery guide](docs/place-discovery-agent.md). Approved monthly
allowances live in Supabase with atomic reservations. Missing setup or allowance
blocks live requests. Jev remains disabled until a separate TypeSafe account,
free credits and a provider-side spending boundary are confirmed.

The older local recommendation screen and fictional catalog remain as development
fixtures; the app's recommendation route now opens live discovery. They are not
presented as real Google venues or as Jev-generated results.
