## [4.0.0] - [September 24, 2026]

### Breaking changes
* Migrated from `package:flutter/material.dart` and `package:flutter/cupertino.dart` to the decoupled [`material_ui`](https://pub.dev/packages/material_ui) and [`cupertino_ui`](https://pub.dev/packages/cupertino_ui) packages (#207)
* Requires Flutter >=3.44.0 and Dart SDK >=3.12.0
* Your app must use `MaterialApp`/`CupertinoApp` from `material_ui`/`cupertino_ui`. In an app still on `package:flutter/material.dart`, `SettingsList` can't read your theme and falls back to default colors and light mode. Stay on `^3.0.1` until your app has migrated.
* New default look that matches iOS 26/27, macOS 26/27, Android 16/17, Windows 11, GNOME 51 and current Chrome settings (see Design refresh). Sizes, paddings and default colors changed. Colors you set in `SettingsThemeData` still win.
* iOS switch tiles now show the new `CupertinoSettingsSwitch` instead of `CupertinoSwitch`. Tests that find `CupertinoSwitch` need to look for `CupertinoSettingsSwitch`.
* macOS now has its own macOS System Settings style instead of the iOS style. Its switch tiles show the new `MacosSettingsSwitch`, not a `CupertinoSwitch`.
* Windows now has its own Windows 11 style instead of the iOS style. Its switch tiles show the new `FluentSettingsSwitch`, not a `CupertinoSwitch`.
* Linux now has its own GNOME style instead of the Android style. Its switch tiles show the new `AdwaitaSettingsSwitch`, not a Material `Switch`.

### Design refresh
* iOS: 26pt cards with continuous corners and 20pt side margins, 52pt rows with 17pt text, 17pt semibold section headers, and the iOS secondary grey for headers and footers. iOS no longer uses all-caps headers, so pass headers in sentence case.
* iOS: a new switch that matches the iOS 26/27 one, drawn entirely in Flutter. It has a 63x28 track and a pill-shaped thumb, and while it is pressed or dragged the thumb becomes a Liquid Glass-style lens. It is public as `CupertinoSettingsSwitch`, so you can use it outside settings lists too.
* macOS: a new style that matches macOS 26/27 System Settings, instead of the iOS one: 12pt cards on a white page, 36pt rows with 13pt text, 13pt semibold headers, a 640pt column and the new public `MacosSettingsSwitch` (36x16, or 44x20 with `MacosSettingsSwitchSize.large`).
* Android, Fuchsia: every tile sits on its own card, 2dp apart, with 20dp corners at the ends of a group and 4dp in between, on a `surfaceContainer` page. 16sp titles, tighter rows, and switches that show a check or a cross.
* Windows: a new Windows 11 Settings style instead of the iOS one: one card per tile with 4px corners and a hairline border, 70px rows, 14px titles and 12px descriptions, the Windows hover, pressed and keyboard focus states, and `FluentSettingsSwitch`, a public WinUI-style toggle drawn in Flutter.
* Linux: a new GNOME style that matches GNOME Settings 51 (libadwaita 1.10): boxed-list cards with 12px corners and a soft shadow, 54px rows with full-width separators, bold group titles, dimmed subtitles and values, a `go-next` arrow on navigation tiles, hover and keyboard focus highlights, and an `AdwClamp`-style 600px column. Its switch, a 46x26 GNOME switch drawn in Flutter, is public as `AdwaitaSettingsSwitch`, and `AdwaitaPanDownIcon` gives combo rows their arrow.
* Web: Chrome-style white cards with 8px corners and a light shadow, 14px titles and 13px descriptions, 20px leading icons, a chevron on navigation tiles, near-black section titles, and a 680px column on wide screens (16px side margins in narrow windows).

### Bug fixes
* Colors, dark mode and platform now follow the app theme in apps built on `material_ui` (#206)
* iOS: values are right-aligned next to the chevron again (#203, #202)
* iOS: simple tiles now show their `value`, like on Android (#201)
* iOS: a long title no longer hides the value. The value takes at most half the row, on one line
* Compiles on Flutter forks that add platforms, such as OpenHarmony, which get the Cupertino style (#205)
* `SettingsList.brightness` now overrides the brightness from the app theme. It was ignored
* `ApplicationType.both` now goes by the platform the app runs on: the `CupertinoTheme` on iOS and macOS, the Material `Theme` elsewhere. Before, it read the Material brightness unless `platform: DevicePlatform.iOS` was set, so a `CupertinoApp` that follows the system could show light colors in dark mode
* `crossAxisAlignment: CrossAxisAlignment.start` now puts the content at the start edge on wide screens (left in LTR, right in RTL). The default padding used to keep it centered
* The wide-screen side padding now comes from the width the list gets, not the screen width, so a `SettingsList` in a narrow pane of a wide window fits the pane. iOS tile descriptions also take the list's width now
* A `SettingsSection` with no tiles no longer crashes on iOS, macOS and Windows. Empty sections now show nothing on every platform
* `SettingsTile.titleDescriptionPadding` now pads the title description on iOS. `titlePadding` was used instead
* `SettingsTile.trailingPadding` and `descriptionPadding` now work on iOS, macOS and Windows, and `titlePadding` on Android and web. They were ignored there
* Android and web: disabled switches use `SettingsThemeData.inactiveSwitchColor` with or without a `trailing` widget, and a web switch next to a `trailing` widget no longer has a hard-coded blue active color (#188)

### New features
* `SettingsSplitView`: the list and the selected page side by side on iPad, tablets, unfolded foldables, desktop and the web, and a list with pushed pages on phones. It follows each platform app: iPad Settings (320pt sidebar, blue capsule selection, two panes from 600pt on iPads), Android Settings (36.36% list pane on surface dim, two panes at 720dp wide with a 600dp smallest width, no icons in a list pane under 380dp) and Chrome (266px menu, two panes above 980px). It keeps pages, their state and pushed sub-pages when a device folds, unfolds or rotates, handles back and Android predictive back, restores the shown page, puts the panes on each side of a hinge, and mirrors in right-to-left layouts. Control it with `SettingsSplitController`, `SettingsSplitLayout`, `initialDestinationId` and `onDestinationChanged`. The macOS and Windows styles use the iPad layout and the GNOME style the Android one for now, in their own colors; their pages keep their own look
* `SettingsDestination` and `SettingsTile.navigation(destination: ...)`: a tile can open a page without your own `Navigator.push`. In a `SettingsList` it pushes a Cupertino or Material route with the platform's page header (iOS 26 inline title and glass back button, Android's collapsing large title, Chrome's page title), and the `SettingsList` in the page takes the platform, brightness and themes of the list that opened it
* `SettingsThemeData.selectedTileColor`, `selectedTileTextColor`, `selectedTileIconColor` and `listPaneBackground` for the split view, with defaults for every style
* Debug builds print a one-time warning when `SettingsList` finds no `material_ui` or `cupertino_ui` theme above it

### Documentation
* To show a value without the chevron, use `SettingsTile` instead of `SettingsTile.navigation` (#204)

### Maintenance
* CI now checks formatting with `dart format` (`flutter format` was removed from Flutter)
* Example app: updated Android Gradle setup, moved the iOS runner to the UIScene lifecycle required on iOS 27, and added a macOS runner
* Example app: a "Split view" demo with iPad, Android and Chrome settings trees, and replicas of macOS, Windows and GNOME settings pages. A screen, style and brightness can be opened directly, e.g. `flutter run --route '/split-view?platform=android&theme=dark'`, `?screen=split-view&platform=macOS` on the web, or `--dart-define=SCREEN=gnome-power`

## [3.0.1] - [April 10, 2026]
* README rewritten with a full API reference, examples and screenshots. No code changes

## [3.0.0] - [April 10, 2026]

### Breaking changes
* Requires Flutter >=3.16.0 and Dart SDK >=3.5.0
* Android and Web themes now derive colors from `Theme.of(context).colorScheme` (Material 3). Custom color overrides via `SettingsThemeData` still work.

### New features
* `compact: bool` parameter on `SettingsTile` — use smaller vertical padding for dense layouts
* `crossAxisAlignment` parameter on `SettingsList`
* `titleTextStyle`, `tileTextStyle`, `tileDescriptionTextStyle`, `inactiveSwitchColor` fields on `SettingsThemeData`

### Bug fixes
* Fixed iOS value text overflow in narrow tiles (#186)
* Fixed RTL chevron direction — now shows back-arrow in right-to-left layouts
* Fixed platform override being ignored on macOS host when `platform: android/web` was set (#139)
* Fixed web switch ignoring `SwitchTheme` due to hardcoded fallback color (#188)
* Fixed disabled switch using wrong inactive color on all platforms

### Maintenance
* Migrated all constructors to super-parameters (`super.key`, `super.child`)
* Replaced deprecated `textScaleFactor` with `MediaQuery.textScalerOf`
* Replaced deprecated `Switch.activeColor` with `Switch.activeThumbColor`
* Replaced deprecated `CupertinoSwitch.activeColor` with `CupertinoSwitch.activeTrackColor`
* Updated CI to `actions/checkout@v4`, coverage gate raised from 35% → 60%
* Updated example app with Material 3 demo screen

## [2.0.3] - [June 13, 2022]
* Updated documentation
* Fixed display of web support on pub.dev
* Fixed scrollbar on wide screens
* Fixed 'trailing' when used 'SettingsTile.switchTile'
* Fixed color scheme on web version
* Fixed default vertical padding on web version

## [2.0.2] - [January 24, 2022]
* Enabled parameter for the ListTile widget
* Trailing parameter for the ListTile widget 
* Fixed minor bugs

## [2.0.1] - [January 9, 2022]
* Cover image was updated

## [2.0.0] - [Now 30, 2021]
* The whole codebase was refactored
* Bug fixes and stability improvements

## [1.0.1] - [Jul 28, 2021]
* Allow manual platform style selection
* Fixed iOS Title text getting cut off in version 1.0.0
* CustomTile implemented
* Implement titleWidget and subtitleWidget parameters
* Implement the native behaviour for the iOS switch tile

## [1.0.0-nullsafety.3] - [April 6, 2021]
* Dropped use of 'dart:io'
* Use Theme.of(context) to detect platform
* Fixed a bug with long subtitles in iOS

## [1.0.0-nullsafety.2] - [February 26, 2021]
* Enable web support
* Round borders for web and iPad settings tiles

## [1.0.0-nullsafety.1] - [February 26, 2021]
* Null safety preview release

## [0.7.0] - [February 26, 2021]
* Fixed double trailing on iOS devices
* Support for MacOS
* Fixed padding in the project example

## [0.6.0] - [February 10, 2021]
* Fixed subtitle for iOS
* Added iosChevron and iosChevronPadding for forward chevron and color in iOS.
* CupertinoSettingsItem toggle on disabled fix
* Content padding implementation

## [0.5.0] - [December 4, 2020]
* Ripple effect for Android
* Ability to setup padding and subtitle for sections
* New onPressed(context) parameter for SettingsTile, onTap() is deprecated from now on.

## [0.4.0] - [August 21, 2020]

* Custom colors support for SettingsList
* Allow physics and shrinkWrap on SettingsList
* CupertinoSettingsItemButton ripple effect
* Device preview disabled for Flutter Web 
* CustomSection implementation (possibility to add your own widget)
* Use Target Platform to determine which Settings UI to show

## [0.3.0] - [May 19, 2020]

* Change background color for dark theme in SettingsList with backgroundColor attribute.
* Ability to add trailing widgets to tiles.
* Added enabled attribute to tile.
* Flutter Web support. 

## [0.2.0] - [December 6, 2019]

* Added onTap color change for cupertino tiles.

## [0.1.1] - [December 4, 2019]

* Slight updates.

## [0.1.0] - [December 4, 2019]

* Initial release with basic SettingsTile and SettingsTile.switchTile.
