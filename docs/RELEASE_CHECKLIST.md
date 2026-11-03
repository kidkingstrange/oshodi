# Google Play Release Checklist & Production Launch Manual

This is the comprehensive operational guide for the owner of **Oshodimushin: Lagos Street RPG** to build, configure, test, and release the game on the Google Play Store.

---

## Stage 1: Google Play Developer Account & Payments Setup

- [ ] **1.1 Create Google Play Developer Account:**
  - Register at [play.google.com/console](https://play.google.com/console).
  - Pay the one-time $25 registration fee.
  - Complete the mandatory identity verification (National Identification Number - NIN, International Passport, or Driver's License) and address verification.
- [ ] **1.2 Set Up Payments Merchant Profile (For In-App Purchases):**
  - In Play Console, navigate to **Settings > Developer account > Payment settings**.
  - Link a valid Nigerian bank account (or designated payment provider) capable of receiving merchant payouts.
  - Review withholding tax declarations and local currency payout parameters for Nigerian Naira (NGN).
- [ ] **1.3 Create App in Console:**
  - Click **Create app**.
  - App name: `Oshodimushin: Lagos Street RPG`
  - Default language: `English (United States)` or `English (Nigeria)`
  - App or Game: **Game**
  - Free or Paid: **Free** (The game is freemium with optional IAPs)
  - Accept Developer Program Policies and US export laws.
- [ ] **1.4 Opt In to Play App Signing (Mandatory):**
  - In **Release > Setup > App integrity**, confirm that **Play App Signing** is enabled. Google securely generates and stores your app signing key, protecting your app even if you lose your local upload key.

---

## Stage 2: Production Keystore Creation & Security

Your upload keystore is used to sign the Android App Bundle (`.aab`) before uploading it to Google Play.

- [ ] **2.1 Generate Release Keystore:**
  Open PowerShell or Command Prompt and run the Java `keytool` command (keep this keystore outside the git repository or verify it is ignored by `.gitignore`):
  ```bash
  keytool -v -genkeypair -v -keystore release.keystore -alias oshodimushin_key -keyalg RSA -keysize 2048 -validity 10000
  ```
  Enter a secure keystore password and answer the standard organizational questions.
- [ ] **2.2 Back Up Your Keystore Safely:**
  > [!IMPORTANT]
  > Never commit `release.keystore` or passwords to a public Git repository. Save a backup copy in a secure password manager or encrypted cloud vault.
- [ ] **2.3 Place in Project (Ignored by Git):**
  Copy `release.keystore` to the project root directory. `.gitignore` is already configured with `*.keystore` to prevent committing it.

---

## Stage 3: App Configuration & Export Presets

- [ ] **3.1 Verify Versioning:**
  - `project.godot`: `config/version="1.0.0"`
  - `export_presets.cfg`:
    - `version/code=1` (Increment by +1 for every subsequent Play Store upload)
    - `version/name="1.0.0"`
    - `package/unique_name="com.danfostudios.oshodimushin"`
    - `package/name="Oshodimushin RPG"`
    - `gradle_build/min_sdk="24"` (Supports Android 7.0 Nougat and higher)
    - `gradle_build/target_sdk="34"` (Meets Google Play's Android 14+ mandate)
- [ ] **3.2 Configure Keystore Credentials in Godot:**
  In Godot, open **Project > Export > Android**:
  - **Release Keystore:** `res://release.keystore`
  - **Release User (Alias):** `oshodimushin_key`
  - **Release Password:** *[Your keystore password]*
  - **Export Format:** Select **Export AAB** (Android App Bundle).
- [ ] **3.3 Export the Release AAB:**
  Run the export command:
  ```bash
  Godot_v4.7.2-stable_win64.exe --headless --export-release "Android" "build/android/OshodimushinRPG.aab"
  ```
  Verify the generated file `build/android/OshodimushinRPG.aab` exists and is under the 50 MB budget (approx. 20–30 MB compressed).

---

## Stage 4: Store Listing & App Content Submissions

Using the documents prepared in the `docs/` directory:

- [ ] **4.1 Main Store Listing (`docs/PLAY_STORE_LISTING.md`):**
  - Enter App Title: `Oshodimushin: Lagos Street RPG`
  - Enter Short Description: `Survive, hustle, and rise in the vibrant Oshodi-Isolo corridor of Lagos!`
  - Enter Full Description from `docs/PLAY_STORE_LISTING.md`.
  - Category: Games > Role Playing (RPG)
  - Tags: Role Playing, Life Sim, Single Player, Stylized, Offline.
- [ ] **4.2 Store Graphics (`docs/STORE_ASSETS_BRIEF.md`):**
  - Upload App Icon (512 × 512 px PNG).
  - Upload Feature Graphic (1024 × 500 px PNG/JPG).
  - Upload at least 4 Phone Screenshots (1080 × 2400 px or 1080 × 1920 px).
- [ ] **4.3 Host Privacy Policy (`docs/PRIVACY_POLICY.md`):**
  - Host the markdown content on GitHub Pages, Google Sites, or your personal website.
  - Enter the public URL into Play Console > App content > **Privacy policy**.
- [ ] **4.4 Complete App Content Declarations (`docs/DATA_SAFETY_AND_RATING.md`):**
  - Complete **Data Safety** questionnaire using Part 1 answers.
  - Complete **Ads Declaration** (Select "Yes, contains ads").
  - Complete **App Access** (Select "All functionality available without restriction").
  - Complete **Target Audience** (Select 13–15, 16–17, 18+).
  - Complete **IARC Content Rating Questionnaire** using Part 3 answers.

---

## Stage 5: In-App Products Setup (Play Console)

In Google Play Console, go to **Monetize > Products > In-app products**:

- [ ] **5.1 Create Product: `remove_ads`**
  - Product ID: `remove_ads`
  - Name: `Remove Ads & Supporter Status`
  - Description: `Permanently removes ads and unlocks instant daily energy bonuses.`
  - Price: `₦1,000` (~$0.99 USD equivalent)
  - Status: Active
- [ ] **5.2 Create Product: `starter_hustle_pack`**
  - Product ID: `starter_hustle_pack`
  - Name: `Starter Hustle Pack`
  - Description: `Instant cash injection of ₦10,000 and +20 max energy capacity boost.`
  - Price: `₦500` (~$0.49 USD equivalent)
  - Status: Active
- [ ] **5.3 Create Product: `danfo_golden_skin`**
  - Product ID: `danfo_golden_skin`
  - Name: `Golden Danfo Van Skin`
  - Description: `Exclusive metallic yellow and gold exterior styling for your transport fleet.`
  - Price: `₦1,500` (~$1.49 USD equivalent)
  - Status: Active
- [ ] **5.4 Create Product: `market_tycoon_banner`**
  - Product ID: `market_tycoon_banner`
  - Name: `Market Tycoon Stall Banner`
  - Description: `Prestigious hand-painted stall banner boosting market customer appeal.`
  - Price: `₦1,500` (~$1.49 USD equivalent)
  - Status: Active

---

## Stage 6: Closed Testing Track (Mandatory 14 Days / 20 Testers)

For personal Google Play accounts registered after November 2023, Google requires a closed test before granting production publishing rights.

- [ ] **6.1 Create Closed Testing Track:**
  - In Play Console, go to **Testing > Closed testing**.
  - Create a new track named "Alpha Closed Test".
  - Create an email list of at least 20 testers (friends, family, university colleagues, Lagos gaming communities).
  - Share the opt-in web link with your testers.
- [ ] **6.2 Upload Release AAB to Closed Track:**
  - Create a new release, upload `OshodimushinRPG.aab`, add release notes, and rollout to 100% of the closed test group.
- [ ] **6.3 Active Testing Period (14 Days Continuous):**
  - Ensure at least 20 testers have accepted the invite and installed the game.
  - Testers must remain opted-in for at least 14 consecutive days.
  - Check **Android Vitals** in Play Console to verify:
    - User-perceived crash rate is under 1.09%.
    - User-perceived ANR (Application Not Responding) rate is under 0.47%.
- [ ] **6.4 Apply for Production Access:**
  - After 14 days, the "Apply for Production" button will become active in your Play Console dashboard.
  - Answer the brief reflection questions (describing test feedback, stability fixes, and app readiness) and submit.

---

## Stage 7: Production Release & Staged Rollout

- [ ] **7.1 Create Production Release:**
  - Navigate to **Release > Production**.
  - Select your verified AAB release.
  - Add production release notes:
    ```text
    Initial public release of Oshodimushin: Lagos Street RPG!
    - Choose from 6 authentic hustle classes: Trader, Transporter, Area Boy, Working Class, Road Official, Faith Leader.
    - 36 specialized subclasses and over 60 dynamic street situations.
    - 100% offline-first single-player gameplay.
    ```
- [ ] **7.2 Staged Rollout (Recommended):**
  - Day 1: Release to **20%** of users. Monitor Android Vitals crash logs.
  - Day 2–3: Increase rollout to **50%**.
  - Day 4–5: Complete rollout to **100%**.
- [ ] **7.3 Post-Launch Monitoring:**
  - Check user reviews and respond courteously.
  - Keep `SaveSystem.save_version` backward compatibility intact for future content updates.
