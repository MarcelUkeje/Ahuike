# Ahuike Mobile

Ahuike is a Flutter hospital appointment booking application for a fictitious hospital.

## Project status

The project is in its foundation stage. The current build includes:

- A branded Material 3 design system
- Original Ahuike launcher artwork for Android and iOS
- Offline Basil SVG icons and reusable Rive/Lottie animation components
- A responsive four-tab application shell
- Food discovery home screen
- Restaurant summary models and repository abstraction
- Seeded development restaurant data
- Search, order history, and profile foundations
- Loading, error, empty, and pull-to-refresh states
- Environment-based API configuration
- An initial widget test
- Android and iOS project shells

Checkout, authentication, persistent carts, payments, and live order tracking are planned next.

## Product experience

The customer journey is designed around these steps:

1. Choose a delivery address.
2. Discover or search for a restaurant.
3. Browse the menu and customize food items.
4. Review the cart and delivery fees.
5. Select an address and payment method.
6. Place the order.
7. Follow preparation and delivery status.
8. Reorder, review, or contact support afterward.

The primary navigation contains Home, Search, Orders, and Profile. The cart will be exposed as a persistent contextual action with an item-count badge.

## Design system

Ahuike uses a friendly, high-contrast visual language:

| Token | Value | Use |
| --- | --- | --- |
| Primary | `#FF3355` | Main actions, active navigation, cart badges |
| Primary light | `#FF5A76` | Gradients and secondary brand emphasis |
| Background | `#F4F4F4` | App canvas |
| Surface | `#FFFFFF` | Cards, fields, and navigation |
| Success | `#10B981` | Open restaurants and successful orders |
| Warning | `#F59E0B` | Ratings, delays, and promotions |
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
│   ├── cart/              # Cart state and future cart UI
│   ├── home/              # Discovery data and presentation
│   ├── orders/            # Active and previous orders
│   ├── profile/           # Customer account and preferences
│   └── search/            # Dish and restaurant discovery
├── shared/
│   ├── models/            # Cross-feature domain models
│   └── widgets/           # Reusable UI components
└── main.dart              # Bootstrap and MaterialApp
```

The current `MockHomeRepository` provides deterministic development data. It will be replaced behind the same interface by an HTTP repository connected to the backend.

## Requirements

- Flutter 3.x with Dart 3.7 or newer
- Android Studio or Xcode for platform builds
- Android emulator/device or iOS simulator/device
- A running Ahuike backend for API-connected features

Verify the toolchain with:

```bash
flutter doctor
```