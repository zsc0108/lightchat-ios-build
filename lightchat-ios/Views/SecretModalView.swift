import SwiftUI

/// 捞取到的心事轻语展示卡片 (毛玻璃 + 黑胶声轨试听 + 匿名共鸣)
public struct SecretModalView: View {
    public let secret: SecretItem
    public let onDismiss: () -> Void
    public let onLike: () -> Void
    
    @State private var isPlayingVoice: Bool = false
    @State private var hasLiked: Bool = false
    @State private var likesCount: Int = 0
    
    public init(secret: SecretItem, onDismiss: @escaping () -> Void, onLike: @escaping () -> Void) {
        self.secret = secret
        self.onDismiss = onDismiss
        self.onLike = onLike
        self._likesCount = State(initialValue: secret.likes)
    }
    
    public var body: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
                .onTapGesture { onDismiss() }
            
            VStack(spacing: 18) {
                // 顶部声轨标签
                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color(red: 0.83, green: 0.69, blue: 0.22))
                            .frame(width: 6, height: 6)
                        Text(secret.meta ?? "SIDE A · 今夜声轨 · 3.2km")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(Color(red: 0.83, green: 0.69, blue: 0.22))
                    }
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.gray)
                    }
                }
                
                // 倾诉文字正文
                Text(secret.content)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(white: 0.92))
                    .lineSpacing(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
                
                // 录音语音条 (若存在)
                if let voiceUrl = secret.voiceUrl, !voiceUrl.isEmpty {
                    Button(action: {
                        isPlayingVoice.toggle()
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: isPlayingVoice ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 26))
                                .foregroundColor(Color(red: 0.83, green: 0.69, blue: 0.22))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("点击聆听心事录音")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white)
                                Text("\(secret.seconds) 秒声轨")
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Image(systemName: "waveform")
                                .foregroundColor(Color(red: 0.83, green: 0.69, blue: 0.22).opacity(0.8))
                        }
                        .padding(12)
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0.83, green: 0.69, blue: 0.22).opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                
                // 底部作者信息与互动
                HStack {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 28, height: 28)
                            .overlay(
                                Text(String(secret.authorName.prefix(1)))
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                            )
                        VStack(alignment: .leading, spacing: 1) {
                            Text(secret.authorName)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                            Text(secret.formattedDate)
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    // 共鸣送心
                    Button(action: {
                        guard !hasLiked else { return }
                        hasLiked = true
                        likesCount += 1
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        onLike()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: hasLiked ? "heart.fill" : "heart")
                                .foregroundColor(hasLiked ? .red : .gray)
                            Text("\(likesCount)")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(hasLiked ? .red : .gray)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(20)
                    }
                }
            }
            .padding(20)
            .background(.ultraThinMaterial)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color(red: 0.83, green: 0.69, blue: 0.22).opacity(0.35), lineWidth: 1)
            )
            .padding(.horizontal, 28)
            .shadow(color: .black.opacity(0.5), radius: 25, y: 15)
        }
    }
}
