# Ahuike Mobile

> **⚠️ NOTE FOR TESTING & GRADING**
> 
> Due to strict anti-spam firewalls on the free-tier backend hosting (Render), automated emails (like OTPs for registration and appointment receipts) cannot be sent out. 
> 
> **To test the registration and login flow, please enter the universal bypass OTP code: `111111`** when prompted. This will automatically verify your account and log you in.

Ahuike is a Flutter hospital appointment booking application for a fictitious Nigerian hospital.

## Project status

The project is in its foundation stage. The current build includes:

- A branded Material 3 design system
- Original Ahuike launcher artwork for Android and iOS
- Offline Basil SVG icons and reusable Rive/Lottie animation components
- A responsive four-tab application shell
- Doctor and department discovery home screen
- Doctor summary models and repository abstraction
- Seeded development doctor and department data
- Search, appointment history, and profile foundations
- Loading, error, empty, and pull-to-refresh states
- Environment-based API configuration
- An initial widget test
- Android and iOS project shells

Authentication, appointment booking, patient records, prescriptions, and real-time appointment notifications are planned next.

## Product experience

The patient journey is designed around these steps:

1. Register or sign in as a patient.
2. Discover or search for a doctor or department.
3. View the doctor's profile, specialization, and available time slots.
4. Select an appointment slot and provide a reason for the visit.
5. Review booking details and the consultation fee.
6. Confirm the appointment and receive a booking reference.
7. Attend the appointment (in-person or via teleconsultation).
8. View the post-appointment prescription and clinical notes.
9. Access appointment history, prescriptions, and medical records from the profile.

The primary navigation contains Home, Search, Appointments, and Profile. Active bookings will be exposed as a persistent contextual action with a status badge.

## Design system

Ahuike uses a friendly, high-contrast visual language:

| Token | Value | Use |
| --- | --- | --- |
| Primary | `#FF3355` | Main actions, active navigation, booking badges |
| Primary light | `#FF5A76` | Gradients and secondary brand emphasis |
| Background | `#F4F4F4` | App canvas |
| Surface | `#FFFFFF` | Cards, fields, and navigation |
| Success | `#10B981` | Available doctors and confirmed bookings |
| Warning | `#F59E0B` | Ratings, schedule alerts, and fee notices |
| Text | `#111827` | Primary content |

PP Neue Machina is bundled for distinctive headings and labels. Cards use generous radii, white surfaces, restrained shadows, and a floating pill-shaped bottom navigation.

Interface icons use the bundled Basil set by Craftwork under CC BY 4.0. The required attribution is also visible in the app's Profile screen.

Design tokens are defined in [`lib/core/theme`](lib/core/theme).

## Architecture

The app follows a feature-first structure. Screens depend on repositories and application controllers rather than talking directly to databases.

```text
lib/
├── core/
│   ├── config/            # Environment and application configuration
│   ├── navigation/        # Root shell and route ownership
│   └── theme/             # Color, spacing, typography, and component themes
├── features/
│   ├── booking/           # Appointment booking state and UI
│   ├── home/              # Doctor and department discovery
│   ├── appointments/      # Active and previous appointments
│   ├── profile/           # Patient account, records, and preferences
│   └── search/            # Doctor and department search
├── shared/
│   ├── models/            # Cross-feature domain models
│   └── widgets/           # Reusable UI components
└── main.dart              # Bootstrap and MaterialApp
```

The current `MockHomeRepository` provides deterministic development data. It will be replaced behind the same interface by an HTTP repository connected to the Ahuike backend.

## Requirements

- Flutter 3.x with Dart 3.7 or newer
- Android Studio or Xcode for platform builds
- Android emulator/device or iOS simulator/device
- A running Ahuike backend for API-connected features

Verify the toolchain with:

```bash
flutter doctor
```

## Local setup

Clone and enter the project:

```bash
git clone https://github.com/MarcelUkeje/Ahuike.git
cd Ahuike
```

Create the local environment file:

```bash
cp .env.example .env
```

Install packages and run:

```bash
flutter pub get
flutter run
```

On an Android emulator, `10.0.2.2` points to the host machine. The default environment therefore uses:

```env
API_BASE_URL=http://10.0.2.2:4000/api/v1
```

For an iOS simulator, use `http://127.0.0.1:4000/api/v1`. For a physical device, use the development machine's LAN address and ensure both devices are on the same network.

## Environment variables

| Variable | Required | Description |
| --- | --- | --- |
| `API_BASE_URL` | Yes | Versioned Ahuike backend URL |
| `APP_ENV` | Yes | `development`, `staging`, or `production` |

The `.env` file is excluded from Git. Do not place private server credentials, payment secrets, or database credentials in the mobile application. Anything bundled into a client application must be treated as public.

## Common commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Analyze Dart code
flutter analyze

# Run all tests
flutter test

# Format source and tests
dart format lib test

# Build Android artifacts
flutter build apk
flutter build appbundle

# Build iOS without signing
flutter build ios --no-codesign
```

## Backend integration contract

All application traffic should use the versioned API prefix configured by `API_BASE_URL`. The backend currently exposes:

- `GET /departments`
- `GET /departments/:departmentId`
- `GET /doctors`
- `GET /doctors/:doctorId`
- `GET /appointments`
- `GET /appointments/:appointmentId`
- `POST /appointments`

Successful responses use a data envelope:

```json
{
  "data": {}
}
```

Errors use a stable code and user-safe message:

```json
{
  "error": {
    "code": "DOCTOR_NOT_FOUND",
    "message": "Doctor not found."
  }
}
```

When authentication is introduced, the client will send a short-lived bearer access token. It will not send database credentials or trust client-calculated consultation fees.

## State management

Provider is included for application state. Controllers should remain small and feature-scoped:

- UI widgets render state and dispatch user intent.
- Controllers coordinate user-facing state.
- Repositories own API and persistence operations.
- Models represent typed domain data.

Avoid placing HTTP calls, JSON decoding, payment logic, or mutable global state directly in screens.

## Testing strategy

The test suite will grow across three levels:

- Unit tests for models, repositories, fee calculations, and controllers
- Widget tests for loading, error, empty, navigation, booking, and confirmation states
- Integration tests for authentication, appointment booking, payment callbacks, and teleconsultation launch

Run the current test suite with `flutter test`.

## Roadmap

### Foundation

- [x] Project and native platform scaffolding
- [x] Design tokens and branded application shell
- [x] Initial doctor and department discovery UI
- [x] Repository abstraction and seeded development data
- [ ] HTTP client, typed DTOs, and API error mapping

### Appointment Booking MVP

- [ ] Patient sign-up and sign-in
- [ ] Patient profile and medical history capture
- [ ] Department and doctor browsing
- [ ] Doctor profile with specialization and availability calendar
- [ ] Time slot selection and booking confirmation
- [ ] Consultation fee payment
- [ ] Appointment status tracking and push notifications
- [ ] Appointment history and rebooking

### Records and Growth

- [ ] Medical records viewer
- [ ] Prescription history
- [ ] Teleconsultation support
- [ ] Doctor ratings and reviews
- [ ] Appointment reminders and calendar export
- [ ] Referral management
- [ ] Accessibility and localization audit
- [ ] App Store and Play Store release automation

## Engineering conventions

- Keep features independent and expose narrow public interfaces.
- Prefer immutable typed models over dynamic maps.
- Keep all colors and dimensions in the theme layer.
- Include explicit loading, empty, error, and offline states.
- Keep interactive targets at least 44 logical pixels.
- Never trust client-calculated consultation fees or charges on the server.
- Add tests for every important state transition and regression.
- Run formatting, analysis, and tests before opening a pull request.

## Security

- Environment files, signing keys, and service credentials must never be committed.
- Payment confirmation must be verified by the backend using provider webhooks.
- Authentication tokens should use secure platform storage.
- Sensitive personal and medical data should be minimized and encrypted where appropriate.
- Logging must not include tokens, complete payment data, or unnecessary patient details.

## License

Copyright © 2026 Ahuike. All rights reserved unless a separate license is added.