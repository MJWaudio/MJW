# MJW AUDIO BOX — iOS starter

This is a starter project for a native SwiftUI iPhone app. It is an early foundation, not a validated acoustic simulator.

## Included
- SwiftUI app shell
- Basic enclosure calculator for a rectangular slot port (approximate Helmholtz tuning)
- Starter screens for ported, 4th-order and 6th-order bandpass workflows
- Codemagic configuration that generates an Xcode project using XcodeGen

## Important limitations
The displayed tuning is an estimate. This starter does not yet calculate trustworthy SPL, driver-dependent bandpass response, cabin gain, compression, port losses, or real-world peak SPL. Do not use its results as final construction plans without validating the physics and measurements.

## Build
Codemagic reads `codemagic.yaml` at repository root. It installs XcodeGen, generates `MJWAudioBox.xcodeproj` from `project.yml`, and builds for iOS Simulator. App Store signing and publishing are not configured yet.
