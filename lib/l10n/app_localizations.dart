import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Zikr'**
  String get appTitle;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @azkar.
  ///
  /// In en, this message translates to:
  /// **'Azkar'**
  String get azkar;

  /// No description provided for @prayer.
  ///
  /// In en, this message translates to:
  /// **'Prayer'**
  String get prayer;

  /// No description provided for @fajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get fajr;

  /// No description provided for @dhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get dhuhr;

  /// No description provided for @asr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get asr;

  /// No description provided for @maghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get maghrib;

  /// No description provided for @isha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get isha;

  /// No description provided for @sebha.
  ///
  /// In en, this message translates to:
  /// **'Sebha'**
  String get sebha;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Peace be upon you'**
  String get greeting;

  /// No description provided for @nextPrayer.
  ///
  /// In en, this message translates to:
  /// **'Next prayer'**
  String get nextPrayer;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @randomZekr.
  ///
  /// In en, this message translates to:
  /// **'Random zekr'**
  String get randomZekr;

  /// No description provided for @newZekr.
  ///
  /// In en, this message translates to:
  /// **'New zekr'**
  String get newZekr;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// No description provided for @afterPrayer.
  ///
  /// In en, this message translates to:
  /// **'After prayer'**
  String get afterPrayer;

  /// No description provided for @sleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleep;

  /// No description provided for @waking.
  ///
  /// In en, this message translates to:
  /// **'Waking up'**
  String get waking;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @dailyProgress.
  ///
  /// In en, this message translates to:
  /// **'Your daily wird'**
  String get dailyProgress;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @benefit.
  ///
  /// In en, this message translates to:
  /// **'Benefit'**
  String get benefit;

  /// No description provided for @tapToCount.
  ///
  /// In en, this message translates to:
  /// **'Tap to count'**
  String get tapToCount;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get done;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get saved;

  /// No description provided for @removed.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get removed;

  /// No description provided for @emptyFavorites.
  ///
  /// In en, this message translates to:
  /// **'Your favorites will appear here'**
  String get emptyFavorites;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @currentPrayer.
  ///
  /// In en, this message translates to:
  /// **'Current prayer'**
  String get currentPrayer;

  /// No description provided for @chooseLocation.
  ///
  /// In en, this message translates to:
  /// **'Choose location'**
  String get chooseLocation;

  /// No description provided for @calculationMethod.
  ///
  /// In en, this message translates to:
  /// **'Calculation method'**
  String get calculationMethod;

  /// No description provided for @asrMethod.
  ///
  /// In en, this message translates to:
  /// **'Asr juristic method'**
  String get asrMethod;

  /// No description provided for @standard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standard;

  /// No description provided for @hanafi.
  ///
  /// In en, this message translates to:
  /// **'Hanafi'**
  String get hanafi;

  /// No description provided for @sunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunrise;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @prayerNotifications.
  ///
  /// In en, this message translates to:
  /// **'Prayer notifications'**
  String get prayerNotifications;

  /// No description provided for @azanSound.
  ///
  /// In en, this message translates to:
  /// **'Azan sound'**
  String get azanSound;

  /// No description provided for @azkarReminders.
  ///
  /// In en, this message translates to:
  /// **'Azkar reminders'**
  String get azkarReminders;

  /// No description provided for @morningReminder.
  ///
  /// In en, this message translates to:
  /// **'Morning reminder'**
  String get morningReminder;

  /// No description provided for @eveningReminder.
  ///
  /// In en, this message translates to:
  /// **'Evening reminder'**
  String get eveningReminder;

  /// No description provided for @sleepReminder.
  ///
  /// In en, this message translates to:
  /// **'Sleep reminder'**
  String get sleepReminder;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @randomFrequency.
  ///
  /// In en, this message translates to:
  /// **'Random zekr changes'**
  String get randomFrequency;

  /// No description provided for @eachOpen.
  ///
  /// In en, this message translates to:
  /// **'Each app open'**
  String get eachOpen;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Once a day'**
  String get daily;

  /// No description provided for @exactAlarm.
  ///
  /// In en, this message translates to:
  /// **'Exact alarm access'**
  String get exactAlarm;

  /// No description provided for @exactAlarmExplanation.
  ///
  /// In en, this message translates to:
  /// **'Allow exact alarms for prayer reminders at the selected time. If denied, reminders still use Android\'s inexact delivery.'**
  String get exactAlarmExplanation;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @permissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications are turned off'**
  String get permissionTitle;

  /// No description provided for @permissionExplanation.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications in system settings to receive prayer and azkar reminders.'**
  String get permissionExplanation;

  /// No description provided for @locationPermission.
  ///
  /// In en, this message translates to:
  /// **'Location permission is unavailable. Choose a city manually or allow location access in settings.'**
  String get locationPermission;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use device location'**
  String get useCurrentLocation;

  /// No description provided for @locationServicesOff.
  ///
  /// In en, this message translates to:
  /// **'Location services are turned off. Choose a city manually or enable location services.'**
  String get locationServicesOff;

  /// No description provided for @notificationsDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications were not enabled. You can enable them in system settings.'**
  String get notificationsDenied;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission required'**
  String get permissionRequired;

  /// No description provided for @riyadh.
  ///
  /// In en, this message translates to:
  /// **'Riyadh'**
  String get riyadh;

  /// No description provided for @makkah.
  ///
  /// In en, this message translates to:
  /// **'Makkah'**
  String get makkah;

  /// No description provided for @cairo.
  ///
  /// In en, this message translates to:
  /// **'Cairo'**
  String get cairo;

  /// No description provided for @istanbul.
  ///
  /// In en, this message translates to:
  /// **'Istanbul'**
  String get istanbul;

  /// No description provided for @london.
  ///
  /// In en, this message translates to:
  /// **'London'**
  String get london;

  /// No description provided for @newYork.
  ///
  /// In en, this message translates to:
  /// **'New York'**
  String get newYork;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @setCustomTarget.
  ///
  /// In en, this message translates to:
  /// **'Set custom target'**
  String get setCustomTarget;

  /// No description provided for @enterNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a number'**
  String get enterNumber;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @sessionHistory.
  ///
  /// In en, this message translates to:
  /// **'Session history'**
  String get sessionHistory;

  /// No description provided for @noSessions.
  ///
  /// In en, this message translates to:
  /// **'Your completed sessions will appear here'**
  String get noSessions;

  /// No description provided for @batteryTip.
  ///
  /// In en, this message translates to:
  /// **'Keep reminders reliable'**
  String get batteryTip;

  /// No description provided for @batteryTipBody.
  ///
  /// In en, this message translates to:
  /// **'Some Android manufacturers delay background alarms. For reliable reminders, allow Zikr to run without battery restrictions and allow notifications and exact alarms in system settings.'**
  String get batteryTipBody;

  /// No description provided for @scholarReview.
  ///
  /// In en, this message translates to:
  /// **'Azkar references and translations require review by a qualified scholar before release.'**
  String get scholarReview;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
