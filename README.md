# Honkai Star Retail

A mobile hybrid application for buying galactic resources and light cones.

## Tech Stack
- **Frontend**: Flutter SDK 3.32.2
- **Backend**: Node.js 22.16.0 + Express
- **Database**: MySQL (via XAMPP 8.2.12)
- **IDE**: Android Studio Meerkat Feature Drop 2024.3.2 Patch 1
- **Android SDK**: API 35

## Project Structure
```
HSR-cl2/
├── backend/
│   ├── server.js        # Express API server
│   ├── package.json     # Node.js dependencies
│   └── database.sql     # MySQL setup script
├── frontend/
│   └── lib/
│       ├── main.dart              # App entry + theme
│       ├── session.dart           # Session storage
│       └── pages/
│           ├── login_page.dart    # Page 1: Login
│           ├── register_page.dart # Page 2: Register
│           ├── home_page.dart     # Page 3: Home/Catalog
│           ├── detail_page.dart   # Page 4: Item Detail
│           └── admin_page.dart    # Page 5: Admin Manage
└── README.md
```

## Setup Instructions

### 1. Database Setup (XAMPP)
1. Start XAMPP → Start **Apache** and **MySQL**
2. Open **phpMyAdmin** (http://localhost/phpmyadmin)
3. Click **Import** → Choose `backend/database.sql` → Click **Go**
4. This creates the `honkai_star_retail` database with sample data

### 2. Backend Setup
```bash
cd backend
npm install
node server.js
```
Server runs on `http://localhost:3000`

### 3. Frontend Setup
```bash
cd frontend
flutter pub get
flutter run
```

### 4. Google Sign-In Setup (for External OAuth)
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a project → Add Android app with package `com.hsr.honkai_star_retail`
3. Add your SHA-1 fingerprint (run `keytool -list -v -keystore ~/.android/debug.keystore`)
4. Download `google-services.json` → place in `frontend/android/app/`
5. Enable Google Sign-In in Firebase Authentication

## Test Accounts
| Email | Password | Role |
|-------|----------|------|
| admin@hsr.com | admin123 | Admin |
| user@hsr.com | user123 | User |

## Requirements Checklist

### 5 Pages 
1. Login Page - Standard login + Google OAuth
2. Register Page - Create new account
3. Home/Catalog Page - Browse all resources
4. Item Detail Page - View details + buy items
5. Admin Manage Page - CRUD operations for resources

### 5 UI Components 
1. **Text** - Used for labels, titles, prices
2. **TextField** - Email, password, quantity inputs
3. **ElevatedButton** - Login, Register, Buy buttons
4. **ListView** - Resource catalog list on Home and Admin pages
5. **Image** - Resource images via Image.network()

### 3 Data Validations 
1. **Login**: Check if email or password is empty → shows error message
2. **Admin Create/Edit**: Price must be a number greater than 0 → shows error message
3. **Buy Item**: Quantity must be greater than 0 → shows error message

### Theme Customizations (4 properties) 
1. **colorScheme** - Purple primary (#7B61FF) and Gold secondary (#FFB74D)
2. **scaffoldBackgroundColor** - Dark background (#13131F)
3. **fontFamily** - Changed to "Segoe UI"
4. **appBarTheme** - Custom AppBar with dark surface color, white text, centered title

### API Routes 
| Method | Route | Auth | Description |
|--------|-------|------|-------------|
| GET | /resources | No | Get all resources |
| GET | /resources/:id | No | Get single resource |
| POST | /auth/login | No | Standard login |
| POST | /auth/register | No | Register user |
| POST | /auth/google | No | Google OAuth login |
| POST | /resources | Token | Create resource (admin) |
| PUT | /resources/:id | Token | Update resource (admin) |
| DELETE | /resources/:id | Token | Delete resource (admin) |
| POST | /resources/:id/buy | Token | Buy resource |

### Authentication 
- **Standard Login**: Login with email/password stored in MySQL database
- **External OAuth**: Google Sign-In integration
- **Bearer Token**: 40-character alphanumeric token generated on login
- **Token Verification**: Required for all admin operations (create, update, delete)

### CRUD Operations 
- **Create**: Admin adds new resource (POST /resources)
- **Retrieve**: View all resources (GET /resources), view single (GET /resources/:id)
- **Update**: Admin edits resource (PUT /resources/:id)
- **Delete**: Admin deletes resource (DELETE /resources/:id)
