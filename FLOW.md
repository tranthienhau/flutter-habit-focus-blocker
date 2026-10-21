# Regenerating screenshots and demo GIFs

## Screenshots (iOS simulator)

```sh
xcrun simctl boot "iPhone 17 Pro"
flutter pub get
flutter drive --driver test_driver/integration_test.dart \
  --target integration_test/screenshot_test.dart -d "iPhone 17 Pro"
```

`integration_test/screenshot_test.dart` pumps the real `AnchorApp` with cleared preferences and
walks onboarding (goals, Screen Time permission, Sign in with Apple, trial), then Today, habit
detail, the add-habit sheet, a focus session (it jumps the timer forward through
`focusProvider.notifier.skip` so the live and complete screens show realistic times), Blocks, the
schedule editor, the shield preview, Insights and Profile, and finally the empty states (it clears
the habits and blocks providers). It uses fixed `pump(Duration)` steps rather than
`pumpAndSettle` because the focus timer ticks every second. Each
`binding.takeScreenshot('NN-name')` is written to `screenshots/NN-name.png` by
`test_driver/integration_test.dart` (`integrationDriver(onScreenshot:)`).

Screenshots are then downscaled to 603px wide and compressed with
`pngquant --quality 75-92`.

## iOS demo GIF

```sh
xcrun simctl io booted recordVideo --codec h264 --force /tmp/ios.mp4 &
flutter drive --driver test_driver/integration_test.dart \
  --target integration_test/screenshot_test.dart -d "iPhone 17 Pro"
kill -INT %1
ffmpeg -ss 26 -to 80 -i /tmp/ios.mp4 -vf "setpts=PTS/1.8" -an /tmp/ios_cut.mp4
ffmpeg -y -i /tmp/ios_cut.mp4 -vf "fps=12,scale=300:-1:flags=lanczos,palettegen=stats_mode=diff" /tmp/pal.png
ffmpeg -y -i /tmp/ios_cut.mp4 -i /tmp/pal.png \
  -lavfi "fps=12,scale=300:-1:flags=lanczos[x];[x][1:v]paletteuse=dither=bayer:bayer_scale=3" screenshots/demo.gif
```

## Android demo GIF

```sh
emulator -avd Medium_Phone_API_36.1 &
flutter build apk --debug
flutter drive --driver test_driver/integration_test.dart \
  --target integration_test/screenshot_test.dart -d emulator-5554 &
# once the log prints "Connecting to Flutter application":
adb -s emulator-5554 shell screenrecord --time-limit 110 --size 540x1200 /sdcard/ademo.mp4
adb -s emulator-5554 pull /sdcard/ademo.mp4 /tmp/android.mp4
```

Trim to the app section (`-ss 2 -to 57`, `setpts=PTS/1.8`) and run the same two-pass ffmpeg
palette conversion into `screenshots/demo-android.gif`. Let `screenrecord` stop on
`--time-limit` so the mp4 is finalized. The Android run writes Android-sized PNGs into
`screenshots/`, so restore the iOS set afterwards.
