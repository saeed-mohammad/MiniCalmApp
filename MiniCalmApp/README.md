# MiniCalm

MiniCalm is a small meditation app built as part of the iOS Developer assignment.

## How to Run

1. Clone the repository.
2. Open the project in Xcode.
3. Use the configured Bundle Identifier and Signing Team.
4. Select an iOS 16+ simulator or device.
5. Build and run.

## Architecture

The app follows a simple MVVM architecture.

* **Library:** SwiftUI + `LibraryViewModel`
* **Player:** UIKit + XIB + `PlayerViewModel`
* **Networking:** `URLSession` with async/await
* **Audio:** `AVPlayer` and `AVAudioSession`
* **SwiftUI/UIKit:** `UIViewControllerRepresentable`

## With More Time

I would improve image caching, and further improve error handling and UI polish.

## AI Assistance

I used AI assistance to understand Swift/iOS concepts, review implementation approaches, and troubleshoot development issues. I reviewed and understood the suggestions before using them in the project.
