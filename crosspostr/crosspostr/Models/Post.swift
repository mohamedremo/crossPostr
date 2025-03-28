import Foundation
import SwiftData

@Model
class Post: Identifiable {
    @Attribute(.unique) var id: UUID /// Sorgt für eine Einzigartige vergabe von ID'S somit wenn insert schon vorhanden --> Update
    var content: String
    var createdAt: Date
    var mediaId: UUID?
    var metadata: String
    var platforms: String
    var scheduledAt: Date
    var status: String
    var userId: String
    
    init(content: String, createdAt: Date, id: UUID = UUID(), mediaId: UUID = UUID(), metadata: String, platforms: String, scheduledAt: Date, status: String, userId: String) {
        self.id = id
        self.content = content
        self.createdAt = createdAt
        self.mediaId = mediaId
        self.metadata = metadata
        self.platforms = platforms
        self.scheduledAt = scheduledAt
        self.status = status
        self.userId = userId
    }
    
    init(id: UUID, content: String, createdAt: Date, mediaId: UUID, metadata: String, platforms: String,scheduledAt: Date, status: String, userId: String) {
        self.id = id
        self.content = content
        self.createdAt = createdAt
        self.mediaId = mediaId
        self.metadata = metadata
        self.platforms = platforms
        self.scheduledAt = scheduledAt
        self.status = status
        self.userId = userId
    }
    
    var authenticityScore: Double {
        PostAnalyzer.calculateAuthenticityScore(for: content, createdAt: createdAt)
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
    
}

struct PostAnalyzer {
    static func calculateAuthenticityScore(for content: String, createdAt: Date) -> Double {
        var score: Double = 100.0

        let personalWords = ["ich", "mein", "mich", "mir", "uns", "wir"]
        let wordsInContent = content.lowercased().split(separator: " ")
        let personalWordCount = wordsInContent.filter { personalWords.contains(String($0)) }.count
        score += min(Double(personalWordCount * 10), 20)

        let hashtags = extractHashtags(from: content)
        if hashtags.count > 5 {
            score -= Double((hashtags.count - 5) * 5)
        }

        let links = countLinks(in: content)
        if links > 1 {
            score -= Double((links - 1) * 15)
        }

        let mentions = countMentions(in: content)
        if mentions > 3 {
            score -= Double((mentions - 3) * 5)
        }

        let emojis = countEmojis(in: content)
        if emojis == 0 || emojis > 5 {
            score -= 10
        }

        let length = content.count
        if length < 50 {
            score -= 15
        } else if length > 250 {
            score -= 10
        }

        let uppercaseCount = content.filter { $0.isUppercase }.count
        let capRate = Double(uppercaseCount) / Double(max(content.count, 1))
        if capRate > 0.3 {
            score -= 10
        }

        let hour = Calendar.current.component(.hour, from: createdAt)
        if hour < 6 || hour > 22 {
            score -= 5
        }

        let wordFreq = Dictionary(grouping: wordsInContent.map { String($0) }, by: { $0 })
            .mapValues { $0.count }
        let highFreqWords = wordFreq.filter { $0.value > 5 }
        if !highFreqWords.isEmpty {
            score -= 5
        }

        let punctuationVariety = Set(content.filter { [".", "!", "?", ","].contains($0) }).count
        if punctuationVariety >= 3 {
            score += 5
        }

        let adWords = ["jetzt kaufen", "angebot", "rabatt", "sichern sie sich", "nur heute", "limited", "sale"]
        if adWords.contains(where: { content.lowercased().contains($0) }) {
            score -= 15
        }

        let exclamationCount = content.filter { $0 == "!" }.count
        if exclamationCount > 3 {
            score -= 5
        }

        let marketingPhrases = ["verpasse nicht", "nur heute", "exklusiv", "kostenlos", "gratis", "jetzt zugreifen", "nicht verpassen"]
        if marketingPhrases.contains(where: { content.lowercased().contains($0) }) {
            score -= 10
        }

        let sentenceCount = content.components(separatedBy: [".", "!", "?"]).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count
        if sentenceCount >= 2 {
            score += 5
        }

        let emojiScalars = content.unicodeScalars.filter { $0.properties.isEmoji }
        let emojiIndices = emojiScalars.compactMap { scalar in
            content.unicodeScalars.firstIndex(of: scalar)?.utf16Offset(in: content)
        }
        if emojiIndices.contains(where: { $0 < content.count - 4 }) {
            score += 5
        }

        let directAddress = ["du", "dein", "euch", "ihr"]
        if wordsInContent.contains(where: { directAddress.contains(String($0)) }) {
            score += 5
        }

        return max(min(round(score), 100), 0)
    }

    static func extractHashtags(from text: String) -> [String] {
        let regex = try? NSRegularExpression(pattern: "#(\\w+)", options: [])
        let matches = regex?.matches(in: text, range: NSRange(text.startIndex..., in: text)) ?? []
        return matches.map { String(text[Range($0.range(at: 1), in: text)!]) }
    }

    static func countMentions(in text: String) -> Int {
        let regex = try? NSRegularExpression(pattern: "@(\\w+)", options: [])
        return regex?.numberOfMatches(in: text, range: NSRange(text.startIndex..., in: text)) ?? 0
    }

    static func countEmojis(in text: String) -> Int {
        return text.unicodeScalars.filter { $0.properties.isEmoji }.count
    }

    static func countLinks(in text: String) -> Int {
        let regex = try? NSRegularExpression(pattern: "https?://[a-zA-Z0-9./?=_-]+", options: [])
        return regex?.numberOfMatches(in: text, range: NSRange(text.startIndex..., in: text)) ?? 0
    }
}

extension Post {
    func toPostDTO() -> PostDTO {
        PostDTO(
            content: self.content,
            createdAt: self.createdAt,
            id: self.id,
            mediaId: self.mediaId ?? UUID(),
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

enum Platform: String, CaseIterable, Hashable {
    
    case instagram, twitter, facebook, snapchat
    

    func details() -> (text: String, image: String) {
            switch self {
            case .instagram:
                return ("Instagram", "instagram_icon")
            case .twitter:
                return ("X", "twitter_icon")
            case .facebook:
                return ("Facebook", "facebook_icon")
            case .snapchat:
                return ("Snapchat", "snapchat_icon")
            }
        }
    
    static func matchedPlatforms(from input: String) -> [Platform] {
        // Aufteilen des Strings nach Kommas und Leerzeichen, dann Leerzeichen trimmen und Kleinbuchstaben verwenden
        let platformStrings = input
            .lowercased()
            .split { $0 == "," || $0 == " " }
            .map { $0.trimmingCharacters(in: .whitespaces) }
        
        // Plattform-Enums filtern, die mit den String-Werten übereinstimmen
        return platformStrings.compactMap { Platform(rawValue: $0) }
    }
}
