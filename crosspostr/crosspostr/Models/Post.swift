import Foundation
import SwiftData

@Model
class Post: Identifiable {
    @Attribute(.unique) var id: UUID /// Sorgt für eine Einzigartige vergabe von ID'S somit wenn insert schon vorhanden --> Update
    var content: String
    var createdAt: Date
    var mediaIds: [UUID]
    var metadata: String
    var platforms: String
    var scheduledAt: Date
    var status: String
    var userId: String
    
    init(content: String, createdAt: Date, id: UUID = UUID(), mediaIds: [UUID] = [], metadata: String, platforms: String, scheduledAt: Date, status: String, userId: String) {
        self.id = id
        self.content = content
        self.createdAt = createdAt
        self.mediaIds = mediaIds
        self.metadata = metadata
        self.platforms = platforms
        self.scheduledAt = scheduledAt
        self.status = status
        self.userId = userId
    }

    /// Berechnet die Metadaten für verschiedene Social-Media-Plattformen.
    func calculateMetaData() -> String {
        let platformsList = platforms.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
        
        var metadataDict: [String: Any] = [:]
        
        for platform in platformsList {
            switch platform {
            case "twitter":
                metadataDict["maxCharacters"] = 280
                metadataDict["supportsVideos"] = true
                metadataDict["supportsImages"] = true
                metadataDict["hashtags"] = extractHashtags()

            case "instagram":
                metadataDict["maxCharacters"] = 2200
                metadataDict["supportsVideos"] = true
                metadataDict["supportsImages"] = true
                metadataDict["hashtags"] = extractHashtags()
                metadataDict["mentionCount"] = countMentions()

            case "facebook":
                metadataDict["maxCharacters"] = 63206
                metadataDict["supportsVideos"] = true
                metadataDict["supportsImages"] = true
                metadataDict["emojiCount"] = countEmojis()

            case "linkedin":
                metadataDict["maxCharacters"] = 3000
                metadataDict["supportsVideos"] = true
                metadataDict["supportsImages"] = true
                metadataDict["linkCount"] = countLinks()

            case "tiktok":
                metadataDict["maxCharacters"] = 150
                metadataDict["supportsVideos"] = true
                metadataDict["supportsImages"] = false
                metadataDict["engagementBoost"] = calculateEngagementBoost()

            default:
                metadataDict["info"] = "Plattform nicht erkannt"
            }
        }
        
        // Umwandlung in JSON-String für bessere Lesbarkeit
        if let jsonData = try? JSONSerialization.data(withJSONObject: metadataDict, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        
        return "{}"
    }

    /// Extrahiert Hashtags aus dem Content
    func extractHashtags() -> [String] {
        let regex = try? NSRegularExpression(pattern: "#(\\w+)", options: [])
        let matches = regex?.matches(in: content, range: NSRange(content.startIndex..., in: content)) ?? []
        
        return matches.map {
            String(content[Range($0.range(at: 1), in: content)!])
        }
    }

    /// Zählt Erwähnungen (@username)
    func countMentions() -> Int {
        let regex = try? NSRegularExpression(pattern: "@(\\w+)", options: [])
        return regex?.numberOfMatches(in: content, range: NSRange(content.startIndex..., in: content)) ?? 0
    }

    /// Zählt Emojis im Text
    func countEmojis() -> Int {
        return content.unicodeScalars.filter { $0.properties.isEmoji }.count
    }

    /// Zählt Links im Text
    func countLinks() -> Int {
        let regex = try? NSRegularExpression(pattern: "https?://[a-zA-Z0-9./?=_-]+", options: [])
        return regex?.numberOfMatches(in: content, range: NSRange(content.startIndex..., in: content)) ?? 0
    }

    /// Simulierte Engagement-Berechnung für TikTok-Posts
    func calculateEngagementBoost() -> Double {
        let words = content.split(separator: " ").count
        let emojis = countEmojis()
        return Double(words + emojis) * 1.2 // Beispiel-Logik
    }
    
    /*
     🛠️ Berechnung der Authentizität
         •    Persönliche Sprache (+)
         •    Enthält der Post “ich”, “mein”, “mich”, “mir”, gibt das Pluspunkte, weil er persönlicher wirkt.
         •    Zu viele Hashtags (-)
         •    Mehr als 5 Hashtags senken den Score, da das oft nach Spam aussieht.
         •    Links (-)
         •    Mehr als 1 Link senkt die Authentizität, weil zu viele Links oft für Werbung genutzt werden.
         •    Erwähnungen (-)
         •    Mehr als 3 Erwähnungen (@user) macht den Post weniger authentisch.
         •    Emojis (+/-)
         •    0 Emojis kann den Post zu trocken wirken lassen, zu viele (>5) kann übertrieben wirken.
         •    Post-Länge (+)
         •    Posts mit zwischen 50 und 250 Zeichen wirken am natürlichsten.
     
     Inhalt                                                                                     Score
     "Ich liebe es, mit euch zu teilen!"                                                        100 ✅ Perfekt
     "Jetzt zuschlagen! #Sale #Angebot #Discount #MegaDeal #Rabatt #Sparen"                     30 ❌ Spam
     "Schaut mal @user1 @user2 @user3 @user4 @user5, hier ist mein Link: https://spam.com"      10 ❌ Sehr unnatürlich
     "Ich habe heute einen coolen Tipp für euch: #Swift #iOSDev 🚀"                             95 ✅ Sehr authentisch
     */
    func calculateAuthenticityScore() -> Double {
        var score: Double = 100.0 // Maximal 100 Punkte für einen perfekten Post

        let personalWords = ["ich", "mein", "mich", "mir", "uns", "wir"]
        let wordsInContent = content.lowercased().split(separator: " ")

        // 🔹 Persönliche Sprache gibt +10 Punkte (bis zu max. 20 Punkte)
        let personalWordCount = wordsInContent.filter { personalWords.contains(String($0)) }.count
        score += min(Double(personalWordCount * 10), 20)

        // ❌ Hashtags: Mehr als 5 senkt den Score um je -5 Punkte
        let hashtags = extractHashtags()
        if hashtags.count > 5 {
            score -= Double((hashtags.count - 5) * 5)
        }

        // ❌ Links: Mehr als 1 senkt den Score um -15 Punkte
        let links = countLinks()
        if links > 1 {
            score -= Double((links - 1) * 15)
        }

        // ❌ Erwähnungen: Mehr als 3 senkt den Score um -5 Punkte pro extra Erwähnung
        let mentions = countMentions()
        if mentions > 3 {
            score -= Double((mentions - 3) * 5)
        }

        // ✅ Emojis: 1-5 Emojis sind ideal, 0 oder mehr als 5 verringern den Score um -10 Punkte
        let emojis = countEmojis()
        if emojis == 0 || emojis > 5 {
            score -= 10
        }

        // 📏 Länge des Posts: Ideal sind 50-250 Zeichen, zu kurz oder zu lang gibt Abzüge
        let length = content.count
        if length < 50 {
            score -= 15 // Zu kurz
        } else if length > 250 {
            score -= 10 // Zu lang
        }

        // Sicherheit: Score darf nicht negativ sein
        return max(score, 0)
    }
}

extension Post {
    func toPostDTO() -> PostDTO {
        PostDTO(
            content: self.content,
            createdAt: self.createdAt,
            id: self.id,
            mediaIds: self.mediaIds,
            metadata: self.metadata,
            platforms: self.platforms,
            scheduledAt: self.scheduledAt,
            status: self.status,
            userId: self.userId
        )
    }
}


enum PostStatus: String, Codable {
    case scheduled, published, failed
}
