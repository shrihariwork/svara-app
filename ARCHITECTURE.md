# Project Svara: Architecture Blueprint

**Mission:** A 100% free, open-source (CC-BY-NC 4.0), non-commercial Android/iOS app for cloning a user's voice and applying it to Sanskrit Shlokas.

## Directory Structure

```text
svara/
├── frontend/               # Flutter mobile application
│   ├── android/            # Android-specific build files & permissions
│   ├── ios/                # iOS-specific build files & permissions
│   ├── lib/                # Dart code
│   │   ├── main.dart
│   │   ├── screens/        # UI Screens (Calibration, Library, Playback)
│   │   └── services/       # API clients (Backend integration)
│   └── pubspec.yaml        # Flutter dependencies (record, just_audio, riverpod)
├── backend/                # Python FastAPI server
│   ├── main.py             # FastAPI entrypoint (/calibrate, /synthesize)
│   ├── requirements.txt    # Python dependencies
│   ├── vagdhenu/           # Git submodule for Vāgdhenu voice cloning AI
│   └── models/             # Directory to store user audio & synthesized outputs
└── ARCHITECTURE.md         # This documentation file
```

## Backend GPU Environment Setup

The FastAPI backend wraps the Vāgdhenu AI pipeline, which relies on PyTorch and CUDA for fast inference. 

### Server Requirements
- **OS:** Ubuntu 22.04 LTS (recommended)
- **GPU:** NVIDIA GPU with at least 16GB VRAM (e.g., T4, A10g, or RTX 3090/4090).
- **CUDA:** CUDA Toolkit 11.8+
- **Python:** 3.10+

### Setup Instructions
1. Install system dependencies:
   ```bash
   sudo apt update
   sudo apt install -y git ffmpeg
   ```
2. Setup Python environment:
   ```bash
   python3.10 -m venv venv
   source venv/bin/activate
   pip install -U pip wheel
   ```
3. Install PyTorch with CUDA support:
   ```bash
   pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
   ```
4. Install backend dependencies:
   ```bash
   pip install -r backend/requirements.txt
   ```
5. Clone the model repository (if not already fetched):
   ```bash
   git submodule update --init --recursive
   ```
6. Run the FastAPI server:
   ```bash
   cd backend
   uvicorn main:app --host 0.0.0.0 --port 8000
   ```

## Frontend Mobile App Setup

The frontend is a Flutter application.
1. Install [Flutter SDK](https://docs.flutter.dev/get-started/install).
2. Fetch dependencies:
   ```bash
   cd frontend
   flutter pub get
   ```
3. Run the app on an emulator/device:
   ```bash
   flutter run
   ```

*Note: Ensure you update the backend API URL in the Flutter code (e.g., inside `services/api_client.dart`) to point to your GPU server's IP address when testing on a physical device.*
