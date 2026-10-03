# CarePass Admin Dashboard

Flutter web dashboard for CarePass administration. Uses Firebase Authentication, Firestore, Cloud Functions and Storage. Feature state uses flutter_bloc and dependencies are registered with GetIt.

## Development

Use Flutter with Dart 3.11 or newer, compatible with pubspec.lock.

```sh
flutter pub get
flutter run -d chrome
dart analyze lib test
flutter test
flutter build web --release
```

Firebase configuration is in lib/firebase_options.dart and .firebaserc. Access requires an existing active administrator profile; the app does not bootstrap a Super Admin on sign-in.

## Source layout

```text
lib/
  core/
    constants/  di/  router/  services/  theme/  utils/
    widgets/
      shared/                  # Individual shared components
  features/<feature>/
    data/datasources/          # Firebase operations
    data/models/               # Serialization
    data/repositories/         # Repository implementations
    domain/entities/          # Application models
    domain/repositories/      # Contracts
    domain/usecases/          # Operations
    presentation/bloc/        # BLoC, events and states
    presentation/pages/       # Page composition
    presentation/widgets/     # Reusable and page-specific widgets
test/                         # Unit, widget and fake-Firestore regressions
docs/                         # Review and integration notes
```

Page-specific Dart parts intentionally share their page's private namespace. Import the page or BLoC entry point, not a part file. Existing public imports remain valid.

The dashboard shares backend infrastructure with ../carepass. This project contains hosting configuration, not its own separate authorization backend. Read [the review](docs/refactor-review.md) and [pending backend fixes](docs/shared-backend-follow-up.md) before release. Tests using fake Firestore do not verify live security rules or push delivery.
