# Dashboard review and refactor

Reviewed the hand-maintained Flutter application, tests, web bootstrap and project configuration. Generated build output, package caches, editor metadata and installed skill packages are not application source and were not refactored. This folder has no Git repository, so the original source was archived before edits.

## Structure

- Retained the existing feature/data/domain/presentation layout and public import paths.
- Split all 11 feature BLoCs into adjacent bloc, event and state files.
- Extracted 53 page-specific widgets into each feature's presentation/widgets/<page>/ folder. Stateful widgets remain with their State class.
- Split shared widgets and the confirmation dialog into core/widgets/shared, retaining shared_widgets.dart as their public entry point.
- Added DashboardFeatureScope to dispose feature caches when the verified admin session ends, and a shared sequential event transformer to keep feature reads/mutations in order.
- Formatted the source and replaced deprecated Flutter APIs. Raised the declared Dart minimum to match the installed dependency/toolchain requirements.

## Bugs fixed

- Custom-role administrators can sign in. Missing/inactive admin records remain rejected. The admin list displays stored permissions instead of silently replacing them with preset defaults; unknown roles no longer become Support.
- AdminSession permissions are immutable to callers; permission checks require a loaded valid session. Auth/profile listeners are disposed and sign-out failures are handled.
- Prevented the dashboard from modifying its own administrator access. Failed admin creation attempts roll back the newly created Authentication login when the profile write fails; cleanup failures are reported explicitly.
- User search/filter/repeated actions work after a successful update, including email search. Status changes and their notification records use an atomic batch.
- Entity equality includes displayed fields, so refreshed names, expiry dates and other edits trigger updates. Feature event ordering prevents slow old reads from replacing newer operations.
- Provider toggles preserve latitude/longitude. Edit forms validate coordinate pairs, rating and discount; clearing both coordinates removes a saved location.
- Banner reordering now writes to Firestore and reloads saved order. New plans/banners reload server-assigned order before later edits.
- Discount edits preserve server-updated usage counters and redemption lists. Invalid plan prices/durations and discount values cannot silently become free/default values.
- Plans and administrators missing optional sort fields are included in lists. User plan filters use real plans, include inactive plans and handle duplicate names.
- Clearing notification history processes every batch instead of silently stopping at 500 records.
- Added mounted checks around asynchronous form/image loads and blocked settings saves during initial loading/uploading.
- Updated web page and installed-app metadata.

## Validation

- Dart analysis: no issues.
- Flutter tests: 34 passed, including 14 new regression cases.
- Release web build: succeeded (build/web). CSV downloads now use package:web with dart:js_interop instead of universal_html. The release build reports "Wasm dry run succeeded"; a full Wasm browser runtime test has not been performed. Flutter also reported an optional Cupertino font warning; the release completed successfully.
- Fake Firestore tests verify application behavior, not deployed Firebase authorization. No production writes, notifications, deployments or account creation were performed during verification.

## Pending shared-backend work

See [shared-backend-follow-up.md](shared-backend-follow-up.md). The existing shared backend has authorization mismatches that cannot be fixed solely by this dashboard refactor. Automatic approval review rejected the broader backend change. Its partial local rules write was restored; shared backend behavior remains unchanged.

## Manual verification

After the shared-backend work is approved and tested, verify authenticated admin workflows with Super Admin and limited-permission accounts, including uploads, account provisioning, user subscription changes and push delivery. The current test suite does not replace those integration checks.

## Source backup and change inventory

Original source: `.refactor-backups/source-20260930-153730.zip`.

Application files changed: 113. New application/test files: 89. Most changed files include formatting as well as the specific changes above.


