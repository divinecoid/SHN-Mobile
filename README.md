# SHN Mobile - Inventory Management System

A Flutter mobile application for inventory management with a modern, intuitive dashboard and secure login system.

## Features

### 🔐 Authentication System
- Secure login page with username/password authentication
- Session management using SharedPreferences
- Auto-login functionality
- Logout capability

### 📊 Interactive Dashboard
- **Welcome Section**: Personalized greeting with user information
- **Quick Stats Cards**: 
  - Total Items in inventory
  - Low stock alerts
  - Monthly incoming/outgoing items
- **Bar Chart**: Monthly activity visualization showing items in/out
- **Donut Chart**: Category distribution across inventory
- **Recent Activities List**: Real-time activity feed with timestamps
- **Low Stock Alerts**: Items that need restocking with percentage indicators

### 🎨 Modern UI/UX
- Dark theme with blue accent colors
- Responsive design for mobile devices
- Smooth animations and transitions
- Intuitive navigation
- Beautiful gradient backgrounds

## Demo Credentials

- **Username**: `admin`
- **Password**: `admin`

## Getting Started

### Prerequisites
- Flutter SDK (3.7.2 or higher)
- Dart SDK
- Android Studio / VS Code

### Installation

1. Clone the repository
2. Navigate to the project directory
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application:
   ```bash
   flutter run
   ```

## Dependencies

- `flutter`: Core Flutter framework
- `fl_chart`: For creating beautiful charts (bar chart, donut chart)
- `shared_preferences`: For local data persistence and session management
- `cupertino_icons`: iOS-style icons

## Project Structure

```
lib/
├── main.dart                 # App entry point with authentication wrapper
├── pages/
│   ├── page_login.dart       # Login page with form validation
│   ├── page_dashboard.dart   # Main dashboard with charts and data
│   ├── page_home.dart        # Original home page
│   ├── page_mutasi_barang.dart
│   ├── page_stock_opname.dart
│   └── page_terima_barang.dart
└── controllers/
    └── home_controller.dart
```

## Features in Detail

### Dashboard Components

1. **Statistics Cards**
   - Real-time inventory metrics
   - Color-coded indicators for different statuses
   - Icon-based visual representation

2. **Monthly Activity Chart**
   - Bar chart showing incoming vs outgoing items
   - Monthly trends visualization
   - Interactive data points

3. **Category Distribution**
   - Donut chart showing inventory by category
   - Percentage-based visualization
   - Color-coded categories

4. **Activity Feed**
   - Recent inventory movements
   - Time-stamped entries
   - Type indicators (In/Out)

5. **Low Stock Alerts**
   - Items below minimum threshold
   - Percentage-based stock levels
   - Priority indicators

## Authentication Flow

1. App starts and checks for existing login session
2. If not logged in, shows login page
3. User enters credentials (admin/admin)
4. Upon successful login, redirects to dashboard
5. Session is saved locally for auto-login
6. Logout clears session and returns to login

## Future Enhancements

- [ ] Add more chart types (line charts, area charts)
- [ ] Implement real-time data synchronization
- [ ] Add barcode scanning functionality
- [ ] Export data to PDF/Excel
- [ ] Push notifications for low stock alerts
- [ ] Multi-user support with role-based access

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License. 
