# Zwesta Trading System - Flutter App

A comprehensive Flutter application for the Zwesta Trading System with login, dashboard, trades management, and account management features.

## Features

### 1. **Login & Authentication**
- User login and registration
- Session management with local storage
- Demo credentials for testing (username: `demo`, password: `demo123`)
- Secure password handling

### 2. **Dashboard Screen**
- Portfolio overview with key metrics
- Quick statistics cards (Balance, Total Profit, Open Trades, Win Rate)
- Recent trades display with links to detailed views
- Primary account information visualization
- Margin usage monitoring
- Welcome message and logout option

### 3. **Trades Screen**
- View all trades with filtering options (All, Open, Closed)
- Open new trades with custom parameters
- Close existing trades with closing price
- Trade details modal with complete trade information
- Real-time profit/loss calculation
- Support for Buy/Sell positions
- Take Profit and Stop Loss management

### 4. **Account Management**
- **Profile Tab**: Edit user information (names, email)
- **Accounts Tab**: 
  - View all trading accounts
  - Account balance and margin information
  - Margin usage percentage tracking
  - Account status monitoring
  - High margin warnings
- **Settings Tab**:
  - Change password
  - Two-Factor Authentication toggle
  - Notification preferences
  - Dark mode toggle
  - Account deletion option
  - App information

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── screens/                           # Screen components
│   ├── login_screen.dart             # Authentication UI
│   ├── dashboard_screen.dart         # Main dashboard
│   ├── trades_screen.dart            # Trading management
│   ├── account_management_screen.dart # Account settings
│   └── index.dart                    # Exports
├── models/                            # Data models
│   ├── user.dart                     # User model
│   ├── trade.dart                    # Trade model
│   ├── account.dart                  # Account model
│   └── index.dart                    # Exports
├── services/                          # Business logic
│   ├── auth_service.dart             # Authentication service
│   ├── trading_service.dart          # Trading operations
│   └── index.dart                    # Exports
├── widgets/                           # Reusable components
│   ├── custom_widgets.dart           # Custom UI widgets
│   └── index.dart                    # Exports
└── utils/                             # Utilities
    ├── constants.dart                # App constants & colors
    ├── theme.dart                    # Theme configuration
    └── index.dart                    # Exports
```

## Models

### User Model
- User ID, username, email
- First and last names
- Profile image URL
- Account type (Standard, Premium, etc.)

### Trade Model
- Symbol (e.g., EUR/USD)
- Trade type (Buy/Sell)
- Quantity, entry price, current price
- Take Profit and Stop Loss levels
- Status (Open, Closed, Pending)
- Profit/Loss calculation with percentage

### Account Model
- Account number and ID
- Balance and margin information
- Currency and leverage ratio
- Status tracking
- Creation date

## Services

### AuthService (Provider)
- User login and registration
- Session management
- Profile updates
- Password changes
- Local storage integration

### TradingService (Provider)
- Trade fetch and management
- Account information
- Open and close trades
- Trade updates
- Portfolio calculations
- Mock data initialization

## UI Components

- **StatCard**: Display key statistics
- **TradeCard**: Show individual trade summary
- **LoadingOverlay**: Loading indicator overlay
- **CustomAppBar**: Branded app bar
- **ErrorBanner**: Error message display
- **SuccessBanner**: Success message display

## Color Scheme

- **Primary**: #1E88E5 (Blue)
- **Secondary**: #FF6B6B (Red)
- **Success**: #4CAF50 (Green)
- **Warning**: #FFC107 (Yellow)
- **Danger**: #F44336 (Red)

## State Management

The app uses **Provider** for state management:
- `AuthService`: Manages authentication state
- `TradingService`: Manages trading and account data
- MultiProvider setup in main.dart

## Getting Started

### Prerequisites
- Flutter SDK (version 3.0.0 or higher)
- Dart SDK

### Installation

1. Navigate to the project directory:
```bash
cd "Zwesta Flutter App"
```

2. Get dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Demo Credentials
- **Username**: demo
- **Password**: demo123

## Features in Detail

### Authentication Flow
1. User lands on Login Screen
2. Can switch between Login and Register modes
3. Credentials are validated and stored locally
4. AuthWrapper redirects to Dashboard or Login based on auth state

### Dashboard Features
- Welcome message with user's first name
- Logout button with confirmation dialog
- Real-time portfolio metrics
- Quick access to recent trades
- Account overview with all trades
- Refresh functionality via pull-to-refresh

### Trading Features
- Create new trades with all parameters
- View trade details with full information
- Close positions with real-time profit calculations
- Filter trades by status
- Track entry price, current price, and profit percentage
- Support for Take Profit and Stop Loss orders

### Account Management
- Profile editing with form validation
- Password change with confirmation
- View all trading accounts
- Monitor margin usage
- Account settings and preferences
- Security features

## Dependencies

- **provider**: State management
- **shared_preferences**: Local data storage
- **http**: API calls (for future integration)
- **intl**: Date and time formatting
- **fl_chart**: Chart components
- **shimmer**: Loading effects
- **go_router**: Navigation (for future use)

## Customization

### Change API Endpoint
Update `AppConstants.apiBaseUrl` in `lib/utils/constants.dart`:
```dart
static const String apiBaseUrl = 'YOUR_API_URL';
```

### Modify Colors
Update color values in `lib/utils/constants.dart`:
```dart
static const Color primaryColor = Color(0xFFYOURCOLOR);
```

### Change Mock Data
Edit `_initializeMockData()` method in `lib/services/trading_service.dart`

## Future Enhancements

- Real API integration
- WebSocket for live price updates
- Advanced charting with candlestick data
- Notifications for trade alerts
- Export trade history
- Multi-language support
- Biometric authentication
- Trading robots/automation
- Advanced analytics and reports

## Testing

The app comes with mock data for demo purposes. All functionality works without a backend server.

## License

© 2024 Zwesta Trading System. All rights reserved.

## Support

For issues or questions, please contact support@zwesta-trading.com
