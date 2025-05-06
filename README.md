
# 🛍️ Belanjain

Belanjain is a modern e-commerce web application designed to provide users with a smooth and intuitive online shopping experience. Built with scalable technologies, it supports product browsing, searching, cart management, checkout, and user account functionalities.


#✨ Features
- 🛒 Browse and search for products by category or name

- 👤 User registration, login, and profile management

- 🛍️ Add to cart, update quantity, and remove items

- 📈 Admin dashboard for managing products and users

## Soon
- 💳 Secure checkout and order summary

- 📦 Order history and order details for users

# ⚙️ Tech Stack

- Flutter 
- Firebase Firestore
- Cloudinary

# 🚀 Getting Started
1️⃣ Requirements
- Flutter SDK (version 3.x recommended)

- Firebase account

- Android Studio / VSCode

- Dart

## Installation

```bash
 https://github.com/aryarobyy/Belanjain-2
 cd Belanjain-2
 flutter pub get
```

## 🔥 Firebase Setup Guide
### Step 1: Create Firebase Project
1. Go to Firebase Console

2. Click Add project, and follow the steps (no need to enable Google Analytics if not needed)

### Step 2: Add Android APP
1. Inside your Firebase project dashboard, click Add App > Android
2. Enter: 
    -  Package name (e.g. com.yourname.belanjain)

    - (Optional) App nickname

    - (Optional) SHA-1 key (needed for Google sign-in)

3. Download the google-services.json file
4. Place it in:

```bash
android/app/google-services.json

```

### Step 3: Enable Firebase services
In Firebase Console, enable:

    - Authentication → enable Email/Password sign-in

    - Cloud Firestore → create database in test mode

    - Firebase Storage

### Step 4: 
```bash
flutter run
```

