# Unusual Activity Detection with Alert System

A comprehensive monitoring system that detects unusual activities, provides real-time alerts, and offers both web and mobile interfaces for seamless surveillance. This was the final year major project of our team consisting of Myself along with my amazing teammates, [Ocean Sitaula](https://github.com/oceansitaula), [Shailesh Devkota](https://github.com/dakdim), and [Suchita Kumari Sah](https://github.com/suchitasah).

## Overview

This project implements an advanced surveillance system with unusual activity detection capabilities, designed to enhance security monitoring. It uses Vision Transformers to identify potential security threats and immediately alerts users through multiple channels including a web interface, mobile application, and Telegram notifications.

The system features real-time video processing, secure OTP-based session authentication, and robust alerting mechanisms making it ideal for security-sensitive environments.

## Project Structure

```
📂 UnusualActivityDetection
 ┣ 📂 BackendAPI
 ┣ 📂 WebApplication
 ┣ 📂 MobileApplication
 ┣ 📂 ExperimentsNotebook
 ┣ 📂 TrainedNotebook
 ┗ 📜 README.md
```

### Components

- **BackendAPI**: Core server handling video processing, activity detection, and communication with front-end applications
- **WebApplication**: Browser-based interface with live camera access and surveillance dashboard
- **MobileApplication**: Flutter-based mobile client for on-the-go monitoring
- **ExperimentsNotebook**: Jupyter notebooks documenting the experimentation process
- **TrainedNotebook**: Notebooks containing model training and evaluation

## Key Features

- Real-time unusual activity detection using advanced vision Transformers.
- Multi-platform support (Web and Mobile)
- Secure OTP-based session authentication
- WebSocket and WebRTC implementation for low-latency video streaming
- Automated alert system with Telegram integration
- Comprehensive surveillance dashboard

## Setup Instructions

### 1. Backend API

```bash
# Navigate to the backend directory
cd BackendAPI
cd backend

# Set up environment variables
# Create a .env file with the following:
#   TELEGRAM_BOT_TOKEN=your_telegram_bot_token
#   TELEGRAM_CHAT_ID=your_chat_id
#   SECRET_KEY=your_django_secret_key

# Install dependencies
pip install -r requirements.txt

# Run the server
python manage.py runserver
```

### 2. Web Application

```bash
# Navigate to the web application directory
cd WebApplication

# Install dependencies
pip install -r requirements.txt

# Run the server
python manage.py runserver
```

The web application provides two main interfaces:

- **Live Camera**: Allows accessing camera feeds with secure OTP session management:
  1. User initiates a camera session
  2. System generates a unique OTP
  3. WebSocket connection is established using WebRTC for low-latency streaming
  4. OTP verification enables secure access to camera feeds on survillance page

- **Surveillance Dashboard**: Displays all connected camera feeds with:
  1. Real-time status indicators
  2. Alert notifications when unusual activities are detected
  3. Verification of OTP-authenticated sessions
  4. Integration with Telegram for instant alert delivery

### 3. Mobile Application

```bash
# Ensure the Backend API is running first

# Navigate to the mobile application directory
cd MobileApplication

# Install dependencies
flutter pub get

# Run the application
flutter run
```

The mobile application provides similar functionality to the web interface with an optimized user experience for mobile devices.

## Technical Implementation

- **Activity Detection**: Utilizes a fine tuned Vison Transformer modelto identify unusual patterns in video feeds of these classes(
1. Abuse 
2. Arrest
3. Arson
4. Assault
5. Burglary
6. Explosion
7. Fighting
8. RoadAccidents
9. Robbery
10. Shooting
11. Shoplifting
12. Stealing
13. Vandalism
)
- **Real-time Communication**: Implements WebSocket protocol for real-time alerts and WebRTC for low-latency video streaming
- **Authentication**: OTP-based session management ensures secure access to sensitive feeds
- **Alert System**: Multi-channel notification system delivering alerts through the application interface and Telegram

## Development

The development process and model experimentation are documented in the notebooks:

- **ExperimentsNotebook**: Contains data analysis, feature engineering, and algorithm selection experiments
- **TrainedNotebook**: Documents the training process, model evaluation, and optimization techniques

## Future Enhancements

- Integration with additional notification services
- Support for PTZ (Pan-Tilt-Zoom) camera controls
- Advanced filtering options for alert categorization
- Cloud-based deployment architecture

---

This project showcases advanced skills in Deep learning, Computer vision and Transformers, real-time communication protocols, secure authentication systems, and cross-platform application development.