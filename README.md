# Ambience Meditation App

A Flutter application that provides calming ambient sound experiences combined with guided meditation sessions and reflection journaling. Users can browse ambience sessions, play meditation audio, and record post-session reflections.

---

# How to Run the Project

## Prerequisites

Make sure the following tools are installed:

- Flutter SDK (3.x recommended)
- Dart SDK
- Android Studio or VS Code
- Android Emulator or Physical Device

Check installation:

---

## Installation Steps

### 1. Clone the Repository
git clone <repository-url>
cd ambience_app
### 2. Install Dependencies
flutter pub get
### 3. Run the Application
flutter run
### 4. Run on Specific Device
flutter run -d android
flutter run -d windows
flutter run -d chrome

---

# Architecture Explanation

The application follows a **feature-based layered architecture** designed to separate UI, business logic, and data sources.

The architecture consists of three main layers:

UI Layer
↓
Controller Layer
↓
Repository/Data Layer

### UI Layer

Responsible for rendering screens and widgets.  
The UI only reads state and triggers actions but does not contain business logic.

### Controller Layer

Controllers manage application state and business logic.  
They act as the bridge between the UI and the data layer.

### Repository/Data Layer

Repositories provide application data such as ambience sessions and models.

This structure keeps the application **modular, maintainable, and scalable**.

---

# Folder Structure

lib/
│
├── core/
│ └── widgets/
│ └── ambience_widgets.dart
| └── formatters.dart
│
├── data/
│ └── models/
│ └── ambience.dart
| └── journal_entry.dart
| └── session_snapshot.dart
│
├── features/
│
│ ├── ambience/
│ │ ├── ambience_screen.dart
│ │ └── ambience_controller.dart
│ │
│ ├── player/
│ │ ├── player_screen.dart
│ │ └── player_controller.dart
│ │
│ └── journal/
│ ├── journal_screen.dart
│ └── journal_controller.dart
│
└── main.dart


### Folder Responsibilities

**core/**
Contains reusable widgets and shared UI components used across multiple features.

**data/**
Contains models and data structures used by the application.

**features/**
Each major functionality is organized as a feature module.

- ambience → browsing meditation sessions
- player → audio playback functionality
- journal → reflection journaling system

This structure improves **maintainability and separation of concerns**.

---

# State Management Approach

The application uses **Controller-based state management** built on Flutter's `ChangeNotifier`.

Controllers store and manage the state of the application.

Example controllers:

- `AmbienceController`
- `PlayerController`
- `JournalController`

Controllers:

- store UI state
- handle user actions
- notify UI when data changes

The UI listens to controllers using:

Whenever the controller updates its state:
notifyListeners()

the UI automatically rebuilds.

### Advantages

- lightweight
- easy to understand
- minimal boilerplate
- suitable for small and medium scale apps

---

# Data Flow

The app uses **unidirectional data flow** to keep state predictable.

Repository → Controller → UI

### Step 1: Repository Layer

Repositories provide raw data such as ambience sessions.

Example:

AmbienceRepository


Responsibilities:

- fetch ambience data
- provide model objects

---

### Step 2: Controller Layer

Controllers process data and handle logic.

Example:
AmbienceController


Responsibilities:

- search filtering
- tag filtering
- preparing UI state

Example flow:

User enters search query
↓
Controller filters ambience list
↓
Controller updates state
↓
UI rebuilds automatically

---

### Step 3: UI Layer

The UI displays data received from the controller.

Example:

AmbienceScreen


The screen listens to controller updates using:



AnimatedBuilder(
animation: ambienceController
)


When the controller updates state using `notifyListeners()`, the UI automatically rebuilds.

---

# Packages Used

## just_audio

Used for audio playback of meditation sessions.

Reasons for choosing:

- reliable audio playback
- supports looping audio
- provides detailed playback control
- works well for ambient sound applications

---

## Flutter SDK

Used as the main framework for building the application.

Advantages:

- cross-platform development
- fast UI development
- hot reload for rapid iteration
- rich widget ecosystem

---

## Dart

Programming language used by Flutter.

Advantages:

- compiled to native performance
- modern language features
- strong integration with Flutter

---

# Tradeoffs and Future Improvements

If additional development time (two more days) were available, the following improvements would be implemented.

---

## Background Audio Support

Currently audio stops when the app is closed.

Improvement:

Use background audio support so meditation continues even when the app is minimized.

Possible solution:



audio_service package


---

## Improved UI Animations

Enhance user experience with smoother transitions:

- animated gradients
- subtle motion effects
- improved hero animations

This would make the meditation experience more immersive.

---

## Better State Architecture

The controller approach works well for small applications but may become difficult to scale.

Future improvement:

Use a structured state management solution such as:

- Riverpod

This would improve dependency management and scalability.

---

## Offline Audio Downloads

Allow users to download ambience tracks for offline listening.

This would require:

- local file storage
- caching system
- download manager

---

# Summary

This project demonstrates:

- clean feature-based architecture
- modular folder organization
- reactive UI updates
- ambient audio playback
- simple but effective state management

The design prioritizes **simplicity, modularity, and maintainability**, making the codebase easy to understand and extend.

