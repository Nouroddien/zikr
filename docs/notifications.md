# Notification sound and device testing

The included `azan_placeholder.wav` is an original, royalty-free synthesized
tone (5.2 seconds), not a recorded or vocal adhan. Replace it with an adhan
recording only when you have the rights to distribute that recording. Keep the
iOS sound shorter than 30 seconds and preserve the filename, or update the
notification sound names in `NotificationService`.

- Android: replace
  `android/app/src/main/res/raw/azan_placeholder.wav`. Android notification
  channels keep their sound choice after creation; uninstall/reinstall the app
  or clear its notification-channel settings when testing a changed sound.
- iOS: replace `ios/Runner/azan_placeholder.wav`; it is included in the Runner
  target's Resources build phase. Verify the resulting app bundle contains the
  sound resource.

Android 12+ exact-alarm access is optional: when it is denied, scheduled
reminders use the inexact, idle-compatible mode. The app should explain the
trade-off before asking users to enable exact alarms. Prayer times are
calculated on device; reverse geocoding/city search may rely on the platform's
geocoding service.
