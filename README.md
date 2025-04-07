# crossPostr 👝🚀

**Deine Storys. Überall.**

**crossPostr** ist eine moderne iOS-App, mit der du Social-Media-Beiträge zentral erstellen, planen und auf mehreren Plattformen gleichzeitig veröffentlichen kannst.

## 🔥 Highlights

- 🌐 Plattformübergreifendes Posten: Ein Beitrag – mehrere Netzwerke.
- 🗓️ Beiträge planen oder direkt posten.
- 🖼️ Unterstützung für Bilder, Videos und Text.
- 📊 KI-gestützte Vorschläge & Analyse-Tools.
- 🧠 Intelligente Trend-Erkennung & Best-Post-Time-Vorschläge.
- 📱 Modernes SwiftUI UI mit Dark Mode & Animationen.

---

## 💻 Technischer Aufbau

### ⚙️ Architektur
- MVVM (Model – View – ViewModel)
- Clean Folder Structure (Features, Core, Models, Theme, etc.)
- SwiftData + Supabase + Firebase Auth + Keychain + OAuth2

### 📁 Ordnerstruktur (aktuell)
```
crosspostr/
├── App/                      # App-Start & Konfiguration
├── Core/                     # Services, Auth, Repositories
├── Features/                 # Views + ViewModels pro Feature (z.​  z.​ B. CreatePost, Dashboard)
├── Models/                   # Post, Media, DTOs etc.
├── Theme/                    # Farben, Fonts, Styles
├── Utilities/                # Hilfsklassen, Extensions
└── Resources/                # Assets & Previews
```

### 🧠 Datenfluss & Speicherung
- Supabase: Benutzerprofile, veröffentlichte Beiträge, Statistiken
- SwiftData: Lokale Entwürfe, App-Einstellungen
- Firebase Auth: Nutzer-Authentifizierung
- Keychain: Token-Speicherung (z.​ B. für OAuth2)

---

## 🌐 API-Integrationen

- 🔐 **Supabase API** – Datenbank, Storage, Realtime
- 🔐 **Firebase Auth** – Nutzer-Authentifizierung
- 🐦 **Twitter API (v2)** – Text-Tweets posten (OAuth2)
- 📘️ **Meta Graph API** – Beiträge posten, Insights (Post-Funktion aktuell gesperrt, da Meta ohne Gewerbenachweis keinen Zugriff auf Publishing-Features erlaubt.)
- 💼 **LinkedIn API** – (geplant)
- 🧠 **KI-Modul / Supabase Function** – Trend-Erkennung & Optimierung

---

## 📦 3rd-Party Frameworks

- **Supabase Swift SDK** – Daten, Auth, Realtime
- **Firebase** – Authentifizierung, Push, Crashlytics
- **Lottie** – Animationen
- **AuthenticationServices / ASWebAuthenticationSession** – OAuth2 Login

---

## 🚀 Kommende Features

- [x] Medien-Upload zu Twitter
- [ ] TikTok / YouTube / Pinterest Integration
- [ ] Multi-User & Rollen (Teamverwaltung)
- [ ] Noch smartere KI-Vorschläge & Rewriting
- [ ] Hashtag-Vorschläge, Emoji-AutoComplete 😄
- [ ] Mehr Analytics: Demografie, Performance nach Plattform

---

## 🛠️ Setup

1. `.env` Datei erstellen oder API-Daten in einem `Secrets.swift` oder `enum` speichern:
```swift
enum APIKey: String {
    case supabase = "<YOUR_SUPABASE_KEY>"
}

enum APIHost: String {
    case supabase = "<YOUR_SUPABASE_URL>"
}
```

2. Xcode öffnen → `crosspostrApp.swift` ist Einstiegspunkt  
3. iOS-Simulator starten & App testen 💪

---

> Made with <3333 by Mohamed Remo – Powered by Swift, Supabase, Firebase und viel zu viel Kaffee ☕
