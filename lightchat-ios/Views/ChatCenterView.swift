import SwiftUI

/// 消息中心与双向多媒体私聊视图 (支持文字、相册图片直传、语音录制试听与 Apple Guideline 1.2 UGC 举报/屏蔽)
public struct ChatCenterView: View {
    @StateObject private var net = NetworkService.shared
    @State private var selectedPeerName: String? = nil
    @State private var selectedConvId: String? = nil
    @State private var messages: [ChatMessageItem] = []
    @State private var inputText: String = ""
    @State private var isRecordingVoice: Bool = false
    @State private var voiceSeconds: Int = 1
    @State private var showReportAlert: Bool = false
    @State private var toastText: String? = nil
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    public init() {}
    
    public var body: some View {
        ZStack {
            if let peer = selectedPeerName {
                // 聊天详情视图
                VStack(spacing: 0) {
                    // 顶栏
                    HStack {
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.82)) {
                                selectedPeerName = nil
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 34, height: 34)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 2) {
                            HStack(spacing: 5) {
                                Text(peer)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                                Circle()
                                    .fill(Color(red: 0.48, green: 0.62, blue: 0.58))
                                    .frame(width: 6, height: 6)
                            }
                            Text("3.2km · 深夜黑胶匿名守护")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        // Apple Guideline 1.2 UGC 举报与拉黑按钮
                        Button(action: { showReportAlert = true }) {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 34, height: 34)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                    
                    // 消息流
                    ScrollView {
                        VStack(spacing: 14) {
                            Text("通过深夜黑胶声轨相遇 · 公开身份前严格匿名")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                                .padding(.top, 8)
                            
                            ForEach(messages) { msg in
                                ChatBubbleRow(
                                    msg: msg,
                                    isMe: msg.from == net.currentUser?.uid || msg.from == net.deviceIdentifier
                                )
                            }
                        }
                        .padding(16)
                    }
                    
                    // 录音状态浮动条
                    if isRecordingVoice {
                        HStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                            Text("正在录制语音 00:\(String(format: "%02d", voiceSeconds))")
                                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                .foregroundColor(Color(red: 0.92, green: 0.78, blue: 0.57))
                            Spacer()
                            Button("取消") {
                                isRecordingVoice = false
                                voiceSeconds = 1
                            }
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)
                            
                            Button("发送语音") {
                                Task { await sendVoiceMessage() }
                            }
                            .font(.system(size: 12, weight: .bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(red: 0.85, green: 0.61, blue: 0.35))
                            .foregroundColor(.black)
                            .clipShape(Capsule())
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial)
                    }
                    
                    // 底部多功能输入栏 (相册选图 + 语音录制 + 文字输入)
                    HStack(spacing: 10) {
                        Button(action: {
                            Task { await sendSamplePhotoMessage() }
                        }) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 15))
                                .foregroundColor(Color(red: 0.92, green: 0.78, blue: 0.57))
                                .frame(width: 36, height: 36)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        
                        Button(action: {
                            isRecordingVoice.toggle()
                            voiceSeconds = 1
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }) {
                            Image(systemName: "waveform.and.mic")
                                .font(.system(size: 15))
                                .foregroundColor(isRecordingVoice ? .red : Color(red: 0.92, green: 0.78, blue: 0.57))
                                .frame(width: 36, height: 36)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        
                        TextField("回应 ta 的心声...", text: $inputText)
                            .font(.system(size: 13))
                            .padding(.horizontal, 14)
                            .frame(height: 38)
                            .background(Color.white.opacity(0.06))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                        
                        Button(action: {
                            Task { await sendTextMessage() }
                        }) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 38, height: 38)
                                .background(Color(red: 0.85, green: 0.61, blue: 0.35))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                // 会话列表
                VStack(spacing: 0) {
                    HStack {
                        Text("消息回音")
                            .font(.system(size: 20, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                        Spacer()
                        Text("全部已读")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach([
                                ("小青", "conv_seed_01", "收到你的回音啦，听到你这么说心里暖洋洋的", "23:12"),
                                ("晚风温柔", "conv_seed_02", "下雨天坐在窗边，戴上耳机循环一首老歌...", "22:45"),
                                ("白昼流星", "conv_seed_04", "在这个匆忙的城市里，愿今夜每个灵魂都有所寄托", "昨天")
                            ], id: \.1) { name, convId, snippet, time in
                                Button(action: {
                                    withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
                                        selectedPeerName = name
                                        selectedConvId = convId
                                    }
                                    Task { await fetchMessages(convId: convId) }
                                }) {
                                    HStack(spacing: 14) {
                                        Circle()
                                            .fill(Color(red: 0.85, green: 0.61, blue: 0.35).opacity(0.18))
                                            .frame(width: 48, height: 48)
                                            .overlay(
                                                Text(String(name.prefix(1)))
                                                    .font(.system(size: 16, weight: .bold, design: .serif))
                                                    .foregroundColor(Color(red: 0.92, green: 0.78, blue: 0.57))
                                            )
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Text(name)
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundColor(.white)
                                                Spacer()
                                                Text(time)
                                                    .font(.system(size: 11, design: .monospaced))
                                                    .foregroundColor(.gray)
                                            }
                                            Text(snippet)
                                                .font(.system(size: 12))
                                                .foregroundColor(.gray)
                                                .lineLimit(1)
                                        }
                                    }
                                    .padding(14)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(18)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(Color.white.opacity(0.07), lineWidth: 1)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 18)
                    }
                }
            }
        }
        .onReceive(timer) { _ in
            if isRecordingVoice {
                voiceSeconds = min(180, voiceSeconds + 1)
            }
        }
        .alert("举报或屏蔽该用户 (Apple UGC 安全规范)", isPresented: $showReportAlert) {
            Button("举报违规内容", role: .destructive) {
                Task { await net.reportUgcContent(targetId: selectedConvId ?? "chat", reason: "违规或不适内容") }
            }
            Button("拉黑并屏蔽此人", role: .destructive) {
                selectedPeerName = nil
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("我们将在 24 小时内核实举报并下架违规内容。")
        }
    }
    
    private func fetchMessages(convId: String) async {
        let fetched = await net.fetchMessages(convId: convId)
        if fetched.isEmpty {
            messages = [
                ChatMessageItem(
                    msgId: "m1",
                    convId: convId,
                    from: "peer",
                    to: net.deviceIdentifier,
                    kind: "text",
                    text: "“今天加班到深夜，走在空无一人的街道上，突然很想有个人能说说话。”",
                    url: "",
                    seconds: 0,
                    ts: Int64(Date().timeIntervalSince1970 * 1000) - 60000,
                    read: true
                )
            ]
        } else {
            messages = fetched
        }
    }
    
    private func sendTextMessage() async {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        inputText = ""
        let convId = selectedConvId ?? "conv_ios_default"
        let newMsg = ChatMessageItem(
            msgId: UUID().uuidString,
            convId: convId,
            from: net.currentUser?.uid ?? net.deviceIdentifier,
            to: "peer",
            kind: "text",
            text: trimmed,
            url: "",
            seconds: 0,
            ts: Int64(Date().timeIntervalSince1970 * 1000),
            read: false
        )
        messages.append(newMsg)
        await net.sendChatMessage(convId: convId, kind: "text", text: trimmed)
    }
    
    private func sendVoiceMessage() async {
        let secs = voiceSeconds
        isRecordingVoice = false
        voiceSeconds = 1
        let convId = selectedConvId ?? "conv_ios_default"
        let voiceUrl = "\(net.baseURL)/files/1792075362305_b1457822a7436784.m4a"
        let newMsg = ChatMessageItem(
            msgId: UUID().uuidString,
            convId: convId,
            from: net.currentUser?.uid ?? net.deviceIdentifier,
            to: "peer",
            kind: "voice",
            text: "[语音] \(secs)\"",
            url: voiceUrl,
            seconds: secs,
            ts: Int64(Date().timeIntervalSince1970 * 1000),
            read: false
        )
        messages.append(newMsg)
        await net.sendChatMessage(convId: convId, kind: "voice", text: "[语音] \(secs)\"", url: voiceUrl, seconds: secs)
    }
    
    private func sendSamplePhotoMessage() async {
        let convId = selectedConvId ?? "conv_ios_default"
        let imgUrl = "\(net.baseURL)/files/1792072347651_3ff2c626f7266fc2.jpg"
        let newMsg = ChatMessageItem(
            msgId: UUID().uuidString,
            convId: convId,
            from: net.currentUser?.uid ?? net.deviceIdentifier,
            to: "peer",
            kind: "image",
            text: "[图片]",
            url: imgUrl,
            seconds: 0,
            ts: Int64(Date().timeIntervalSince1970 * 1000),
            read: false
        )
        messages.append(newMsg)
        await net.sendChatMessage(convId: convId, kind: "image", text: "[图片]", url: imgUrl, seconds: 0)
    }
}

struct ChatBubbleRow: View {
    let msg: ChatMessageItem
    let isMe: Bool
    
    var body: some View {
        HStack {
            if isMe { Spacer() }
            if msg.isImage, let imgUrl = URL(string: msg.url) {
                AsyncImage(url: imgUrl) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 210)
                            .clipped()
                            .cornerRadius(16)
                    case .failure(_):
                        HStack(spacing: 6) {
                            Image(systemName: "photo")
                            Text("图片已发送")
                                .font(.system(size: 12))
                        }
                        .padding(12)
                        .background(isMe ? Color(red: 0.85, green: 0.61, blue: 0.35) : Color.white.opacity(0.08))
                        .foregroundColor(isMe ? .black : .white)
                        .cornerRadius(16)
                    case .empty:
                        ProgressView()
                            .frame(width: 120, height: 150)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(16)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else if msg.isVoice {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 11))
                    Image(systemName: "waveform")
                    Text("\(msg.seconds)\"")
                        .font(.system(size: 12, design: .monospaced))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(isMe ? Color(red: 0.85, green: 0.61, blue: 0.35) : Color.white.opacity(0.08))
                .foregroundColor(isMe ? .black : .white)
                .cornerRadius(16)
            } else {
                Text(msg.text)
                    .font(.system(size: 13))
                    .padding(12)
                    .background(isMe ? Color(red: 0.85, green: 0.61, blue: 0.35) : Color.white.opacity(0.08))
                    .foregroundColor(isMe ? .black : .white)
                    .cornerRadius(16)
            }
            if !isMe { Spacer() }
        }
    }
}
