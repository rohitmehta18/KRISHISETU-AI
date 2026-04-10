# 🌾 KrishiSetu AI - Smart IoT Farming Application

> **Empowering Farmers with Real-Time IoT Monitoring & AI-Driven Insights**

A comprehensive IoT-powered agricultural application that bridges the gap between traditional farming and modern technology. KrishiSetu AI provides real-time crop monitoring, weather forecasting, pest detection, and AI-powered advisory systems to help farmers maximize yields and optimize resources.

---

## 📋 Table of Contents

- [✨ Features](#-features)
- [🏗️ Architecture](#️-architecture)
- [💻 Tech Stack](#-tech-stack)
- [📱 Screenshots](#-screenshots)
- [🚀 Getting Started](#-getting-started)
- [📦 Building APK](#-building-apk)
- [🌐 Deployment](#-deployment)
- [📁 Project Structure](#-project-structure)
- [🔌 API Endpoints](#-api-endpoints)
- [📊 Database Schema](#-database-schema)
- [🛠️ Development](#️-development)
- [📞 Support](#-support)

---

## ✨ Features

### 🔐 **Authentication & User Management**
- Secure JWT-based authentication
- User registration with farmer profile
- Password management & account security
- Session management with persistent login
- Role-based access control

### 📊 **Real-Time Monitoring**
- **Sensor Integration**: Live data from ESP32 IoT devices
  - Temperature & Humidity tracking
  - Soil moisture percentage
  - Light intensity (LDR sensor)
  - pH level monitoring
  - Water level detection
  - Relay control for irrigation

### 🌤️ **Weather Intelligence**
- Region-based weather forecasting
- Real-time weather updates
- Rainfall predictions
- Temperature trends
- Historical weather data

### 🚜 **Crop Management**
- Crop type selection & tracking
- Crop-specific recommendations
- Variety management
- Yield tracking
- Crop cycle monitoring

### 🐛 **Health & Pest Detection**
- AI-powered crop health scoring
- Disease detection algorithms
- Pest identification
- Automated health alerts
- Treatment recommendations

### 💊 **Pest & Pesticide Management**
- Pesticide database with guidelines
- Application safety information
- Weather-based spray recommendations
- Residue period tracking
- Organic alternatives

### 📋 **Insurance & Schemes**
- Farmer insurance scheme information
- Government subsidy tracking
- Scheme eligibility checker
- Documentation support

### 🎯 **Dashboard & Analytics**
- Comprehensive analytics dashboard
- Real-time statistics
- Historical data visualization
- Performance metrics

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    KrishiSetu AI                        │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────────┐         ┌──────────────────┐     │
│  │  Flutter Web/App │         │   Android APK    │     │
│  │   (UI Layer)     │◄───────►│   (Mobile)       │     │
│  └────────┬─────────┘         └──────────────────┘     │
│           │                                             │
│           │ HTTPS/HTTP                                 │
│           ▼                                             │
│  ┌─────────────────────────────────────────────────┐   │
│  │     Express.js Backend (Render)                 │   │
│  │  ┌─────────────────────────────────────────┐   │   │
│  │  │ - Auth Routes                           │   │   │
│  │  │ - Sensor Routes (ESP32 Integration)     │   │   │
│  │  │ - Weather Service                       │   │   │
│  │  │ - Crop Management                       │   │   │
│  │  │ - Health Detection                      │   │   │
│  │  │ - Insurance & Schemes                   │   │   │
│  │  └─────────────────────────────────────────┘   │   │
│  └────────┬────────────────────────┬──────────────┘   │
│           │                        │                   │
│  ┌────────▼────────┐     ┌────────▼──────────┐        │
│  │  MongoDB Atlas  │     │  ESP32 IoT Device │        │
│  │  (Cloud DB)     │     │  (WiFi: 192.168  │        │
│  │                 │     │   .4.1)           │        │
│  └─────────────────┘     └───────────────────┘        │
│                                                         │
│  External APIs:                                       │
│  - Google Gemini AI (Health Detection)                │
│  - Weather API Service                                │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 💻 Tech Stack

### **Frontend**
| Component | Technology |
|-----------|-----------|
| Language | Dart |
| Framework | Flutter (v3.11.4+) |
| State Management | StatefulWidget |
| HTTP Client | http package |
| Fonts | Google Fonts |
| Icons | Material Icons, Cupertino Icons |

### **Backend**
| Component | Technology |
|-----------|-----------|
| Runtime | Node.js |
| Framework | Express.js (v4.18.3) |
| Database | MongoDB Atlas |
| Authentication | JWT (jsonwebtoken) |
| Password Hashing | bcryptjs |
| HTTP Client | axios |
| CORS | @koa/cors |
| Environment | dotenv |

### **IoT Hardware**
| Component | Details |
|-----------|---------|
| Microcontroller | ESP32 |
| WiFi | 192.168.4.1 |
| Sensors | Temperature, Humidity, Soil Moisture, pH, Light |
| Network Protocol | HTTP REST API |

### **Cloud & Deployment**
| Service | Usage |
|---------|-------|
| Render | Backend Hosting |
| MongoDB Atlas | Database (Cloud) |
| GitHub | Version Control |
| Google Gemini AI | AI Advisory |

---

## 🚀 Getting Started

### **Prerequisites**
- ✅ Flutter SDK (v3.11.4+)
- ✅ Node.js (v16+)
- ✅ MongoDB Atlas Account
- ✅ Android SDK (for APK builds)
- ✅ Git
- ✅ Render account (for deployment)

### **Installation**

#### **1. Clone the Repository**
```bash
git clone <repository-url>
cd krishi_app
```

#### **2. Setup Flutter Frontend**
```bash
# Get dependencies
flutter pub get

# Check devices
flutter devices

# Run development app
flutter run
```

#### **3. Setup Node.js Backend**
```bash
cd krishi_backend

# Install dependencies
npm install

# Configure environment
cp .env.example .env
# Edit .env with your MongoDB credentials and settings

# Start development server
npm run dev

# Or production
npm start
```

#### **4. Configure Environment Variables**

**Backend (.env file)**
```bash
# MongoDB Configuration
MONGO_URI=mongodb+srv://username:password@cluster.mongodb.net/krishiDB

# Server
PORT=3000
NODE_ENV=development

# JWT
JWT_SECRET=your_secret_key_here

# ESP32 WiFi
ESP_BASE_URL=http://192.168.4.1
TIMEOUT_MS=5000
```

**Frontend (lib/services/auth_service.dart)**
```dart
String get _baseUrl => 'https://setu-backend-jixd.onrender.com';
```

---

## 📦 Building APK

### **Step 1: Clean Build**
```bash
cd krishi_app
flutter clean
flutter pub get
```

### **Step 2: Set Android SDK Path**
```powershell
# Windows
$env:ANDROID_HOME = "C:\Users\$env:USERNAME\AppData\Local\Android\sdk"

# Or set permanently in Environment Variables
```

### **Step 3: Build APK**
```bash
flutter build apk --release
```

### **Step 4: Output Location**
```
krishi_app/build/app/outputs/flutter-apk/app-release.apk
```

### **Step 5: Install on Device**
```bash
# Via USB
adb install build/app/outputs/flutter-apk/app-release.apk

# Or transfer .apk file manually to phone and tap to install
```

---

## 🌐 Deployment

### **Backend Deployment (Render)**

1. **Push Code to GitHub**
```bash
cd krishi_backend
git add -A
git commit -m "Deploy production build"
git push origin main
```

2. **Enable MongoDB IP Whitelist**
   - Go to MongoDB Atlas → Network Access
   - Add IP: `0.0.0.0/0` (or specific Render IP)

3. **Deploy on Render**
   - Create new Web Service
   - Connect GitHub repo
   - Set environment variables:
     - `MONGO_URI`: Your MongoDB connection string
     - `NODE_ENV`: production
   - Build: `npm install`
   - Start: `npm start`

4. **Monitor Deployment**
   - Render Dashboard → Logs
   - Should see: `✅ Server running on port 3000`

### **Frontend Distribution**

- **Web**: Deploy Flutter Web to hosting (Vercel, Netlify)
- **Android**: Distribute APK via:
  - Google Play Store
  - Firebase App Distribution
  - Direct APK sharing

---

## 📁 Project Structure

```
krishi_app/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── screens/
│   │   ├── login_screen.dart     # Login & Authentication
│   │   ├── signup_screen.dart    # New user registration
│   │   ├── home_screen.dart      # Main dashboard
│   │   ├── dashboard_screen.dart # Analytics dashboard
│   │   ├── profile_screen.dart   # User profile management
│   │   ├── alerts_screen.dart    # Notifications & alerts
│   │   ├── schemes_screen.dart   # Insurance & subsidies
│   │   └── change_password_screen.dart
│   ├── services/
│   │   ├── auth_service.dart     # Authentication API calls
│   │   ├── sensor_service.dart   # ESP32 sensor data
│   │   ├── weather_service.dart  # Weather API integration
│   │   ├── crop_service.dart     # Crop management
│   │   ├── crop_health_service.dart # Health detection
│   │   ├── gemini_service.dart   # AI advisory (Google Gemini)
│   │   └── session.dart          # Session management
│   ├── widgets/
│   │   ├── crop_health_card.dart # Health metrics UI
│   │   └── [other UI components]
│   └── theme/
│       └── app_colors.dart       # Color scheme
├── android/
│   ├── app/build.gradle.kts      # Android build config
│   └── src/
├── ios/                          # iOS configuration
├── web/                          # Web version
├── pubspec.yaml                  # Dependencies
├── analysis_options.yaml         # Lint rules
└── README.md                     # This file

krishi_backend/
├── src/
│   ├── server.js                 # Express server setup
│   ├── config/
│   │   ├── db.js                 # MongoDB connection
│   │   └── esp.config.js         # ESP32 configuration
│   ├── models/
│   │   └── user.model.js         # User schema
│   ├── routes/
│   │   ├── auth.routes.js        # Auth endpoints
│   │   ├── sensor.routes.js      # Sensor endpoints
│   │   ├── weather.routes.js     # Weather endpoints
│   │   ├── crop*.routes.js       # Crop endpoints
│   │   ├── health.routes.js      # Health endpoints
│   │   └── insurance.routes.js   # Insurance endpoints
│   ├── services/
│   │   └── esp.service.js        # ESP32 communication
│   └── middleware/
├── package.json                  # Dependencies
├── .env                          # Environment variables
├── .env.example                  # Template
└── README.md
```

---

## 🔌 API Endpoints

### **Authentication**
```
POST   /api/auth/signup          Register new user
POST   /api/auth/login           User login
GET    /api/user/profile         Get user profile
PUT    /api/user/change-password Change password
```

### **Sensors & IoT**
```
GET    /api/data                 Fetch sensor data from ESP32
GET    /api/on                   Turn relay ON
GET    /api/off                  Turn relay OFF
```

### **Weather**
```
GET    /api/weather?region=XXX   Get weather for region
```

### **Crops**
```
GET    /api/crops                Get all crops
POST   /api/crops                Add new crop
GET    /api/crops/:id            Get crop details
```

### **Health & Pest**
```
GET    /api/health               Get crop health status
POST   /api/health               Record health check
GET    /api/pesticides           Get pesticide recommendations
```

### **Insurance**
```
GET    /api/insurance            Get available schemes
GET    /api/insurance/:id        Get scheme details
```

---

## 📊 Database Schema

### **User Collection**
```javascript
{
  _id: ObjectId,
  email: String (unique),
  password: String (hashed),
  name: String,
  age: Number,
  region: String,
  farmerType: String,        // Small, Medium, Large
  landSize: Number,          // acres
  farmingType: String,       // Organic, Traditional, Mixed
  crops: [String],
  waterSource: String,
  irrigationType: String,
  usesPesticides: Boolean,
  language: String,
  createdAt: Date,
  updatedAt: Date
}
```

---

## 🛠️ Development

### **Running in Development Mode**

**Frontend**
```bash
cd krishi_app
flutter run -d chrome    # Web
flutter run              # Mobile/Emulator
```

**Backend**
```bash
cd krishi_backend
npm run dev              # With auto-reload
```

### **Testing Locally**
1. Start backend: `npm run dev`
2. Update `auth_service.dart`:
   ```dart
   String get _baseUrl => 'http://localhost:3000';
   ```
3. Run Flutter app: `flutter run`

### **Debug Mode**
```bash
flutter run --debug
```

### **Hot Reload**
```
Press 'r' in terminal to reload
Press 'R' for full restart
```

---

## 📞 Support

### **Common Issues**

| Issue | Solution |
|-------|----------|
| MongoDB connection error | Whitelist IP in MongoDB Atlas (0.0.0.0/0) |
| CORS errors | Backend CORS already configured |
| ESP32 not found | Ensure ESP32 on same WiFi, IP: 192.168.4.1 |
| APK build fails | Enable Developer Mode, set ANDROID_HOME |
| Flutter not found | Add Flutter to PATH environment |

### **Useful Commands**

```bash
# Flutter
flutter doctor              # Check environment setup
flutter clean              # Clean build files
flutter pub get            # Get dependencies
flutter upgrade            # Update Flutter SDK

# Node.js Backend
npm install                # Install dependencies
npm start                  # Start server
npm run dev                # Development with nodemon
npm audit                  # Security check

# Git
git status                 # Check changes
git add -A                 # Stage changes
git commit -m "message"    # Commit
git push origin main       # Push to remote
```

---

## 📄 License

This project is developed as part of **SEM 4 - KrishiSetu AI (IoTian)** academic project.

---

## 👥 Team & Credits

**Developed with ❤️ for farmers**

- IoT Integration & Hardware Setup
- Mobile App Development (Flutter)
- Backend API Development (Node.js)
- AI/ML Integration (Google Gemini)
- Weather & Database Integration

---

## 🚀 Future Roadmap

- [ ] Multilingual support expansion
- [ ] Advanced ML models for crop prediction
- [ ] Offline mode support
- [ ] Blockchain-based farmer records
- [ ] Video tutorial integration
- [ ] Export analytics to PDF
- [ ] SMS notifications
- [ ] WhatsApp bot integration

---

**Last Updated**: April 2026
**Version**: 1.0.0
**Status**: ✅ Production Ready

---

Made with 🌾 for sustainable farming

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
