# settings_ui v3.0.0 — Release Plan

Target: `3.0.0` on pub.dev  
Flutter: 3.41.x stable / Dart 3.x  
Status: **READY TO PUBLISH**

This file tracks every task needed before and after the release.  
Check off items (`- [x]`) as they are completed.

---

## Phase 1 — Codebase Health & Deprecation Fixes ✅

- [x] **1.1** Bump `pubspec.yaml` SDK constraint to `>=3.5.0 <4.0.0` and Flutter to `>=3.16.0`
- [x] **1.2** Replace `MediaQuery.of(context).textScaleFactor` with `MediaQuery.textScalerOf(context).scale(value)`
- [x] **1.3** Replace `Key? key` super-constructor patterns with `super.key`
- [x] **1.4** Update `dev_dependencies`: `flutter_lints: ^5.0.0`
- [x] **1.5** `flutter analyze` — zero issues

---

## Phase 2 — Bug Fixes ✅

- [x] **2.1** iOS value text overflow — `Flexible` in inner Row of `buildTileContent` *(Issue #186)*
- [x] **2.2** RTL chevron — `chevron_back` in RTL locales *(Issue #170)*
- [x] **2.3** Web platform tag — `platforms:` block in `pubspec.yaml` *(Issue #179)*
- [x] **2.4** `enabled` ignored on Web tile — `inactiveTitleColor` applied *(Issue #174)*
- [x] **2.5** Web switch `activeColor` — hardcoded fallback removed *(Issue #188)*
- [x] **2.6** `switchTheme` ignored on Web — no more hardcoded blue override *(Issue #188)*
- [x] **2.7** `trailing` missing on Web switch tile — fixed
- [x] **2.9** Platform override ignored on macOS host — `theme.platform` used instead of re-detecting *(Issue #139)*
- [x] Replace deprecated `Switch.activeColor` → `Switch.activeThumbColor`
- [x] Replace deprecated `CupertinoSwitch.activeColor` → `CupertinoSwitch.activeTrackColor`

---

## Phase 3 — Material 3 Theme Overhaul ✅

- [x] **3.1/3.2** Android light + dark — derived from `ColorScheme`
- [x] **3.3** iOS themes — Cupertino hardcoded values retained
- [x] **3.4** Web theme — derived from `ColorScheme`
- [x] **3.5** `ThemeProvider.getTheme` reads `Theme.of(context).colorScheme`
- [x] **3.6** `inactiveSwitchColor` added to `SettingsThemeData`

---

## Phase 4 — New Features ✅

- [x] **4.1** `compact: bool` on `SettingsTile` *(PR #178)*
- [x] **4.2** `crossAxisAlignment` on `SettingsList` *(Issue #189)*
- [x] **4.3** `titleTextStyle`, `tileTextStyle`, `tileDescriptionTextStyle` in `SettingsThemeData` *(Issue #185)*

---

## Phase 5 — Example App ✅

- [x] **5.1** Bump example SDK + Flutter constraints
- [x] **5.2** Removed `device_preview` (incompatible with Dart 3.x); cleaned up `main.dart`
- [x] **5.3** `cupertino_icons: ^1.0.8`
- [x] **5.4** Android Gradle updated (Gradle 8.7, AGP 8.3.2, Kotlin 1.9.24, Java 17) — builds and runs
- [x] **5.5** `Material3DemoScreen` added to gallery
- [x] **5.6** All deprecated API usage fixed; `flutter analyze` zero issues

---

## Phase 6 — Tests ✅

- [x] **6.1** Test color assertions updated to use `colorScheme`
- [x] **6.2** iOS value overflow test
- [x] **6.3** RTL chevron tests (LTR + RTL)
- [x] **6.4** Web enabled/switch color tests
- [x] **6.5** Compact tile tests (Android, iOS, Web)
- [x] **6.6** Coverage gate raised 35% → 60%; actual coverage: **92%**
- [x] **6.7** 108 unit tests passing; 17 integration tests passing on Android emulator

---

## Phase 7 — CI & Release Prep ✅

- [x] **7.1** `actions/checkout@v4` in CI; coverage gate 60%
- [x] **7.3** `version: 3.0.0` in `pubspec.yaml`
- [x] **7.4** `CHANGELOG.md` entry for `3.0.0`
- [x] **7.5** `flutter pub publish --dry-run` — passes (2 soft warnings: uncommitted files + .iml git state)
- [ ] **7.6** Commit → merge `dev` → `master` → tag `v3.0.0`
- [ ] **7.7** `flutter pub publish`

---

## Phase 8 — Post-Release: Issues & PRs

Do this **after** `3.0.0` is live on pub.dev.

### PRs to merge / close
| PR | Title | Action |
|----|-------|--------|
| #193 | fix long IOSSettingsTile value text | Close — fixed in 2.1 |
| #192 | flip RTL arrow | Close — fixed in 2.2 |
| #191 | web platform pub.dev tag | Close — fixed in 2.3 |
| #178 | compact SettingsTile | Close — implemented in 4.1 |

### Issues to close
| Issue | Title | Response |
|-------|-------|----------|
| #199 | Future Updates | Announce v3.0.0 |
| #198 | White screen in release APK | Likely unrelated to package; ask for minimal repro, link v3 |
| #197 | Make a new release | Announce v3.0.0 |
| #196 | Chevron missing | Fixed in v3 (RTL fix) |
| #194 | inactiveColour for switchTile | Fixed in 3.6 |
| #189 | SettingsList alignment override | Fixed in 4.2 |
| #188 | Switch ignores switchTheme | Fixed in 2.6 |
| #186 | Title/value wrapping | Fixed in 2.1 |
| #185 | Custom font support | Fixed in 4.3 |
| #184 | iOS dirty dependencies | Verify in v3 |
| #180 | trailing missing on Web switch | Fixed in 2.7 |
| #179 | Chrome/web support | Fixed in 2.3 |
| #176 | Scrollbar on wide screens | Verify fix still works; close |
| #174 | enabled ignored on Web | Fixed in 2.4 |
| #173 | Switch color on Web | Fixed in 2.5 |
| #170 | RTL navigation arrow | Fixed in 2.2 |
| #168 | Alternative for background/subtitle | Document in v3 release notes |
| #160 | Windows layout | Improved |
| #148 | macOS layout | Improved |
| #139 | platform override ignored on macOS | Fixed in 2.9 |
| #110 | Switch not toggling | Ask if still present in v3 |

---

## Session Log

| Date | Session | What was done |
|------|---------|---------------|
| 2026-04-10 | 1 | Repo audit, CLAUDE.md written, V3_PLAN.md created |
| 2026-04-10 | 2 | Phases 1–7 completed; all tests passing; ready to publish |
