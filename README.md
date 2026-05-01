# brrr

brrr is an open source iOS notification receiver + Cloudflare Worker webhook backend.

Default public Worker URL: **https://push.vymedia.xyz**  
Contact: **hamalainen.miska@outlook.com**

## What is brrr?

brrr is a tiny developer utility that lets your iPhone go **brrr**. Open the app, grant notification permission, register your APNs token with the Worker, then send a webhook request to trigger push notifications.

## How it works

1. iOS app asks for notification permission.
2. App registers with APNs and receives a device token.
3. App POSTs token to `POST /register` on Worker.
4. You call webhook (`POST /`, `POST /send`, or `POST /send/:deviceId`).
5. Worker generates APNs JWT (ES256), sends APNs request, and your iPhone receives push.

## Architecture (text diagram)

```text
curl / webhook client
      |
      v
Cloudflare Worker (https://push.vymedia.xyz)
  - accepts plain text or JSON payloads
  - stores token in in-memory map (non-persistent)
  - generates APNs JWT
  - forwards alert payload to APNs
      |
      v
Apple Push Notification service (APNs)
      |
      v
iPhone running brrr app
```

## iOS setup

- Open `ios/brrr.xcodeproj` in Xcode.
- Set your Team/Signing identity.
- Ensure Push Notifications capability is enabled.
- Bundle ID placeholder is `xyz.vymedia.brrr`.
- Run on a real device for APNs.

## Worker setup

```bash
cd worker
npm install
npm run deploy
```

No required environment variables for default template.

## APNs identifiers needed

Edit `worker/src/index.ts` constants:

- `APNS_TEAM_ID`
- `APNS_KEY_ID`
- `APNS_BUNDLE_ID`
- `APNS_PRIVATE_KEY`

### APNs Auth Key creation (Apple Developer)

1. Apple Developer portal → Certificates, IDs & Profiles.
2. Keys → `+` → enable APNs.
3. Download `.p8` file once.
4. Copy Team ID, Key ID, bundle identifier.
5. Paste values in Worker constants.

## Webhook usage

### Plain text

```bash
curl -X POST https://push.vymedia.xyz \
  -d 'Hello world! 🚀'
```

### JSON

```bash
curl -X POST https://push.vymedia.xyz \
  -H "Content-Type: application/json" \
  -d '{"title":"brrr","body":"Hello world! 🚀","subtitle":"optional subtitle","badge":1,"sound":"default"}'
```

## Custom Worker URL in app

Settings screen allows replacing `https://push.vymedia.xyz` so users can point to their own deployment.

## Install/runtime error fix

If you see:

`Failed to map .../Documents/Applications/.../brrr: Bad file descriptor`

this usually means the IPA was unsigned (or incorrectly signed) and iOS cannot map/launch the app binary.

Use one of these paths instead:

- Build + run directly from Xcode on your device with valid signing.
- Export a properly signed IPA (development, ad-hoc, or TestFlight/App Store).

Do **not** install unsigned IPA artifacts on-device; they are only useful for CI packaging checks.

## Build IPA with GitHub Actions

Workflow: `.github/workflows/build-ios.yml`

- Always builds unsigned simulator app for CI sanity.
- Optionally signs and exports IPA when secrets are provided:
  - `APPLE_TEAM_ID`
  - `BUILD_CERTIFICATE_BASE64`
  - `P12_PASSWORD`
  - `BUILD_PROVISION_PROFILE_BASE64`
  - `KEYCHAIN_PASSWORD`

## Limitations

- Default token store is in-memory only; Worker memory is not persistent.
- For production persistence, add KV, D1, Durable Objects, or external DB.
- APNs push delivery requires valid Apple credentials.

## Security warning

Default API is intentionally unauthenticated/public. This can be abused. For personal deployments, consider rate limits, IP allow-lists, bearer auth, Turnstile, or per-device secrets.

## Contributing

PRs welcome. Keep API simple, keep default setup env-free, and preserve the open webhook-first UX.
