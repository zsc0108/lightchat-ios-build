import Foundation

/// 网络通信与服务端交互服务 (连接京东云生产网关 117.72.83.144/lightchat)
public class NetworkService: ObservableObject {
    public static let shared = NetworkService()
    
    public let baseURL = "http://117.72.83.144/lightchat"
    
    @Published public var currentUser: UserProfile?
    @Published public var token: String = ""
    @Published public var isConnected: Bool = false
    
    private init() {
        Task {
            await autoDeviceLogin()
        }
    }
    
    public var deviceIdentifier: String {
        let key = "com.lightchat.ios.device_id"
        if let saved = UserDefaults.standard.string(forKey: key) {
            return saved
        }
        let newID = "DEV_IOS_" + UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(12).uppercased()
        UserDefaults.standard.set(newID, forKey: key)
        return newID
    }
    
    /// 设备免密静默直登
    @MainActor
    public func autoDeviceLogin() async {
        guard let url = URL(string: "\(baseURL)/auth/device-login") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["device_id": deviceIdentifier, "device_name": "iPhone 16 Pro"]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let tok = json["token"] as? String,
               let userDict = json["user"] as? [String: Any],
               let userData = try? JSONSerialization.data(withJSONObject: userDict) {
                let user = try JSONDecoder().decode(UserProfile.self, from: userData)
                self.currentUser = user
                self.token = tok
                self.isConnected = true
            }
        } catch {
            print("[Network] 设备免密直登失败: \(error)")
        }
    }
    
    /// 随机捞取远方的一段轻语心事
    public func pullRandomSecret() async throws -> SecretItem? {
        guard let url = URL(string: "\(baseURL)/secrets/pull") else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(deviceIdentifier, forHTTPHeaderField: "x-device-id")
        if !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let (data, _) = try await URLSession.shared.data(for: request)
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let secretDict = json["secret"] as? [String: Any],
           let secretData = try? JSONSerialization.data(withJSONObject: secretDict) {
            return try JSONDecoder().decode(SecretItem.self, from: secretData)
        }
        return nil
    }
    
    /// 投递轻语心事
    public func sendSecret(content: String, voiceUrl: String = "", seconds: Int = 0, theme: String = "obsidian") async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/secrets/send") else { return false }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(deviceIdentifier, forHTTPHeaderField: "x-device-id")
        if !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let body: [String: Any] = [
            "device_id": deviceIdentifier,
            "content": content,
            "voice_url": voiceUrl,
            "seconds": seconds,
            "theme": theme
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        let (data, _) = try await URLSession.shared.data(for: request)
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let code = json["code"] as? Int, code == 0 {
            return true
        }
        return false
    }
    
    /// 点赞共鸣
    public func likeSecret(id: String) async {
        guard let url = URL(string: "\(baseURL)/secrets/like") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["secret_id": id])
        _ = try? await URLSession.shared.data(for: request)
    }
    
    /// 获取私聊历史消息
    public func fetchMessages(convId: String) async -> [ChatMessageItem] {
        guard let encoded = convId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/messages/list?conv_id=\(encoded)") else { return [] }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let list = json["list"] as? [[String: Any]],
               let listData = try? JSONSerialization.data(withJSONObject: list) {
                return (try? JSONDecoder().decode([ChatMessageItem].self, from: listData)) ?? []
            }
        } catch {}
        return []
    }
    
    /// 发送私聊消息 (支持 text / image / voice)
    public func sendChatMessage(convId: String, kind: String = "text", text: String = "", url: String = "", seconds: Int = 0) async {
        guard let reqUrl = URL(string: "\(baseURL)/messages/send") else { return }
        var request = URLRequest(url: reqUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(deviceIdentifier, forHTTPHeaderField: "x-device-id")
        if !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let body: [String: Any] = [
            "conv_id": convId,
            "kind": kind,
            "text": text,
            "url": url,
            "seconds": seconds,
            "device_id": deviceIdentifier
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        _ = try? await URLSession.shared.data(for: request)
    }
    
    /// 免短信绑定手机号
    @MainActor
    public func bindPhone(phone: String, pinCode: String) async -> Bool {
        guard let url = URL(string: "\(baseURL)/auth/bind-phone") else { return false }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let body: [String: Any] = ["phone": phone, "pin_code": pinCode, "device_id": deviceIdentifier]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let ok = json["ok"] as? Bool, ok,
               let userDict = json["user"] as? [String: Any],
               let userData = try? JSONSerialization.data(withJSONObject: userDict) {
                self.currentUser = try? JSONDecoder().decode(UserProfile.self, from: userData)
                return true
            }
        } catch {}
        return false
    }
    
    /// StoreKit 2 购买或卡密核销同步至京东云
    @MainActor
    public func purchaseVipDirect(planId: String) async -> Bool {
        guard let url = URL(string: "\(baseURL)/vip/purchase") else { return false }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "plan_id": planId,
            "channel": "APPLE_IAP",
            "device_id": deviceIdentifier
        ])
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let ok = json["ok"] as? Bool, ok,
               let userDict = json["user"] as? [String: Any],
               let userData = try? JSONSerialization.data(withJSONObject: userDict) {
                self.currentUser = try? JSONDecoder().decode(UserProfile.self, from: userData)
                return true
            }
        } catch {}
        return false
    }
    
    /// 私域激活码核销
    @MainActor
    public func redeemVipCode(code: String) async -> Bool {
        guard let url = URL(string: "\(baseURL)/vip/redeem") else { return false }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "code": code,
            "device_id": deviceIdentifier
        ])
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let ok = json["ok"] as? Bool, ok,
               let userDict = json["user"] as? [String: Any],
               let userData = try? JSONSerialization.data(withJSONObject: userDict) {
                self.currentUser = try? JSONDecoder().decode(UserProfile.self, from: userData)
                return true
            }
        } catch {}
        return false
    }
    
    /// UGC 举报 (Apple Guideline 1.2)
    public func reportUgcContent(targetId: String, reason: String) async {
        guard let url = URL(string: "\(baseURL)/ugc/report") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["target_id": targetId, "reason": reason])
        _ = try? await URLSession.shared.data(for: request)
    }
    
    /// 彻底注销账号 (Apple Guideline 5.1.1(v))
    @MainActor
    public func deleteAccount() async {
        guard let url = URL(string: "\(baseURL)/auth/delete-account") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["device_id": deviceIdentifier])
        _ = try? await URLSession.shared.data(for: request)
        self.currentUser = nil
        self.token = ""
    }
}
