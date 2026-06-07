RingoBar — Brand Assets
========================

Selected icon: A · Cream & Red  (cream ground, red apple)

CONTENTS
  AppIcon.appiconset/       Drop-in app icon — 13 PNGs + Contents.json
  AccentColor.colorset/     App-wide accent (apple red #D4322A, dark #E2473B)
  FocusRed.colorset/        Focus / running state   #D4322A
  BreakGreen.colorset/      Break state             #3F9D4F
  PauseGray.colorset/       Paused state            #8A8A8E
  RingoBar-Icon-A-1024.png  Quick 1024 preview

HOW TO USE (Xcode)
  1. Drag AppIcon.appiconset into your Assets.xcassets, replacing the
     empty AppIcon.
  2. Drag AccentColor.colorset (and the state colorsets if you want them)
     into Assets.xcassets too.
  3. The icon set already covers: iOS 1024 (light / dark / tinted) and the
     full macOS ladder 16 -> 1024 @1x/@2x. Contents.json is wired up.

PALETTE  (SwiftUI)
  Accent / Focus  Color(red: 0.831, green: 0.196, blue: 0.165)   #D4322A
  Break           Color(red: 0.247, green: 0.616, blue: 0.310)   #3F9D4F
  Pause           Color(red: 0.541, green: 0.541, blue: 0.557)   #8A8A8E
  Cream surface   #F4EFE7      Warm ink  #1A1413

  Prefer Color("AccentColor"), Color("BreakGreen"), etc. so dark-mode
  variants resolve automatically.
