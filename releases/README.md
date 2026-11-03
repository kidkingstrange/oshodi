# Oshodimushin RPG — Release Binaries Directory

This directory is designated for holding local Android release binaries:

- `releases/OshodimushinRPG.apk` (For sideloading and testing on physical Android devices)
- `releases/OshodimushinRPG.aab` (Android App Bundle for uploading to the Google Play Store Console)

### How to generate these files:
1. In the Godot 4 editor, ensure export templates are installed (**Editor > Manage Export Templates > Download and Install**).
2. Configure your Android SDK path in **Editor > Editor Settings > Export > Android**.
3. Go to **Project > Export**:
   - Select preset **Android** to export `OshodimushinRPG.apk` into this folder.
   - Select preset **Android AAB (Release)** to export `OshodimushinRPG.aab` into this folder.
4. Once exported here, run:
   ```bash
   git add releases/
   git commit -m "release: add v1.0.0 APK and AAB binaries"
   git push origin master
   ```
