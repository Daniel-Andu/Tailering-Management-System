# Flutter Tailoring Management System

A complete cross-platform business management application for tailoring shops, built with Flutter.

[![Flutter Version](https://img.shields.io/badge/Flutter-3.44.8-blue.svg)](https://flutter.dev/)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Windows%20%7C%20macOS%20%7C%20Linux%20%7C%20Web-lightgrey.svg)](https://flutter.dev/multi-platform)
[![License System](https://img.shields.io/badge/License-30%20Day%20Trial-green.svg)](#license-system)

## ✨ Features

### 🏪 **Complete Business Management**
- **Customer Management** - Add, edit, and track customer information
- **Order Management** - Full order lifecycle from creation to delivery  
- **Measurement System** - Cloth-type specific measurement templates
- **Payment Tracking** - Multiple payment methods with balance tracking
- **Inventory Management** - Stock tracking for fabrics and materials
- **Staff Management** - Employee roles and task assignments
- **Appointment Scheduling** - Calendar management for fittings and deliveries
- **Financial Reports** - Revenue analysis and business metrics
- **Dashboard Analytics** - Real-time business overview

### 🌍 **Cross-Platform & Offline**
- **Multi-Platform** - Android, iOS, Windows, Mac, Linux, Web
- **Offline-First** - No internet connection required
- **Bilingual Support** - English and Amharic localization
- **Material Design 3** - Modern, intuitive user interface

### 🔐 **Business Features**
- **30-Day Trial** - Automatic trial activation
- **License System** - Secure offline activation
- **SQLite Database** - Local data storage with migrations
- **Receipt Generation** - Printable customer receipts
- **Data Security** - Encrypted license storage

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Android Studio (for Android development)
- VS Code (recommended)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Tailering-Management-System
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Building for Distribution

**Android APK:**
```bash
scripts/build_release_apk.bat
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**Windows Desktop:**
```bash
flutter build windows --release
# Output: build/windows/runner/Release/
```

## 📁 Project Structure

```
Tailering-Management-System/
├── 📱 lib/                     # Flutter application source
│   ├── 🎯 app/                 # App configuration and shell
│   ├── 🔧 core/                # Core functionality and database
│   ├── 🏗️  features/           # Business feature modules
│   ├── 📊 models/              # Data models  
│   ├── 🔄 providers/           # State management
│   ├── 🎨 screens/             # UI screens
│   ├── 🛠️  utils/              # Utilities and helpers
│   └── 🌐 l10n/               # Localization files
├── 🤖 android/                 # Android configuration
├── 🖼️  assets/                 # Images, fonts, resources
├── 📜 scripts/                 # Build and automation scripts
├── 📚 docs/                    # Technical documentation
├── 🔧 tools/                   # Development tools
└── 🧪 test/                    # Tests
```

## 🛠️ Technical Stack

- **Frontend:** Flutter 3.44.8, Dart 3.12.2
- **UI:** Material Design 3, Impeller rendering (Vulkan)
- **Database:** SQLite with migrations
- **State Management:** Provider pattern (19+ providers)
- **Architecture:** Feature-first clean architecture
- **Platforms:** Android, iOS, Windows, macOS, Linux, Web

## 🏗️ Architecture

### Feature-First Structure
Each business domain is organized as a self-contained module:
- Dashboard, Customers, Orders, Payments
- Appointments, Inventory, Staff, Reports
- Each feature has its own providers, screens, and data models

### State Management
- **Provider Pattern** - Reactive state management
- **Repository Pattern** - Clean data layer separation  
- **MVVM Architecture** - Clear presentation layer

## 💼 Business Model

### Target Market
- Tailoring shops and alteration businesses
- Custom garment manufacturers
- Small to medium tailoring enterprises

### Pricing Strategy
- **Free Trial:** 30 days full access
- **License:** $150-300 per installation
- **Distribution:** Direct APK/EXE delivery

### Revenue Potential
- 50 customers: $9,950/year
- 100 customers: $19,900/year  
- 200+ customers: $39,800+/year

## 🔐 License System

The application includes a secure offline license system:
- **30-day trial** automatically activated on first launch
- **License key format:** `TAILOR-XXXX-XXXX-XXXX`
- **Device binding** with unique device ID generation
- **Offline validation** - no server required

## 📖 Documentation

- [Flutter Setup Guide](docs/FLUTTER_SETUP_GUIDE.md) - Development environment setup
- [Build Release Guide](docs/BUILD_RELEASE.md) - Production build instructions
- [Scripts Documentation](scripts/README.md) - Build and automation scripts

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📞 Support

For technical support or business inquiries:
- **Flutter Issues:** [Flutter Documentation](https://flutter.dev/docs)
- **Stack Overflow:** [Flutter Community](https://stackoverflow.com/questions/tagged/flutter)

## 🆚 Migration from JavaFX

This Flutter application replaces the previous JavaFX desktop version:

| Feature | JavaFX (Old) | Flutter (New) |
|---------|--------------|---------------|
| Platforms | Windows only | Android, iOS, Windows, Mac, Linux, Web |
| Java Required | Yes | No |
| Installation | Complex | Simple APK/EXE |
| Mobile Support | No | Native mobile apps |
| Modern UI | Basic | Material Design 3 |
| Distribution | File download | App stores or direct |

## 📄 License

This project is proprietary software for tailoring business management.

---

**Built with ❤️ using Flutter for the tailoring industry**
