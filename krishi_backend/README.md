# 🚀 KrishiSetu Backend API

> **Node.js/Express REST API for Smart Farming IoT Platform**

A robust Express.js backend server that serves as the middleware between Flutter mobile clients, MongoDB database, and ESP32 IoT devices. Handles authentication, real-time sensor data, weather information, crop management, and AI-powered agricultural advisory.

---

## 📋 Quick Navigation

- [🏗️ Architecture](#-architecture)
- [⚙️ Installation](#️-installation)
- [🚀 Running the Server](#-running-the-server)
- [📡 API Endpoints](#-api-endpoints)
- [🔐 Authentication](#-authentication)
- [🌐 Deployment](#-deployment)
- [🛠️ Development](#️-development)
- [🐛 Troubleshooting](#-troubleshooting)

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────┐
│      KrishiSetu Backend (Express.js)            │
├─────────────────────────────────────────────────┤
│                                                 │
│  CORS Middleware ◄─── Request from Flutter App │
│         │                                       │
│         ▼                                       │
│  ┌──────────────────────────────────────────┐  │
│  │  Route Handlers                          │  │
│  │  ├── /api/auth (JWT Authentication)     │  │
│  │  ├── /api/user (Profile Management)     │  │
│  │  ├── /api/data (Sensor Integration)     │  │
│  │  ├── /api/weather (Weather Service)     │  │
│  │  ├── /api/crops (Crop Management)       │  │
│  │  ├── /api/health (Health Detection)     │  │
│  │  ├── /api/pesticides (Pest Management)  │  │
│  │  └── /api/insurance (Schemes & Subsidy) │  │
│  └──────────────────────────────────────────┘  │
│         │                                       │
│    ┌────┴─────────────────────┬────────────┐   │
│    ▼                          ▼            ▼   │
│  MongoDB               ESP32 Device    External│
│  (User Data,           (WiFi:          APIs   │
│   Sensors,            192.168.4.1)    (Gemini,│
│   Analytics)                          Weather)│
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## ⚙️ Installation

### **Prerequisites**
- ✅ Node.js v16 or higher
- ✅ npm or yarn package manager
- ✅ MongoDB Atlas account
- ✅ Git
- ✅ Postman (optional, for API testing)

### **Step 1: Clone Repository**
```bash
git clone <repository-url>
cd krishi_backend
```

### **Step 2: Install Dependencies**
```bash
npm install
```

This installs:
```json
{
  "express": "^4.18.3",          // Web framework
  "mongoose": "^9.4.1",          // MongoDB ODM
  "bcryptjs": "^3.0.3",          // Password hashing
  "jsonwebtoken": "^9.0.3",      // JWT auth
  "cors": "^2.8.5",              // CORS handling
  "axios": "^1.6.8",             // HTTP requests
  "dotenv": "^16.0.3"            // Environment variables
}
```

### **Step 3: Configure Environment**
```bash
# Copy example file
cp .env.example .env

# Edit .env with your credentials
nano .env
```

**Required Settings:**
```env
# MongoDB
MONGO_URI=mongodb+srv://username:password@cluster.mongodb.net/krishiDB

# Server
PORT=3000
NODE_ENV=development

# Security
JWT_SECRET=your_super_secret_key_here

# ESP32 IoT
ESP_BASE_URL=http://192.168.4.1
TIMEOUT_MS=5000
```

---

## 🚀 Running the Server

### **Development Mode** (with auto-reload)
```bash
npm run dev
```

Expected output:
```
✅ Server running on port 3000
📝 Environment: development
✅ MongoDB connected successfully
```

### **Production Mode**
```bash
npm start
```

### **Health Check**
```bash
curl http://localhost:3000/
```

Response:
```json
{
  "status": "Krishi backend running",
  "version": "1.0.0"
}
```

---

## 📡 API Endpoints

### **🔐 Authentication Routes** (`/api/auth`)

#### **Register New User**
```bash
POST /api/auth/signup

Content-Type: application/json

{
  "email": "farmer@example.com",
  "password": "secure_password",
  "name": "Rajesh Kumar",
  "age": 45,
  "region": "Maharashtra",
  "farmerType": "Medium",
  "landSize": 5.5,
  "farmingType": "Organic",
  "crops": ["Rice", "Wheat"],
  "waterSource": "Borewell",
  "irrigationType": "Drip",
  "usesPesticides": false,
  "language": "hi"
}
```

**Response (201):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "507f1f77bcf86cd799439011",
    "name": "Rajesh Kumar",
    "email": "farmer@example.com"
  }
}
```

#### **Login**
```bash
POST /api/auth/login
Content-Type: application/json

{
  "email": "farmer@example.com",
  "password": "secure_password"
}
```

**Response (200):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "507f1f77bcf86cd799439011",
    "name": "Rajesh Kumar",
    "email": "farmer@example.com"
  }
}
```

---

### **👤 User Routes** (`/api/user`)

#### **Get Profile**
```bash
GET /api/user/profile
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "id": "507f1f77bcf86cd799439011",
  "email": "farmer@example.com",
  "name": "Rajesh Kumar",
  "age": 45,
  "region": "Maharashtra",
  "farmerType": "Medium",
  "landSize": 5.5,
  "farmingType": "Organic",
  "crops": ["Rice", "Wheat"],
  "waterSource": "Borewell",
  "irrigationType": "Drip",
  "usesPesticides": false,
  "language": "hi"
}
```

#### **Change Password**
```bash
PUT /api/user/change-password
Authorization: Bearer <token>
Content-Type: application/json

{
  "oldPassword": "current_password",
  "newPassword": "new_password"
}
```

---

### **📊 Sensor Routes** (`/api`)

#### **Get Live Sensor Data**
```bash
GET /api/data
```

**Response (200) - ESP32 Connected:**
```json
{
  "temperature": 32.5,
  "humidity": 68,
  "soilPercent": 54,
  "ldrRaw": 2048,
  "ph": 6.8,
  "waterLevel": true,
  "relay": false,
  "autoMode": true
}
```

**Response (503) - ESP32 Not Connected:**
```json
{
  "error": "Device not connected"
}
```

#### **Control Relay - Turn ON**
```bash
GET /api/on
```

#### **Control Relay - Turn OFF**
```bash
GET /api/off
```

---

### **🌤️ Weather Routes** (`/api/weather`)

#### **Get Weather Data**
```bash
GET /api/weather?region=Maharashtra
```

**Response (200):**
```json
{
  "region": "Maharashtra",
  "temperature": 32,
  "humidity": 65,
  "rainfall": 0,
  "windSpeed": 12,
  "condition": "Sunny",
  "forecast": [
    {
      "date": "2026-04-11",
      "temp": 33,
      "rainfall": 5
    }
  ]
}
```

---

### **🌾 Crops Routes** (`/api/crops`)

#### **Get All Crops**
```bash
GET /api/crops
```

#### **Add New Crop**
```bash
POST /api/crops
Content-Type: application/json

{
  "name": "Rice",
  "variety": "Basmati",
  "plantedDate": "2026-03-15",
  "expectedHarvestDate": "2026-06-15",
  "irrigationSchedule": "Every 5 days"
}
```

---

### **🏥 Health Routes** (`/api/health`)

#### **Get Crop Health Status**
```bash
GET /api/health
```

**Response (200):**
```json
{
  "healthScore": 85,
  "status": "Good",
  "issues": [],
  "recommendations": [
    "Maintain soil moisture at 50-60%",
    "Check for pests weekly"
  ],
  "lastChecked": "2026-04-10T10:30:00Z"
}
```

---

### **💊 Pesticides Routes** (`/api/pesticides`)

#### **Get Pesticide Recommendations**
```bash
GET /api/pesticides
```

---

### **📋 Insurance Routes** (`/api/insurance`)

#### **Get Available Schemes**
```bash
GET /api/insurance
```

---

## 🔐 Authentication

### **JWT Implementation**

All protected routes require JWT token in header:

```bash
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### **Token Expiry**
- **Login tokens**: 7 days
- **Refreshed on**: User login
- **Stored in**: Flutter Session

---

## 🌐 Deployment

### **Deploy to Render**

#### **Step 1: Push to GitHub**
```bash
git add -A
git commit -m "Deploy: Backend API"
git push origin main
```

#### **Step 2: Create Render Service**
1. Go to https://render.com
2. Create new **Web Service**
3. Connect GitHub repository (krishi_backend)

#### **Step 3: Configure Build Settings**
- **Name**: krishi-backend
- **Runtime**: Node
- **Build Command**: `npm install`
- **Start Command**: `npm start`

#### **Step 4: Add Environment Variables**
```
MONGO_URI=mongodb+srv://ROHIT:ROHIT@cluster0.tea3tom.mongodb.net/krishiDB
PORT=3000
NODE_ENV=production
ESP_BASE_URL=http://192.168.4.1
JWT_SECRET=your_secret_here
```

#### **Step 5: MongoDB Whitelist**
1. Go to MongoDB Atlas → Network Access
2. Add IP: `0.0.0.0/0`
3. Wait 1-2 minutes for update

#### **Step 6: Deploy**
- Click **"Deploy"** button
- Monitor logs for deployment status
- Should see: `✅ Server running on port 3000`

#### **Step 7: Get Your URL**
```
https://setu-backend-jixd.onrender.com
```

---

## 🛠️ Development

### **Project Structure**
```
src/
├── server.js                    # Express app setup
├── config/
│   ├── db.js                   # MongoDB connection
│   └── esp.config.js           # ESP32 configuration
├── models/
│   └── user.model.js           # User schema
├── routes/
│   ├── auth.routes.js          # Auth endpoints
│   ├── sensor.routes.js        # Sensor data
│   ├── weather.routes.js       # Weather API
│   ├── crop*.routes.js         # Crop management
│   ├── health.routes.js        # Health detection
│   └── insurance.routes.js     # Insurance schemes
├── services/
│   └── esp.service.js          # ESP32 HTTP client
└── middleware/
    └── [custom middleware]

.env                           # Environment variables
package.json                   # Dependencies
README.md                      # This file
```

### **Testing API Endpoints**

#### **Using cURL**
```bash
# Test health check
curl http://localhost:3000/

# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"123456"}'

# Get sensor data
curl http://localhost:3000/api/data
```

#### **Using Postman**
1. Import [Postman Collection](./postman_collection.json)
2. Set `baseUrl` to `http://localhost:3000`
3. Set `token` in Variables after login
4. Run requests

---

## 🐛 Troubleshooting

### **MongoDB Connection Error**
```
❌ MongoDB connection error: Could not connect to any servers
```

**Solution:**
- Check MongoDB URI in `.env`
- Whitelist IP in MongoDB Atlas: `0.0.0.0/0`
- Ensure credentials are correct

### **CORS Error**
```
Access to XMLHttpRequest blocked by CORS policy
```

**Solution:**
- Backend CORS already configured for all origins
- Run backend on same port or update Flutter URL

### **ESP32 Not Responding**
```
❌ Device not connected (503)
```

**Solution:**
- Ensure ESP32 is powered on
- Check WiFi connection
- Verify IP: `192.168.4.1`
- Check `ESP_BASE_URL` in `.env`

### **Port Already in Use**
```
Error: listen EADDRINUSE: address already in use :::3000
```

**Solution:**
```bash
# Kill process using port 3000
lsof -ti:3000 | xargs kill -9

# Or use different port
PORT=3001 npm start
```

---

## 📊 Environment Variables Reference

| Variable | Purpose | Example |
|----------|---------|---------|
| `MONGO_URI` | Database connection | `mongodb+srv://...` |
| `PORT` | Server port | `3000` |
| `NODE_ENV` | Environment | `production` |
| `JWT_SECRET` | Token signing key | `secret_key` |
| `ESP_BASE_URL` | ESP32 address | `http://192.168.4.1` |
| `TIMEOUT_MS` | Request timeout | `5000` |

---

## 📈 Performance Tips

1. **Sensor requests timeout quickly** (5s) to prevent app freeze
2. **MongoDB indexes** on email for faster lookups
3. **JWT tokens** expire after 7 days for security
4. **CORS** optimized to handle mobile requests

---

## 🔒 Security Best Practices

- ✅ Passwords hashed with bcrypt (10 rounds)
- ✅ JWT tokens signed with secret
- ✅ CORS restricts endpoints
- ✅ Environment variables not committed
- ✅ MongoDB credentials never exposed
- ✅ Input validation on all routes

---

## 📞 Support & Issues

| Issue | Command |
|-------|---------|
| Check Node version | `node -v` |
| Check npm version | `npm -v` |
| Reinstall dependencies | `npm install` |
| Clear cache | `npm cache clean --force` |
| See all processes | `lsof -i :3000` |

---

**Version**: 1.0.0  
**Last Updated**: April 2026  
**Status**: ✅ Production Ready

Made with 💚 for sustainable farming

## Parser

`src/utils/parser.js` uses regex to extract values from the ESP HTML page.
If your ESP outputs different labels, update the patterns there.
