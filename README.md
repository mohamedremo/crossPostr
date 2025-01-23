# crossPostr

**Deine Storys. Überall.**

Unsere App **crossPostr** bietet eine einfache und effiziente Lösung, um Social-Media-Beiträge auf mehreren Plattformen gleichzeitig zu planen und zu veröffentlichen. Sie richtet sich an Content Creator, Social-Media-Manager und Unternehmen, die Zeit sparen und ihre Reichweite maximieren möchten.

## Design

<p>
  <img src="./img/screen1.png" width="200">
  <img src="./img/screen2.png" width="200">
  <img src="./img/screen3.png" width="200">
</p>

## Features

Hier kommen alle Features rein, welche deine App bietet.

**Tipp: Du kannst diese Punkte auch am Anfang ausfüllen und mit der Zeit abhaken, sodass am Ende eine vollständige Liste entsteht.**

- [ ] 🌐  **Plattformübergreifendes Posten**: Inhalte gleichzeitig auf mehreren Social-Media-Plattformen veröffentlichen.
- [ ] ⏰  **Beitragsplanung**: Posts im Voraus planen mit Datum- und Uhrzeit-Auswahl.
- [ ] 🖼️  **Medien-Unterstützung**: Bilder, Videos und Texte in Posts integrieren.
- [ ] 📊  **Statistik-Analyse**: Überblick über Likes, Kommentare, Shares und Reichweite.
- [ ]  **🔔 Benachrichtigungen**: Erinnerungen für geplante Posts und Erfolge nach Veröffentlichung.
- [ ] 🗂️  **Dashboard**: Übersicht aller geplanten und abgeschlossenen Beiträge.

## Technischer Aufbau

#### Projektaufbau

Unsere App **crossPostr** folgt der **MVVM-Architektur** (Model-View-ViewModel), um eine klare Trennung von Logik und UI zu gewährleisten. Die Ordnerstruktur ist wie folgt aufgebaut:

**Ordnerstruktur**

• **app/** - Hauptverzeichnis der Anwendung, enthält die Einstiegspunkte.

• **ui/** - Enthält alle Views (Screens) und zugehörigen UI-Komponenten, strukturiert nach Tabs (z. B. Home, Create, Analytics).

• **viewmodel/** - ViewModels zur Datenverarbeitung und Bindung zwischen Repository und UI.

• **model/** - Enthält die Datenklassen und Business-Logik.

• **repository/** - Zugriff auf externe Datenquellen (z. B. API, lokale Datenbanken).

• **network/** -  Netzwerkservices für API-Calls.

• **utils/** Hilfsklassen, Konstante und generische Funktionen.

#### Datenspeicherung

• **Benutzerprofile:** Supabase

• **Beiträge:**

• Geplante Beiträge: SwiftData

• Veröffentlicht/Archiviert: Supabase

• **Statistiken:** Supabase (Hauptspeicher), SwiftData (lokale Kopien)

• **App-Einstellungen:** SwiftData

#### API Calls

• **Supabase API :** Authentifizierung, Datenbankzugriff und Echtzeit-Synchronisation.

• **Social-Media-Plattform-APIs:**

• **Facebook Graph API**: Veröffentlichen von Beiträgen, Abrufen von Insights.

• **Twitter API**: Tweets planen, veröffentlichen und analysieren.

• **Instagram Graph API**: Bilder und Videos posten, Statistiken abrufen.

• **LinkedIn API**: Beiträge veröffentlichen und Engagement-Daten sammeln.

• **Image Processing API (z. B. Cloudinary):**

• **Funktion:** Optimierung und Speicherung von Bildern für Social-Media-Beiträge.

• **Analytics API (z. B. Supabase Functions):**

• **Funktion:** Berechnung von Insights wie Posting-Zeiten und Trendanalysen.

#### 3rd-Party Frameworks

• **Supabase Swift SDK**

• Für Datenbankzugriff, Authentifizierung und Echtzeit-Sync.

• **Kingfisher**

• Bild-Cache und -Laden für schnelle und optimierte Medienanzeige.

• **SwiftCharts**

• Darstellung von Statistiken und Analysen in benutzerfreundlichen Diagrammen.

• **Firebase SDK**

• Push-Benachrichtigungen und Crashlytics für Fehlerberichte.

• **Lottie for SwiftUI**

• Animationen für ein interaktives und modernes UI.

• **SwiftUIX**

• Zusätzliche UI-Komponenten und Verbesserungen für SwiftUI.

## Ausblick

Nach Abschluss der Mindestanforderungen

- [ ]  **Automatisierung** (KI-gestützte vorschläge für optimale Zeiten zum Posten)
- [ ]  **Erweiterte Analytics** (Detailliertere Statistiken, wie demografische Insights und plattformspezifische Erfolgsfaktoren.)
- [ ]  **Zusätzliche Plattformen** (Integration weiterer Netzwerke wie TikTok, Pinterest und YouTube.)
- [ ]  **Team-Management** (Rollen- und Berechtigungsverwaltung für kollaboratives Arbeiten im Team.)
- [ ]  **Premium-Funktionen** - Ne scherz ist ForFree ^^
