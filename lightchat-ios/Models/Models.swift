import Foundation

// MARK: - 旅人资料模型
public struct UserProfile: Codable, Identifiable {
    public var id: String { uid }
    public let uid: String
    public var phone: String?
    public var isPhoneBound: Bool
    public var nickname: String
    public var avatarUrl: String
    public var signature: String
    public var vipUntil: Int64
    public var isBanned: Bool?
    
    public var isVip: Bool {
        return vipUntil > Int64(Date().timeIntervalSince1970 * 1000)
    }
    
    public var remainingVipDays: Int {
        guard isVip else { return 0 }
        let diff = Double(vipUntil) / 1000.0 - Date().timeIntervalSince1970
        return max(0, Int(ceil(diff / 86400.0)))
    }
    
    enum CodingKeys: String, CodingKey {
        case uid
        case phone
        case isPhoneBound = "is_phone_bound"
        case nickname
        case avatarUrl = "avatar_url"
        case signature
        case vipUntil = "vip_until"
        case isBanned = "is_banned"
    }
}

// MARK: - 轻语心事声轨模型
public struct SecretItem: Codable, Identifiable {
    public let id: String
    public let meta: String?
    public let authorName: String
    public let avatarUrl: String
    public let content: String
    public let voiceUrl: String?
    public let seconds: Int
    public let likes: Int
    public let pullCount: Int?
    public let distance: String?
    public let theme: String?
    public let createdAt: Int64
    
    public var formattedDate: String {
        let date = Date(timeIntervalSince1970: TimeInterval(createdAt) / 1000.0)
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:mm"
        return formatter.string(from: date)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case meta
        case authorName = "name"
        case avatarUrl = "avatar"
        case content = "content"
        case voiceUrl
        case seconds
        case likes
        case pullCount
        case distance
        case theme
        case createdAt
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        meta = try? container.decode(String.self, forKey: .meta)
        authorName = (try? container.decode(String.self, forKey: .authorName)) ?? "星河旅人"
        avatarUrl = (try? container.decode(String.self, forKey: .avatarUrl)) ?? ""
        content = (try? container.decode(String.self, forKey: .content)) ?? ""
        voiceUrl = try? container.decode(String.self, forKey: .voiceUrl)
        seconds = (try? container.decode(Int.self, forKey: .seconds)) ?? 0
        likes = (try? container.decode(Int.self, forKey: .likes)) ?? 0
        pullCount = try? container.decode(Int.self, forKey: .pullCount)
        distance = try? container.decode(String.self, forKey: .distance)
        theme = try? container.decode(String.self, forKey: .theme)
        createdAt = (try? container.decode(Int64.self, forKey: .createdAt)) ?? Int64(Date().timeIntervalSince1970 * 1000)
    }
}

// MARK: - 私聊会话与即时消息模型
public struct ChatMessageItem: Codable, Identifiable {
    public var id: String { msgId }
    public let msgId: String
    public let convId: String
    public let from: String
    public let to: String
    public let kind: String // "text" | "voice" | "image"
    public let text: String
    public let url: String
    public let seconds: Int
    public let ts: Int64
    public let read: Bool?
    
    public var isImage: Bool { kind == "image" }
    public var isVoice: Bool { kind == "voice" }
    
    public var formattedTime: String {
        let date = Date(timeIntervalSince1970: TimeInterval(ts) / 1000.0)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
