# Shared backend changes requiring approval

Status: proposed scope only; shared backend changes were not retained or deployed.

The dashboard and member app use the same Firebase project, `carepass-b0220`, and default Standard Firestore database. The relevant shared source is in `D:/work/carepass`, outside this dashboard folder. The local rules were reviewed; deployed rules were not downloaded or assumed to match them.

| Workflow | Current local backend mismatch | Proposed change after approval |
| --- | --- | --- |
| Admin account creation, role changes, disabling and removal | `admin_users` permits reads but no dashboard writes | Add a trusted administrator-management path with explicit authority, schema validation, and protection against self-escalation/removing one's own access. Prefer server-managed Authentication lifecycle. |
| User profile/status edits and subscription extensions | Other users' profiles cannot be updated by admins | Permit only authorized user-management operations and only the supported profile/status/expiry fields; keep receipts, plan activation and quota fields protected. |
| Notification sending and history cleanup | Per-user notification creation and notification_history writes/deletes are not allowed | Add permission-checked send/history operations with bounded payload validation. |
| Payment and overview reporting | The dashboard queries the payments collection group; the rules have only the nested user-specific match | Add an explicit collection-group read rule for authorized reporting admins, keeping receipt writes server-only and member isolation intact. |
| Provider types, locations, service categories | Admins can read these collections but cannot maintain them | Add collection-specific management permissions and validation. |
| Read-only/custom administrator roles | Catalog writes and push callables currently check active-admin status rather than individual permissions | Align server authorization with stored permissions and trusted super-admin authority. UI routing alone is not an authorization boundary. |

Affected shared source would include `firestore.rules`, `functions/src/access.js`, `functions/src/notifications.js`, and emulator tests. A change must preserve the member app's existing guest catalog reads and prevent member entitlement changes or admin self-provisioning.

Required validation: emulator tests for permitted/denied admin roles, inactive admins, customer isolation, admin creation/update bypasses, receipt collection-group reads, bounded notification writes, and all existing member rules tests. Backend changes should remain local until separately deployed through the normal release process.

Automatic approval review rejected this broader change because it alters shared authorization and member-data access beyond the explicitly authorized dashboard refactor. Approval is required before applying it. Leaving it unchanged means the affected dashboard workflows may still receive permission-denied errors if these local rules are deployed; the production configuration has not been tested here.
