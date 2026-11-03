# Google Play Data Safety & Content Rating Guide

This document provides exact, step-by-step responses for the **Data Safety**, **Content Rating (IARC)**, and **App Content** questionnaires in the Google Play Console for **Oshodimushin: Lagos Street RPG**.

---

## Part 1: Google Play Data Safety Questionnaire

Google requires all developers to declare data collection and sharing practices. Because Oshodimushin RPG is offline-first and integrates only standard Google Play Billing and Google AdMob SDKs, follow these exact declarations:

### 1. Overview Questions
| Question | Answer | Reason / Explanation |
|---|---|---|
| **Does your app collect or share any of the required user data types?** | **Yes** | Standard third-party Google AdMob and Google Play Billing SDKs collect device identifiers and purchase telemetry. The core game itself collects no user data. |
| **Is all of the user data collected by your app encrypted in transit?** | **Yes** | All network communications by Google Play Billing and AdMob occur over secure TLS/HTTPS channels. |
| **Do you provide a way for users to request that their data be deleted?** | **Yes** | The app provides an in-game "Delete Save" option, and users can clear local app storage or reset/delete their Android Advertising ID in OS settings. |

### 2. Specific Data Types Declaration

Select **Only** the following categories. For all other categories (Location, Personal Info, Health, Messages, Photos, Audio, Files, Contacts, etc.), answer **No**.

#### A. Device or Other Identifiers
- **Data Type:** Device or other IDs (e.g., Android Advertising ID)
- **Collected?** Yes
- **Shared?** Yes (Transmitted to Google AdMob for ad serving and fraud mitigation)
- **Processed ephemerally?** Yes
- **Is this data required or optional?** Optional (Users can play fully offline without ads, or reset/opt out of advertising IDs in Android settings)
- **Purposes:**
  - [x] Advertising or marketing
  - [x] Analytics
  - [x] Fraud prevention, security, and compliance

#### B. Financial Info (Purchases)
- **Data Type:** Purchase history
- **Collected?** Yes (Processed directly by Google Play Billing)
- **Shared?** No (Handled within Google Play ecosystem)
- **Processed ephemerally?** No (Google maintains purchase records for entitlement restoration)
- **Is this data required or optional?** Optional (In-app purchases are completely optional)
- **Purposes:**
  - [x] App functionality (Verifying ownership of Remove Ads and cosmetic items)
  - [x] Fraud prevention, security, and compliance

#### C. App Performance & Diagnostics
- **Data Type:** Crash logs / Diagnostics
- **Collected?** Yes (Via Google Play Vitals and Google AdMob diagnostic telemetry)
- **Shared?** No
- **Processed ephemerally?** Yes
- **Purposes:**
  - [x] Analytics
  - [x] App functionality (Detecting rendering or device crashes)

---

## Part 2: App Content Declarations (Play Console Setup)

Complete each of the App Content sections as follows:

| Section | Declaration / Setting | Notes |
|---|---|---|
| **Privacy Policy** | Enter hosted URL of `docs/PRIVACY_POLICY.md` | Host on GitHub Pages, Google Sites, or personal domain |
| **Ads Declaration** | **"Yes, my app contains ads"** | Opt-in rewarded video ads only; no forced interstitials |
| **App Access** | **"All functionality is available without restrictions"** | No login, credentials, or geofencing required |
| **Target Audience** | Select **13–15, 16–17, 18 and over** | Do **not** select ages under 13 to avoid COPPA "Designed for Families" program complexities |
| **News Apps** | **"No"** | This is a roleplaying game, not a news publisher |
| **COVID-19 Contact Tracing** | **"No"** | Not applicable |
| **Data Safety** | Submit answers from Part 1 above | Matches offline-first + AdMob profile |
| **Government Apps** | **"No"** | Not an official government agency application |
| **Financial Features** | **"My app doesn't provide any financial features"** | Game uses fictional in-game Naira; no real money loans or cryptocurrency |

---

## Part 3: IARC Content Rating Questionnaire

The International Age Rating Coalition (IARC) questionnaire determines the app's age rating across Google Play regions (ESRB, PEGI, USK, etc.).

Select Category: **Game**

### Questionnaire Answers:
1. **Violence:**
   - Does the game contain depictions of violence? -> **Yes**
   - Are depictions of violence graphic, realistic, or bloody? -> **No**
   - How is violence depicted? -> **Mild, cartoonish, or text-based conflict only** (e.g., comedic haggling arguments, street dispute text options, cartoon sound effects; zero blood, zero gore, zero dismemberment).
2. **Fear / Horror:**
   - Does the game contain horrifying or gruesome elements? -> **No**
3. **Sexuality / Nudity:**
   - Does the game contain sexual themes, depictions, or nudity? -> **No**
4. **Language:**
   - Does the game contain profanity or offensive language? -> **No** (Mild street slang and colloquial dialogue only; zero profanity, zero slurs, zero hate speech).
5. **Controlled Substances (Drugs, Alcohol, Tobacco):**
   - Does the game depict or promote the use of illegal drugs or substance abuse? -> **No** (Mild comedic references to street bustle; zero promotion or glorification of illegal substances).
6. **Crude Humor:**
   - Does the game contain crude humor (bodily functions, vulgarity)? -> **No**
7. **Gambling:**
   - Does the game depict gambling or allow betting with real money? -> **No**
8. **User Interaction & Location Sharing:**
   - Does the game allow users to interact or exchange messages with other users? -> **No** (100% single-player).
   - Does the game share the user's physical location with other users? -> **No**.
   - Does the game allow users to purchase digital goods? -> **Yes** (In-app purchases for cosmetics and ad removal).

### Resulting Content Ratings:
- **Google Play:** Teen / Everyone 10+
- **ESRB (North America):** Everyone 10+ (Mild Fantasy Violence, Comic Mischief, In-Game Purchases)
- **PEGI (Europe):** PEGI 7 (Mild Violence, In-Game Purchases)
- **USK (Germany):** USK 6
- **ClassInd (Brazil):** 10+
