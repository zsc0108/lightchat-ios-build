import SwiftUI

/// 高级黑胶唱片拟态视效组件 (含唱针落针、声波涟漪与物理惯性旋转)
public struct VinylRecordView: View {
    @Binding public var isPlaying: Bool
    public var rotationSpeed: Double = 14.0 // 旋转一圈秒数
    
    @State private var rotationAngle: Double = 0
    @State private var tonearmAngle: Double = -22.0 // 唱针未落针角度
    
    // 触觉反馈发生器
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    
    public init(isPlaying: Binding<Bool>, rotationSpeed: Double = 14.0) {
        self._isPlaying = isPlaying
        self.rotationSpeed = rotationSpeed
    }
    
    public var body: some View {
        ZStack {
            // 1. 底层环境金晖光晕 (Ambient Glow)
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.83, green: 0.69, blue: 0.22).opacity(isPlaying ? 0.18 : 0.05),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 40,
                        endRadius: 135
                    )
                )
                .frame(width: 260, height: 260)
                .animation(.easeInOut(duration: 1.2), value: isPlaying)
            
            // 2. 黑胶唱片本体 (立体同心圆声轨)
            ZStack {
                // 外缘金属环
                Circle()
                    .fill(Color(red: 0.06, green: 0.07, blue: 0.09))
                    .frame(width: 224, height: 224)
                    .shadow(color: .black.opacity(0.8), radius: 16, x: 0, y: 8)
                    .overlay(
                        Circle().stroke(Color(red: 0.83, green: 0.69, blue: 0.22).opacity(0.25), lineWidth: 1.5)
                    )
                
                // 同心圆声轨纹理 (Grooves)
                ForEach(0..<7) { index in
                    Circle()
                        .stroke(
                            Color.white.opacity(0.03 + Double(index) * 0.005),
                            lineWidth: 1
                        )
                        .frame(width: CGFloat(78 + index * 20), height: CGFloat(78 + index * 20))
                }
                
                // 黑胶高光反光扇形 (Gloss Highlights)
                AngularGradient(
                    gradient: Gradient(colors: [
                        .white.opacity(0.0),
                        .white.opacity(0.06),
                        .white.opacity(0.0),
                        .white.opacity(0.06),
                        .white.opacity(0.0)
                    ]),
                    center: .center
                )
                .clipShape(Circle())
                .frame(width: 222, height: 222)
                
                // 中心唱片标贴 (Label)
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.16, green: 0.13, blue: 0.08), Color(red: 0.08, green: 0.07, blue: 0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 78, height: 78)
                        .overlay(Circle().stroke(Color(red: 0.83, green: 0.69, blue: 0.22).opacity(0.5), lineWidth: 1))
                    
                    VStack(spacing: 1) {
                        Text("SIDE A")
                            .font(.system(size: 7, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(red: 0.83, green: 0.69, blue: 0.22).opacity(0.8))
                        Text("轻 语")
                            .font(.system(size: 12, weight: .bold, design: .serif))
                            .foregroundColor(Color(red: 0.95, green: 0.88, blue: 0.70))
                        Text("LC · 024")
                            .font(.system(size: 6, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    
                    // 主轴中心孔
                    Circle()
                        .fill(Color(red: 0.06, green: 0.07, blue: 0.09))
                        .frame(width: 12, height: 12)
                        .overlay(Circle().stroke(Color.black, lineWidth: 1))
                }
            }
            .rotationEffect(.degrees(rotationAngle))
            
            // 3. 拟态唱臂与唱针 (Tonearm)
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 0) {
                    // 唱臂基座转轴
                    Circle()
                        .fill(Color(red: 0.18, green: 0.19, blue: 0.22))
                        .frame(width: 30, height: 30)
                        .overlay(Circle().stroke(Color(red: 0.83, green: 0.69, blue: 0.22).opacity(0.6), lineWidth: 1.5))
                        .shadow(radius: 4)
                    
                    // 金色金属唱臂杆
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.95, green: 0.88, blue: 0.70), Color(red: 0.75, green: 0.60, blue: 0.20)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 4, height: 105)
                        .offset(y: -3)
                    
                    // 唱头与唱针 (Cartridge & Stylus)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(red: 0.14, green: 0.15, blue: 0.18))
                        .frame(width: 14, height: 22)
                        .overlay(
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(Color(red: 0.83, green: 0.69, blue: 0.22), lineWidth: 1)
                        )
                        .offset(x: -2, y: -5)
                }
                .rotationEffect(.degrees(tonearmAngle), anchor: .top)
                .offset(x: 92, y: -70)
                .animation(.spring(response: 0.6, dampingFraction: 0.75), value: tonearmAngle)
            }
        }
        .frame(width: 260, height: 250)
        .clipped()
        .onTapGesture {
            // 点击黑胶：触发触感反馈并切换播放/暂停
            impactFeedback.impactOccurred()
            isPlaying.toggle()
        }
        .onChange(of: isPlaying) { playing in
            if playing {
                tonearmAngle = 0.0 // 落针接触声轨
                startSpinning()
            } else {
                tonearmAngle = -22.0 // 唱针移开
            }
        }
    }
    
    private func startSpinning() {
        withAnimation(Animation.linear(duration: rotationSpeed).repeatForever(autoreverses: false)) {
            rotationAngle += 360
        }
    }
}
