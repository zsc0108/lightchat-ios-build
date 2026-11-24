import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - 动态岛与实时活动属性载荷
public struct VinylActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var isPlaying: Bool
        public var title: String
        public var authorName: String
        public var elapsedSeconds: Int
        public var totalSeconds: Int
        
        public init(isPlaying: Bool, title: String, authorName: String, elapsedSeconds: Int, totalSeconds: Int) {
            self.isPlaying = isPlaying
            self.title = title
            self.authorName = authorName
            self.elapsedSeconds = elapsedSeconds
            self.totalSeconds = totalSeconds
        }
    }
    
    public var secretId: String
    
    public init(secretId: String) {
        self.secretId = secretId
    }
}

// MARK: - 动态岛 UI 组件定义
public struct VinylLiveActivityWidget: Widget {
    public init() {}
    
    public var body: some WidgetConfiguration {
        ActivityConfiguration(for: VinylActivityAttributes.self) { context in
            // 锁屏界面 (Lock Screen & Banner)
            LockScreenVinylView(context: context)
                .activityBackgroundTint(Color.black.opacity(0.85))
                .activitySystemActionForegroundColor(Color(red: 0.83, green: 0.69, blue: 0.22)) // 香槟金
        } dynamicIsland: { context in
            DynamicIsland {
                // 1. 动态岛展开状态 (Expanded)
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 8) {
                        // 微型旋转黑胶唱片
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.12, green: 0.13, blue: 0.16))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(Color(red: 0.83, green: 0.69, blue: 0.22).opacity(0.4), lineWidth: 1)
                                )
                            Circle()
                                .fill(Color(red: 0.83, green: 0.69, blue: 0.22))
                                .frame(width: 14, height: 14)
                        }
                        .rotationEffect(.degrees(context.state.isPlaying ? 360 : 0))
                        .animation(context.state.isPlaying ? Animation.linear(duration: 4).repeatForever(autoreverses: false) : .default, value: context.state.isPlaying)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.state.title)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                            Text(context.state.authorName)
                                .font(.system(size: 11))
                                .foregroundColor(Color.gray)
                        }
                    }
                    .padding(.leading, 4)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    // 声波跳动动效
                    HStack(spacing: 3) {
                        ForEach(0..<4) { index in
                            RoundedRectangle(cornerRadius: 1.5)
                                .fill(Color(red: 0.83, green: 0.69, blue: 0.22))
                                .frame(width: 3, height: context.state.isPlaying ? CGFloat([14, 22, 10, 18][index]) : 4)
                                .animation(context.state.isPlaying ? Animation.easeInOut(duration: 0.4).repeatForever().delay(Double(index) * 0.1) : .default, value: context.state.isPlaying)
                        }
                    }
                    .padding(.trailing, 8)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    // 底部声轨进度条与状态
                    HStack {
                        Text("\(context.state.elapsedSeconds)\"")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.gray)
                        
                        ProgressView(value: Double(context.state.elapsedSeconds), total: Double(max(1, context.state.totalSeconds)))
                            .tint(Color(red: 0.83, green: 0.69, blue: 0.22))
                        
                        Text("\(context.state.totalSeconds)\"")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 4)
                }
            } compactLeading: {
                // 2. 动态岛常态收起左侧 (Compact Leading)
                ZStack {
                    Circle()
                        .fill(Color(red: 0.12, green: 0.13, blue: 0.16))
                        .frame(width: 18, height: 18)
                        .overlay(Circle().stroke(Color(red: 0.83, green: 0.69, blue: 0.22), lineWidth: 0.8))
                    Circle()
                        .fill(Color(red: 0.83, green: 0.69, blue: 0.22))
                        .frame(width: 6, height: 6)
                }
            } compactTrailing: {
                // 3. 动态岛常态收起右侧 (Compact Trailing)
                HStack(spacing: 2) {
                    Image(systemName: "waveform")
                        .font(.system(size: 10))
                        .foregroundColor(Color(red: 0.83, green: 0.69, blue: 0.22))
                    Text("\(context.state.totalSeconds - context.state.elapsedSeconds)s")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color(red: 0.83, green: 0.69, blue: 0.22))
                }
            } minimal: {
                // 4. 多任务极简圆球 (Minimal)
                Circle()
                    .fill(Color(red: 0.83, green: 0.69, blue: 0.22))
                    .frame(width: 12, height: 12)
            }
        }
    }
}

// MARK: - 锁屏大卡片视图
struct LockScreenVinylView: View {
    let context: ActivityViewContext<VinylActivityAttributes>
    
    var body: some View {
        HStack(spacing: 14) {
            // 黑胶拟态盘
            ZStack {
                Circle()
                    .fill(Color(red: 0.08, green: 0.09, blue: 0.12))
                    .frame(width: 56, height: 56)
                    .overlay(Circle().stroke(Color(red: 0.83, green: 0.69, blue: 0.22).opacity(0.3), lineWidth: 1))
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    .frame(width: 42, height: 42)
                Circle()
                    .fill(Color(red: 0.83, green: 0.69, blue: 0.22))
                    .frame(width: 16, height: 16)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(context.state.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Text("今夜声轨")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(red: 0.83, green: 0.69, blue: 0.22))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(red: 0.83, green: 0.69, blue: 0.22).opacity(0.15))
                        .cornerRadius(6)
                }
                
                Text("来自 \(context.state.authorName) 的低语倾诉")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                ProgressView(value: Double(context.state.elapsedSeconds), total: Double(max(1, context.state.totalSeconds)))
                    .tint(Color(red: 0.83, green: 0.69, blue: 0.22))
            }
        }
        .padding(14)
    }
}
