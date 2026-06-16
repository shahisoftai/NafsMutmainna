# Cloud Synchronization (v2.1) — Future

> The optional, end-to-end-encrypted cloud sync layer. **Not in v1** — v1 is strictly local-first and offline-only. v2.1 adds opt-in sync so a user can move between phone and tablet.

---

## 1 · What v1.0 has

**No sync.** The user's data is stored only on the device. If the user uninstalls the app or breaks their phone, the data is gone.

This is **by design** for v1.0:

- **Privacy** — the user owns their emotional data, no one else.
- **Simplicity** — no server, no auth, no edge cases.
- **Trust** — the user can audit the entire codebase to verify that no data leaves the device.

## 2 · What v2.1 will add

### 2.1 Opt-in cloud sync

The user can choose to **enable sync**. When enabled:

- The 6 **user tables** are uploaded to the user's own cloud account (initially iCloud / Google Drive / Dropbox; later, a custom endpoint).
- The Knowledge and Graph tables are **not** synced — they are bundled in the app and identical on every device.
- The sync is **end-to-end encrypted** — the server cannot read the data.
- The user can **disable sync at any time**, and the cloud copy is deleted within 30 days.

### 2.2 Multi-device support

After enabling sync, the user can install Heart OS on a second device (e.g. a tablet). The second device downloads the user's data on first launch.

### 2.3 Backup & restore

A user can **export** their data as a JSON file and **import** it on a new device. This is the **manual** version of sync — it works without any server.

## 3 · What's synced, what's not

| Table | Synced? | Why |
|---|---|---|
| `attributes` | ❌ | Bundled in the app, identical everywhere. |
| `emotions` | ❌ | Same. |
| `emotion_attribute_links` | ❌ | Same. |
| `attribute_links` | ❌ | Same. |
| `domains` | ❌ | Same. |
| `domain_attribute_links` | ❌ | Same. |
| `domain_emotion_links` | ❌ | Same. |
| `nafs_states` | ❌ | Same. |
| `attribute_nafs_weights` | ❌ | Same. |
| `emotion_nafs_weights` | ❌ | Same. |
| `checkins` | ✅ | User data. |
| `detected_attributes` | ✅ | Derived from checkins; sync for consistency. |
| `interventions_history` | ✅ | User data. |
| `nafs_history` | ✅ | User data. |
| `habits` | ✅ | User data. |
| `habit_logs` | ✅ | User data. |

Only the **6 user tables** are synced. The 10 immutable tables are not.

## 4 · Sync mechanism

### 4.1 Storage backend

v2.1 supports three backends:

1. **iCloud Drive** — for iOS users.
2. **Google Drive** — for Android users.
3. **Dropbox** — for cross-platform users.

All three are **third-party** cloud storage providers. Heart OS does not run its own server.

### 4.2 Encryption

The sync payload is encrypted with **AES-256-GCM** using a key derived from the user's passphrase (via Argon2id). The encryption happens **on the device** before upload. The cloud provider sees only opaque blobs.

### 4.3 Conflict resolution

The last-write-wins strategy is used for most fields. For `checkins` and `habit_logs`, the row with the latest `Date` wins.

For `nafs_history`, the strategy is more nuanced:

- Each device computes its own daily Nafs.
- The sync layer **merges** by taking the average of the two values.
- The merged value is then re-normalised.

This avoids "ping-ponging" where a phone and tablet keep overwriting each other.

## 5 · The auth flow

Sync requires **no account**. The user provides a **passphrase** (or biometric unlock on supported devices). The passphrase derives the encryption key. Losing the passphrase means losing the cloud data — the user is warned explicitly.

There is no email, no phone number, no identity. Sync is **anonymous**.

## 6 · The "first sync" experience

```
   Settings → Enable Sync
        │
        ├── Create passphrase (or use biometric)
        │
        ├── Choose backend (iCloud / Google Drive / Dropbox)
        │
        ├── Authenticate with the backend
        │
        ├── Initial upload (~10 seconds for a year of data)
        │
        └── Done. "Sync enabled" appears in Settings.
```

The first sync uploads **all 6 user tables** as a single encrypted blob. Subsequent syncs are incremental (delta sync).

## 7 · The "second device" experience

```
   Install Heart OS on Tablet
        │
        ├── Onboarding: "Do you have existing data?"
        │
        ├── Yes → "Enter your sync passphrase"
        │
        ├── Decrypt and download (~10 seconds)
        │
        └── Done. The tablet has the user's full history.
```

The tablet is **independent** thereafter — the user can log on either device and the changes will sync to the other.

## 8 · The "disable sync" experience

```
   Settings → Disable Sync
        │
        ├── "Are you sure? Your cloud data will be deleted in 30 days."
        │
        ├── Yes → Disable locally. Mark cloud data for deletion.
        │
        └── Done. "Sync disabled" appears in Settings.
```

The 30-day grace period protects against accidental disabling.

## 9 · Why opt-in, not opt-out

Three reasons:

1. **Trust** — the user must explicitly opt in to any data leaving the device.
2. **Compliance** — GDPR, CCPA, and similar regulations require explicit consent.
3. **No surprises** — the user should never be surprised that their data is in the cloud.

## 10 · The schema impact

**Minimal.** The 6 user tables are already in the schema. For v2.1, we may add:

- `sync_metadata` — when the last sync happened, the device ID, etc.
- `sync_log` — a record of sync operations (for debugging).

These are **additive** — no existing columns change.

## 11 · Open questions (TBD)

- Should sync include the **notes** field of `checkins`? (Probably yes — it's the user's reflection. But it is the most sensitive data.)
- Should sync include the **AI reflections** (from the v2 AI layer)? (Yes, if the user opts in.)
- Should there be a **family plan** — a parent and child's data syncing to the same account? (Out of scope for v2.1.)
- Should the cloud data be **wiped automatically** if the user does not log in for 1 year? (Probably yes, with a warning at 11 months.)

## 12 · What sync means for the rest of the system

**Nothing changes for v1.0.** The local-first architecture is preserved. Sync is an **additive** layer on top.

For the AI layer (see `ai_layer.md`), sync enables the user's reflections and insights to be available across devices. The AI itself still runs **locally** — the model does not sync.

For the analytics dashboard (see `analytics.md`), sync means the analytics can be computed on any device the user logs into.

## 13 · See also

- `../00_root/roadmap.md` §4 — the v2.1 roadmap.
- `ai_layer.md` — the AI layer that may benefit from sync.
- `analytics.md` — the analytics that may benefit from sync.
- `multilingual_support.md` — how language preferences sync.
- `../04_user_tables/checkins.md` — one of the 6 synced tables.
