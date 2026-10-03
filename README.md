<h1 align="center">CarePass Admin Dashboard</h1>
<p align="center"><strong>Manage the network behind quality care for less.</strong></p>
<p align="center">A Flutter web dashboard for healthcare providers, services, memberships, payments, and customer support.</p>
<p align="center">Flutter Web · Dart · Firebase · BLoC</p>

---

CarePass Admin Dashboard is the administration interface for the [CarePass member app](https://github.com/fadymilad2/carepass). It gives authorized staff a central place to maintain the provider catalog, manage membership plans, review payments, and publish content for app users.

The dashboard and member app share Firebase infrastructure. Changes to shared catalog records are reflected in the member app when it reloads the data.

## Features

| Module | Capabilities |
| --- | --- |
| Overview | Membership and payment summaries with charts and reporting. |
| Users | Search customer records, inspect profiles, and access account management tools. |
| Providers | Maintain provider details, multiple categories, locations, opening hours, discounts, images, and active status. |
| Services | Link offerings to providers, organize categories, set discounts and availability, and upload or preview service images. |
| Membership plans | Maintain subscription plans and their configuration. |
| Payments | Search and filter payment history and export reports to CSV. |
| Discount codes | Manage promotional codes, validity, and usage settings. |
| Banners | Create promotional content and upload images for the member app. |
| Notifications | Send notifications and review notification history. |
| Administrators | Manage administrator profiles, role presets, and stored permissions. |
| Settings | Maintain app branding, content, and health-check allowance settings. |

These are dashboard workflows; successful operations also depend on the deployed backend permissions and available Cloud Functions. See [shared backend integration notes](docs/shared-backend-follow-up.md) for documented authorization gaps.

## Providers with multiple services

Create **one provider record per location** and select every applicable category, such as **Clinic**, **Pharmacy**, and **Laboratory**.

1. Open **Providers** and add or edit the facility.
2. Under **Provider categories**, select all categories it offers.
3. Save its shared address, contact information, and other details.
4. Open **Services** and link each offering to that same provider.

Each service can have its own category, discount, description, image, and availability. A medical complex does not need a separate provider record for every department.

The provider form warns about matching names and addresses. The service picker groups matching choices and preserves the linked provider when editing an existing service. These UI behaviors do not automatically merge or delete database records.

## Technology

| Layer | Tools |
| --- | --- |
| Interface | Flutter Web, Material widgets, Google Fonts, `fl_chart`, `data_table_2` |
| State management | `flutter_bloc` and `equatable` |
| Navigation | `go_router` |
| Dependency injection | `get_it` |
| Authentication | Firebase Authentication with email/password sign-in |
| Data | Cloud Firestore |
| Backend operations | Firebase Cloud Functions |
| Images | Firebase Storage, image picker, cached network images |
| Reports | CSV export and browser APIs |
| Tests | Flutter Test and `fake_cloud_firestore` |
| Hosting | Firebase Hosting with single-page app routing |

## Getting started

### Requirements

- Flutter with Dart `>=3.11.0 <4.0.0`, compatible with [pubspec.yaml](pubspec.yaml) and the lockfile.
- Chrome for local web development.
- Firebase CLI and FlutterFire CLI for configuring a Firebase environment.
- Access to the intended Firebase project and an active administrator account.

### 1. Install dependencies

Run from the dashboard project directory:

```sh
flutter pub get
```

### 2. Configure the environment

Firebase settings are stored in [lib/firebase_options.dart](lib/firebase_options.dart), [.firebaserc](.firebaserc), and [firebase.json](firebase.json). The checked-in configuration targets the original CarePass project.

For a separate development environment, select your own project and generate its web configuration:

```sh
firebase login
firebase use --add
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID --platforms=web
```

The environment needs Firebase Authentication, Firestore, Storage, and the corresponding shared backend functions and rules. Use a dedicated development environment when testing catalog changes or account management.

### 3. Configure administrator access

Sign-in uses Firebase Authentication email/password accounts. The authenticated UID must also have an existing, active document at `admin_users/{uid}`. Provision initial access through the project's trusted administration process.

The dashboard checks the administrator record on the server and signs out accounts without active access. It does not create a Super Admin automatically when someone signs in.

The supported role presets are **Super Admin**, **Support**, **Marketer**, and **Custom**. Existing accounts use their stored permission grants. For the current fields and permission names, see the [administrator model](lib/features/auth/data/models/admin_model.dart) and [role definitions](lib/features/admin_users/domain/entities/admin_user_entity.dart).

Navigation and UI permission checks support the user experience; authorization must also be enforced by Firestore rules and Cloud Functions.

### 4. Start the dashboard

```sh
flutter run -d chrome
```

Sign in with your configured administrator account. The sections available to that account depend on its stored permissions.

## Shared backend

This project contains the dashboard frontend and its Hosting configuration. The shared Cloud Functions and Firestore rules are maintained in the [CarePass app repository](https://github.com/fadymilad2/carepass), conventionally checked out alongside this project as `../carepass`.

The two clients share records for providers, services, users, membership plans, payments, promotional content, and application settings. Image uploads use Firebase Storage. Payment processing and other trusted operations belong to the shared backend.

Review [shared-backend-follow-up.md](docs/shared-backend-follow-up.md) before deploying changes to administrator permissions or member data access. It records known source-level mismatches; it is not a live audit of the currently deployed backend.

Keep integration secrets in backend configuration. The dashboard should not contain payment gateway secrets or service-account credentials.

## Project structure

```text
lib/
  main.dart                     Firebase initialization and app startup
  firebase_options.dart         Firebase platform configuration
  core/
    constants/                  Shared names and values
    di/                         Dependency registration
    router/                     Routes and access-aware navigation
    services/                   Administrator session services
    theme/                      Dashboard colors and typography
    utils/                      Reporting and other shared helpers
    widgets/                    Dashboard shell and reusable components
  features/
    admin_users/                Administrator accounts and permissions
    auth/                       Email/password login
    banners/                    Promotional banners
    discount_codes/             Promotional codes
    notifications/              Notification tools and history
    overview/                   Metrics and charts
    payments/                   Payment reporting
    plans/                      Membership plans
    providers/                  Healthcare provider catalog
    services/                   Provider service offerings
    settings/                   Application settings
    users/                      Customer records
test/                           Unit, widget, and fake-Firestore tests
docs/                           Review and integration notes
web/                            Web entry point and app assets
firebase.json                   Firebase Hosting configuration
```

Features use three layers: `data` for Firebase operations and serialization, `domain` for entities and use cases, and `presentation` for BLoCs, pages, and widgets.

Page-specific widgets and BLoC event/state files may use Dart `part` directives. Import their owning page or BLoC entry point rather than a part file directly.

## Verification

```sh
flutter analyze
flutter test
flutter build web --release
```

Tests cover reporting, notification handling, provider categories, and regression cases. Fake-Firestore tests do not verify deployed security rules, actual image uploads, or push delivery. Check those integrations against the intended development backend as well.

## Build and deploy

Create the web build:

```sh
flutter build web --release
```

Output is written to `build/web`. [firebase.json](firebase.json) serves this directory and rewrites application routes to `index.html`.

To publish an approved build to your selected Hosting project:

```sh
firebase deploy --only hosting --project=YOUR_FIREBASE_PROJECT_ID
```

This command deploys Hosting only. Shared Cloud Functions, Firestore rules, and Storage permissions have their own deployment workflows.

## Troubleshooting

| Problem | What to check |
| --- | --- |
| Login succeeds but access is rejected | The Authentication UID must match an active `admin_users` document. |
| A dashboard section is missing | Check the account's stored permissions. |
| An operation returns `permission-denied` | Check the deployed backend rules and the documented shared backend requirements. |
| An image upload fails | Check Storage configuration, authorization, and network access. |
| A browser refresh returns a route error | Confirm the Hosting rewrite to `index.html` is deployed. |
| Development changes affect live app content | Confirm both clients' Firebase project configuration before editing shared data. |

## Further reading

- [Refactor review](docs/refactor-review.md)
- [Shared backend follow-up](docs/shared-backend-follow-up.md)
- [CarePass member app](https://github.com/fadymilad2/carepass)
