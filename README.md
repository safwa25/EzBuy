_Last updated: 2026-01-01_

Welcome to EzBuy — Flutter e‑commerce app built as a DEPI graduation project. Whether you’re browsing, buying, or building features, this README walks you through everything in an accessible.


## ✨ Features (What EzBuy Can Do)
- 🔐 User authentication: signup, login, token refresh
- 🛒 Product browsing: categories, pagination, search
- 📦 Product details: images, variants, reviews
- 🧺 Persistent cart: survives app restarts
- 💳 Checkout flow: shipping, addresses, payments
- 🧾 Order history & tracking
- 🙋 Profile & address management
- 🔔 Push notifications for order updates (FCM)
- 🌐 Offline-friendly reads + queued writes for sync
- 🛠️ Optional admin features for product/order management

Short version: a full shopping app with the developer-friendly structure to extend, test, and ship. 🚀

---


## 📱 App Tour — What the user sees
- Splash → Auth check → Home screen with product categories
- Product list & search with lazy loading
- Product details: zoomable images, reviews, variants
- Add-to-cart, change quantities, persistent cart badge
- Smooth checkout: address selection, shipping, payment
- Order confirmation & order history
- Push notifications take you straight to the order details

It's designed to be pleasant, familiar, and snappy — like window shopping with a nice latte. ☕️

---

## 🧩 Modules (Who does what — quick cheat sheet)

Auth
- Login/Signup, token storage, profile
- Key: AuthRepository, AuthBloc/Cubit, flutter_secure_storage

Products
- List, search, product details
- Key: ProductRepository, ProductBloc, ProductDTOs

Cart
- Add/remove, quantities, persistent local state
- Key: CartRepository, CartCubit, CartLocalDataSource

Checkout & Payments
- Shipping, addresses, payment intent, place order
- Key: CheckoutBloc, PaymentService (Stripe/other SDK)

Orders
- Order history, details, status updates
- Key: OrdersRepository, OrdersScreen

Profile & Settings
- Update profile & addresses

Shared components
- ProductCard, RatingWidget, QuantitySelector, AppTheme

---


## 🔐 Authentication & Security (Firebase)

EzBuy uses **Firebase Authentication** to provide a secure and flexible user authentication system.

### Supported Authentication Methods
- **Email & Password Authentication**
  - Users can sign up and log in using email and password.
- **Google Sign-In**
  - Users can authenticate quickly using their Google account.

### Password Reset & Update Options

EzBuy supports **two password management flows**:

#### 1️⃣ Password Reset via Email (Outside the App)
- Users can request a password reset from the login screen.
- Firebase sends an automatic **password reset email** to the user’s registered email (e.g., Gmail).
- The email contains a **secure Firebase link** that allows the user to set a new password outside the app.

#### 2️⃣ Password Update Inside the App
- Logged-in users can update their password from within the application.
- The user must:
  - Enter the **current (old) password**
  - Enter and confirm the **new password**
- Firebase securely validates and updates the credentials.

### Security Notes
- Authentication is fully managed by **Firebase Auth**.
- Secure tokens are used to maintain user sessions.
- Sensitive data is never stored in plain text.

---

## 🔁 Major Flows (How the app behaves)
- App start: splash → check token → home or auth
- Authentication: input → validation → API → token saved → navigate
- Browse/search: debounced queries → paginated results → product taps
- Product details: fetch or reuse cached item → show variants → add to cart
- Add to cart: local upsert, persist, update UI
- Checkout: create payment intent → on success place order → clear cart → confirmation
- Orders: fetch & cache history → details & tracking

Error handling
- Friendly messages, retry UI for recoverable errors, crash reporting for unexpected exceptions.

---

## 🔧 Setup & Local Development

Prerequisites
- Flutter SDK (stable; recommended >= 3.x)
- Dart SDK
- Android Studio / Xcode (for device builds)
- Node / json-server (optional for local mock API)

Clone
```bash
git clone https://github.com/safwa25/EzBuy.git
cd EzBuy
```


## 🛠️ Used Tech (Stack & Libraries)

EzBuy uses a practical, modern Flutter stack. These are the libraries and tools used or recommended — friendly to contributors and production-ready.

Platform & language
- Flutter — cross-platform UI toolkit
- Dart — programming language

State management
- flutter_bloc (Bloc / Cubit) — recommended


Images & media
- cached_network_image — image caching + placeholders

