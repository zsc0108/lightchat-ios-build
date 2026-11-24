import SwiftUI

/// LightChat iOS 主容器视图 (集成交互式灵动岛、三大主模块切换与 StoreKit 2 订购面板)
public struct MainTabView: View {
    @StateObject private var net = NetworkService.shared
    @StateObject private var storeKit = StoreKitManager.shared
    
    @State private var selectedTab: Int = 0
    @State private var isPlayingVinyl: Bool = true
    @State private var isIslandExpanded: Bool = false
    @State private var showVipSheet: Bool = false
    @State private var pulledSecret: SecretItem? = nil
    @State private var showSendSecretSheet: Bool = false
    @State private var isPulling: Bool = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.05, blue: 0.06).ignoresSafeArea()
            
            VStack(spacing: 0) {
                if selectedTab == 0 {
                    // ── Tab 0: 轻语之境 ──
                    VStack(spacing: 0) {
                        // 1. 顶部导航栏
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("轻语之境")
                                    .font(.system(size: 20, weight: .bold, design: .serif))
                                    .foregroundColor(.white)
                                Text("NO.24 · LATE NIGHT RESONANCE")
                                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                showVipSheet = true
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 11))
                                        .foregroundColor(Color(red: 0.85, green: 0.61, blue: 0.35))
                                    Text(net.currentUser?.isVip == true ? "VIP · \(net.currentUser?.remainingVipDays ?? 30)天" : "开通VIP")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(Color(red: 0.92, green: 0.78, blue: 0.57))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(red: 0.85, green: 0.61, blue: 0.35).opacity(0.14))
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule().stroke(Color(red: 0.85, green: 0.61, blue: 0.35).opacity(0.45), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        // 可自适应滚动的主体区域，彻底杜绝任何小屏 iPhone 上下重叠
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 14) {
                                // 2. 应用内交互式灵动岛中枢 (Dynamic Island Interactive Capsule)
                                VStack {
                                    if isIslandExpanded {
                                        // 灵动岛弹簧展开面板
                                        VStack(spacing: 12) {
                                            HStack {
                                                Circle()
                                                    .fill(Color(red: 0.85, green: 0.61, blue: 0.35))
                                                    .frame(width: 28, height: 28)
                                                    .overlay(Circle().fill(Color.black).frame(width: 8, height: 8))
                                                
                                                VStack(alignment: .leading, spacing: 2) {
                                                    HStack(spacing: 6) {
                                                        Text("LIVE ACTIVITY")
                                                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                                                            .padding(.horizontal, 5)
                                                            .padding(.vertical, 1.5)
                                                            .background(Color(red: 0.85, green: 0.61, blue: 0.35).opacity(0.2))
                                                            .foregroundColor(Color(red: 0.92, green: 0.78, blue: 0.57))
                                                            .cornerRadius(4)
                                                        Text(pulledSecret?.authorName ?? "小青 · 3.2km")
                                                            .font(.system(size: 12, weight: .bold))
                                                            .foregroundColor(.white)
                                                            .lineLimit(1)
                                                    }
                                                    Text(pulledSecret?.content ?? "“今天加班到深夜，走在空无一人的街道上…”")
                                                        .font(.system(size: 11))
                                                        .foregroundColor(.gray)
                                                        .lineLimit(1)
                                                }
                                                Spacer()
                                                Button(action: {
                                                    withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                                                        isIslandExpanded = false
                                                    }
                                                }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.gray)
                                                }
                                            }
                                            
                                            HStack(spacing: 8) {
                                                Button(action: { isPlayingVinyl.toggle() }) {
                                                    Label(isPlayingVinyl ? "暂停声轨" : "继续落针", systemImage: isPlayingVinyl ? "pause.fill" : "play.fill")
                                                        .font(.system(size: 11, weight: .semibold))
                                                        .lineLimit(1)
                                                        .minimumScaleFactor(0.85)
                                                        .frame(maxWidth: .infinity)
                                                        .padding(.vertical, 7)
                                                        .background(Color.white.opacity(0.08))
                                                        .foregroundColor(Color(red: 0.92, green: 0.78, blue: 0.57))
                                                        .cornerRadius(10)
                                                }
                                                
                                                Button(action: {
                                                    Task {
                                                        if let s = try? await net.pullRandomSecret() {
                                                            pulledSecret = s
                                                        }
                                                    }
                                                }) {
                                                    Label("切轨捞取", systemImage: "forward.end.fill")
                                                        .font(.system(size: 11, weight: .semibold))
                                                        .lineLimit(1)
                                                        .minimumScaleFactor(0.85)
                                                        .frame(maxWidth: .infinity)
                                                        .padding(.vertical, 7)
                                                        .background(Color.white.opacity(0.08))
                                                        .foregroundColor(.white)
                                                        .cornerRadius(10)
                                                }
                                                
                                                Button(action: {
                                                    withAnimation {
                                                        isIslandExpanded = false
                                                        selectedTab = 1
                                                    }
                                                }) {
                                                    Label("私聊回应", systemImage: "bubble.right.fill")
                                                        .font(.system(size: 11, weight: .bold))
                                                        .lineLimit(1)
                                                        .minimumScaleFactor(0.85)
                                                        .frame(maxWidth: .infinity)
                                                        .padding(.vertical, 7)
                                                        .background(Color(red: 0.85, green: 0.61, blue: 0.35))
                                                        .foregroundColor(.black)
                                                        .cornerRadius(10)
                                                }
                                            }
                                        }
                                        .padding(14)
                                        .background(.ultraThinMaterial)
                                        .cornerRadius(22)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 22)
                                                .stroke(Color(red: 0.85, green: 0.61, blue: 0.35).opacity(0.45), lineWidth: 1)
                                        )
                                        .padding(.horizontal, 18)
                                    } else {
                                        // 灵动岛紧凑胶囊态
                                        Button(action: {
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                                                isIslandExpanded = true
                                            }
                                        }) {
                                            HStack(spacing: 8) {
                                                Circle()
                                                    .fill(Color(red: 0.85, green: 0.61, blue: 0.35))
                                                    .frame(width: 14, height: 14)
                                                    .overlay(Circle().fill(Color.black).frame(width: 4, height: 4))
                                                Text("今夜 38,421 段轻语正在旋转")
                                                    .font(.system(size: 11, design: .monospaced))
                                                    .foregroundColor(Color.white.opacity(0.9))
                                                    .lineLimit(1)
                                                Image(systemName: "waveform")
                                                    .font(.system(size: 11))
                                                    .foregroundColor(Color(red: 0.85, green: 0.61, blue: 0.35))
                                            }
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 7)
                                            .background(.ultraThinMaterial)
                                            .clipShape(Capsule())
                                            .overlay(
                                                Capsule().stroke(Color(red: 0.85, green: 0.61, blue: 0.35).opacity(0.35), lineWidth: 1)
                                            )
                                        }
                                    }
                                }
                                .padding(.top, 8)
                                
                                // 3. 核心黑胶唱片拟态视效 (严格 250pt 边界裁剪，绝不越界)
                                VinylRecordView(isPlaying: $isPlayingVinyl)
                                    .frame(width: 260, height: 250)
                                    .padding(.vertical, 4)
                                
                                Text("FM 98.4 · 轻触黑胶落针，听见远方灵魂的低语")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color.gray)
                                    .lineLimit(1)
                                
                                // 4. 底部双操作卡片
                                HStack(spacing: 12) {
                                    Button(action: {
                                        showSendSecretSheet = true
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    }) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack {
                                                Image(systemName: "pencil.line")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(Color(red: 0.85, green: 0.61, blue: 0.35))
                                                Spacer()
                                                Text("匿名封存")
                                                    .font(.system(size: 10))
                                                    .foregroundColor(.gray)
                                            }
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("投递轻语")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(.white)
                                                Text("写下心事，刻录声轨")
                                                    .font(.system(size: 10))
                                                    .foregroundColor(.gray)
                                                    .lineLimit(1)
                                            }
                                            Text("今日余 15 次 ↗")
                                                .font(.system(size: 9))
                                                .foregroundColor(.gray)
                                        }
                                        .padding(14)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(.ultraThinMaterial)
                                        .cornerRadius(18)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18)
                                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                        )
                                    }
                                    
                                    Button(action: {
                                        Task {
                                            isPulling = true
                                            defer { isPulling = false }
                                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                            if let secret = try? await net.pullRandomSecret() {
                                                withAnimation(.spring(response: 0.42, dampingFraction: 0.8)) {
                                                    pulledSecret = secret
                                                }
                                            }
                                        }
                                    }) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack {
                                                Image(systemName: "dot.radiowaves.left.and.right")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(Color(red: 0.85, green: 0.61, blue: 0.35))
                                                Spacer()
                                                Text("随机共鸣")
                                                    .font(.system(size: 10))
                                                    .foregroundColor(Color(red: 0.85, green: 0.61, blue: 0.35))
                                            }
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("捞取轻语")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(.white)
                                                Text("轻落唱针，听见低语")
                                                    .font(.system(size: 10))
                                                    .foregroundColor(.gray)
                                                    .lineLimit(1)
                                            }
                                            Text(isPulling ? "正在寻觅声轨..." : "落针聆听 →")
                                                .font(.system(size: 9, weight: .semibold))
                                                .foregroundColor(Color(red: 0.85, green: 0.61, blue: 0.35))
                                        }
                                        .padding(14)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(red: 0.85, green: 0.61, blue: 0.35).opacity(0.1))
                                        .cornerRadius(18)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18)
                                                .stroke(Color(red: 0.85, green: 0.61, blue: 0.35).opacity(0.4), lineWidth: 1)
                                        )
                                    }
                                }
                                .padding(.horizontal, 18)
                                .padding(.bottom, 16)
                            }
                        }
                    }
                    .transition(.opacity)
                } else if selectedTab == 1 {
                    // ── Tab 1: 消息与多媒体私聊 ──
                    ChatCenterView()
                        .transition(.opacity)
                } else {
                    // ── Tab 2: 个人中心与合规设置 ──
                    ProfileCenterView(showVipSheet: $showVipSheet)
                        .transition(.opacity)
                }
                
                // 底部通透毛玻璃导航栏
                HStack {
                    TabItemButton(icon: "record.circle", title: "轻语", isSelected: selectedTab == 0) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) { selectedTab = 0 }
                    }
                    Spacer()
                    TabItemButton(icon: "bubble.left.and.bubble.right", title: "消息", isSelected: selectedTab == 1) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) { selectedTab = 1 }
                    }
                    Spacer()
                    TabItemButton(icon: "person", title: "我的", isSelected: selectedTab == 2) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) { selectedTab = 2 }
                    }
                }
                .padding(.horizontal, 48)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .overlay(
                    Rectangle().frame(height: 0.5).foregroundColor(Color.white.opacity(0.08)),
                    alignment: .top
                )
            }
            
            if let secret = pulledSecret {
                SecretModalView(secret: secret, onDismiss: {
                    withAnimation { pulledSecret = nil }
                }, onLike: {
                    Task { await net.likeSecret(id: secret.id) }
                })
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .sheet(isPresented: $showVipSheet) {
            VipCenterSheetView()
        }
        .sheet(isPresented: $showSendSecretSheet) {
            SendSecretSheet(isPresented: $showSendSecretSheet)
        }
    }
}

struct TabItemButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
            UISelectionFeedbackGenerator().selectionChanged()
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: isSelected ? .bold : .regular))
                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
            }
            .foregroundColor(isSelected ? Color(red: 0.85, green: 0.61, blue: 0.35) : .gray)
        }
    }
}

struct SendSecretSheet: View {
    @Binding var isPresented: Bool
    @State private var text: String = ""
    @State private var isSubmitting: Bool = false
    
    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.09, blue: 0.12).ignoresSafeArea()
            VStack(spacing: 16) {
                HStack {
                    Text("投递轻语心事")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button("取消") { isPresented = false }
                        .foregroundColor(.gray)
                }
                .padding()
                
                TextEditor(text: $text)
                    .padding(12)
                    .background(Color.white.opacity(0.04))
                    .cornerRadius(12)
                    .foregroundColor(.white)
                    .frame(height: 160)
                    .padding(.horizontal)
                
                Button(action: {
                    Task {
                        isSubmitting = true
                        defer { isSubmitting = false }
                        let ok = try? await NetworkService.shared.sendSecret(content: text)
                        if ok == true {
                            isPresented = false
                        }
                    }
                }) {
                    Text(isSubmitting ? "正在刻录..." : "刻录并投递")
                        .font(.system(size: 14, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(Color(red: 0.85, green: 0.61, blue: 0.35))
                        .foregroundColor(.black)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                
                Spacer()
            }
        }
    }
}
