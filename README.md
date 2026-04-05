# 🏠 Smart Home App

A Flutter-based smart home control and monitoring application built as part of the **ENCS5200 Graduation Project** at Birzeit University.

---

## 📱 Features

### Navigation
The app has 5 main tabs:
- **My Homes** — Browse and control all your homes
- **Monitor** — Live view of all devices and their current energy usage
- **Schedulers** — View and manage all device schedules
- **Reports** — Usage reports per device with time filters
- **Settings** — Edit names, toggle theme, switch language, logout

### Device Control
- Toggle devices ON/OFF with animated switches
- Each toggle is logged with a timestamp for usage tracking
- Devices support 4 types: Light, Plug, Fan, AC

### Scheduling
- Set start/end time for any device
- Select repeat days (S M T W T F S)
- Cancel schedules from the Schedulers tab or from the device card (⋮)

### Reports
- Filter by device and time period (Today / Last 7 Days / Last 30 Days / All Time)
- Shows: Hours ON, Total Toggles, Turned ON count, Turned OFF count

### Language Support
- Full **English / Arabic** support
- RTL layout automatically applied when Arabic is selected

### Data
- Structure loaded from `assets/data.json` on startup
- State (ON/OFF, schedules, usage logs) saved locally via SharedPreferences
- Every action is sent as a JSON file to a local Python server (`server.py`)

---

## 🗂️ Project Structure

```
smart_home/
├── assets/
│   ├── data.json          # Homes, rooms, devices structure
│   └── schedules.json     # Initial schedules
├── lib/
│   ├── l10n/
│   │   └── app_strings.dart   # English & Arabic translations
│   ├── models/
│   │   ├── device.dart        # Device, DeviceSchedule, UsageEvent
│   │   ├── room.dart
│   │   └── home.dart
│   ├── providers/
│   │   └── home_provider.dart # State management
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── main_shell.dart    # Bottom navigation
│   │   ├── homes_screen.dart
│   │   ├── home_screen.dart
│   │   ├── room_screen.dart
│   │   ├── monitor_screen.dart
│   │   ├── schedulers_screen.dart
│   │   ├── reports_screen.dart
│   │   └── settings_screen.dart
│   ├── services/
│   │   └── db_service.dart    # Sends JSON to local server
│   ├── main.dart
│   └── theme.dart
└── pubspec.yaml
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Python 3 (for the local database server)

### Run the App

```bash
cd smart_home
flutter pub get
flutter run -d chrome       # Web
flutter run                 # Android/iOS
```

### Run the Database Server

Place `server.py` inside your `to database` folder, then:

```bash
cd "to database"
python server.py
```

The server runs on `http://localhost:8080` and saves every action as a JSON file in the same folder.

---

## 📦 Dependencies

| Package | Purpose |
|--------|---------|
| `provider` | State management |
| `shared_preferences` | Local state persistence |
| `uuid` | Unique IDs for homes/rooms/devices |
| `http` | Send JSON to local server |

---

## 🔧 Configuration

### Adding Homes / Rooms / Devices
Edit `assets/data.json` directly. Each home has an `id`, `name`, `icon`, and a list of `rooms`. Each room has devices with a `type` index:

| Index | Type |
|-------|------|
| 0 | Light |
| 1 | Plug |
| 2 | Fan |
| 3 | AC |

### Adding Initial Schedules
Edit `assets/schedules.json`. IDs must match those in `data.json`.

---

## 👨‍💻 Team

| Name |
|------|
| Khader Issa |
| Adam Al-Zahem |
| Saad Rimawi |

**Supervisor:** Dr. Ahmad Afaneh  
**University:** Birzeit University  
**Course:** ENCS5200 — Graduation Project
