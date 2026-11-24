import SwiftUI
import StoreKit

/// 原生 StoreKit 2 VIP 会员订购中心 (采用 Apple Ultra-thin 毛玻璃材质)
public struct VipCenterSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var storeKit = StoreKitManager.shared
    @StateObject private var net = NetworkService.shared
    @State private var selectedProductID = "com.example.lightchat.vip.month12"
    @State private var redeemCodeInput: String = ""
    @State private var redeemFeedback: String? = nil
    
    // 会员权益清单
    private let benefits = [
        ("crown.fill", "专属黑胶身份标识", "昵称专享香槟金尊贵声轨徽章与动态气泡"),
        ("waveform.path", "语音轻语时长上限", "免费 60 秒提升至 180 秒无损录音"),
        ("photo.fill", "无损图片上传特权", "支持 30MB 高清原图直传与漫游"),
        ("pin.fill", "专属轻语会话置顶", "可置顶高达 20 个共鸣心事会话"),
        ("eye.slash.fill", "隐身无痕漫步", "查看心事与他人动态不留任何足迹"),
        ("sparkles", "全站纯净免广告", "彻底去除启动页与信息流商业推广")
    ]
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // 背景深空暗曜灰底色
            Color(red: 0.05, green: 0.06, blue: 0.08).ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // 1. 顶部 Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("LightChat VIP")
                                .font(.system(size: 24, weight: .bold, design: .serif))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(red: 0.98, green: 0.92, blue: 0.75), Color(red: 0.83, green: 0.69, blue: 0.22)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            Text("刻录专属心事声轨 · 解锁六项尊享特权")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.gray.opacity(0.8))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    // 2. 四档套餐卡片选择栏
                    if storeKit.products.isEmpty {
                        VStack(spacing: 12) {
                            FallbackPlanCard(id: "com.example.lightchat.vip.month12", title: "年度尊享 VIP", badge: "超值立省 60%", desc: "折合 ¥9.8/月 · 365天黑胶尊享", price: "¥118", isSelected: selectedProductID == "com.example.lightchat.vip.month12") {
                                selectedProductID = "com.example.lightchat.vip.month12"
                            }
                            FallbackPlanCard(id: "com.example.lightchat.vip.month3", title: "季度畅听 VIP", badge: nil, desc: "90天黑胶尊享权益", price: "¥58", isSelected: selectedProductID == "com.example.lightchat.vip.month3") {
                                selectedProductID = "com.example.lightchat.vip.month3"
                            }
                            FallbackPlanCard(id: "com.example.lightchat.vip.month1", title: "月度体验 VIP", badge: nil, desc: "30天独立订购不续费", price: "¥25", isSelected: selectedProductID == "com.example.lightchat.vip.month1") {
                                selectedProductID = "com.example.lightchat.vip.month1"
                            }
                            FallbackPlanCard(id: "com.example.lightchat.vip.automonth", title: "连续包月订阅", badge: nil, desc: "Apple ID 按月自动续订", price: "¥19.8/月", isSelected: selectedProductID == "com.example.lightchat.vip.automonth") {
                                selectedProductID = "com.example.lightchat.vip.automonth"
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(storeKit.products) { product in
                                ProductPlanCard(
                                    product: product,
                                    isSelected: selectedProductID == product.id,
                                    onSelect: {
                                        selectedProductID = product.id
                                        UISelectionFeedbackGenerator().selectionChanged()
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // 3. 会员六大核心权益矩阵
                    VStack(alignment: .leading, spacing: 14) {
                        Text("会员特权全景")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        VStack(spacing: 10) {
                            ForEach(benefits, id: \.1) { icon, title, desc in
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(red: 0.83, green: 0.69, blue: 0.22).opacity(0.15))
                                            .frame(width: 34, height: 34)
                                        Image(systemName: icon)
                                            .font(.system(size: 14))
                                            .foregroundColor(Color(red: 0.83, green: 0.69, blue: 0.22))
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(title)
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(.white)
                                        Text(desc)
                                            .font(.system(size: 11))
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                }
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // 4. 立即开通按钮与免执照私域激活码兑换
                    VStack(spacing: 14) {
                        Button(action: {
                            Task {
                                if let targetProduct = storeKit.products.first(where: { $0.id == selectedProductID }) {
                                    let success = await storeKit.purchase(targetProduct)
                                    if success {
                                        _ = await net.purchaseVipDirect(planId: selectedProductID)
                                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                                        dismiss()
                                    }
                                } else {
                                    let ok = await net.purchaseVipDirect(planId: selectedProductID)
                                    if ok {
                                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                                        dismiss()
                                    }
                                }
                            }
                        }) {
                            HStack {
                                if storeKit.isPurchasing {
                                    ProgressView().tint(.black)
                                } else {
                                    Image(systemName: "crown.fill")
                                    Text("通过 Apple StoreKit 立即开通")
                                        .font(.system(size: 15, weight: .bold))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                LinearGradient(
                                    colors: [Color(red: 0.98, green: 0.92, blue: 0.75), Color(red: 0.83, green: 0.69, blue: 0.22)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.black)
                            .cornerRadius(16)
                            .shadow(color: Color(red: 0.83, green: 0.69, blue: 0.22).opacity(0.3), radius: 10, y: 4)
                        }
                        .disabled(storeKit.isPurchasing)
                        .padding(.horizontal)
                        
                        // 私域激活码 / 卡密兑换 (免营业执照方案)
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("🎟️ 私域激活码 / 卡密兑换")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white)
                                Spacer()
                                Button("填入测试码 LC-VIP-2026") {
                                    redeemCodeInput = "LC-VIP-2026"
                                }
                                .font(.system(size: 10))
                                .foregroundColor(Color(red: 0.83, green: 0.69, blue: 0.22))
                            }
                            HStack(spacing: 8) {
                                TextField("输入16位激活码 (如 LC-VIP-2026)", text: $redeemCodeInput)
                                    .font(.system(size: 12, design: .monospaced))
                                    .padding(.horizontal, 12)
                                    .frame(height: 38)
                                    .background(Color.white.opacity(0.06))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                
                                Button("立即核销") {
                                    Task {
                                        let ok = await net.redeemVipCode(code: redeemCodeInput)
                                        redeemFeedback = ok ? "核销成功！已点亮 12 个月 VIP 尊享特权" : "激活码无效或已被使用"
                                        if ok {
                                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                                            try? await Task.sleep(nanoseconds: 700_000_000)
                                            dismiss()
                                        }
                                    }
                                }
                                .font(.system(size: 12, weight: .bold))
                                .padding(.horizontal, 14)
                                .frame(height: 38)
                                .background(Color(red: 0.83, green: 0.69, blue: 0.22).opacity(0.2))
                                .foregroundColor(Color(red: 0.98, green: 0.92, blue: 0.75))
                                .cornerRadius(10)
                            }
                            if let fb = redeemFeedback {
                                Text(fb)
                                    .font(.system(size: 11))
                                    .foregroundColor(Color(red: 0.83, green: 0.69, blue: 0.22))
                            }
                        }
                        .padding(14)
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // 恢复购买
                        Button(action: {
                            Task {
                                await storeKit.restorePurchases()
                                await net.autoDeviceLogin()
                            }
                        }) {
                            Text("恢复已购买项目 (Restore Purchases)")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // 5. 苹果官方强制合规协议跳转 (Guideline 3.1.1 & Guideline 1.2)
                    HStack(spacing: 16) {
                        Link("用户服务协议 (EULA)", destination: URL(string: "http://117.72.83.144/lightchat/terms")!)
                        Text("·").foregroundColor(.gray)
                        Link("隐私保护政策", destination: URL(string: "http://117.72.83.144/lightchat/privacy")!)
                    }
                    .font(.system(size: 11))
                    .foregroundColor(Color(red: 0.83, green: 0.69, blue: 0.22))
                    .padding(.bottom, 24)
                }
            }
        }
    }
}

// MARK: - 套餐选项单卡
struct ProductPlanCard: View {
    let product: Product
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(product.displayName)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        if product.id.contains("month12") {
                            Text("超值立省")
                                .font(.system(size: 9, weight: .bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red.opacity(0.85))
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        }
                    }
                    Text(product.description)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(product.displayPrice)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.83, green: 0.69, blue: 0.22))
                    if let subscription = product.subscription {
                        Text(subscription.subscriptionPeriod.unit == .month ? "/月" : "/年")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    }
                }
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? Color(red: 0.83, green: 0.69, blue: 0.22) : .gray.opacity(0.5))
                    .padding(.leading, 6)
            }
            .padding(14)
            .background(.ultraThinMaterial)
            .background(isSelected ? Color(red: 0.83, green: 0.69, blue: 0.22).opacity(0.12) : Color.clear)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color(red: 0.83, green: 0.69, blue: 0.22) : Color.white.opacity(0.08), lineWidth: isSelected ? 1.5 : 1)
            )
        }
    }
}

struct FallbackPlanCard: View {
    let id: String
    let title: String
    let badge: String?
    let desc: String
    let price: String
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(title)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        if let b = badge {
                            Text(b)
                                .font(.system(size: 9, weight: .bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red.opacity(0.85))
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        }
                    }
                    Text(desc)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                Spacer()
                Text(price)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.83, green: 0.69, blue: 0.22))
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? Color(red: 0.83, green: 0.69, blue: 0.22) : .gray.opacity(0.5))
                    .padding(.leading, 6)
            }
            .padding(14)
            .background(.ultraThinMaterial)
            .background(isSelected ? Color(red: 0.83, green: 0.69, blue: 0.22).opacity(0.12) : Color.clear)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color(red: 0.83, green: 0.69, blue: 0.22) : Color.white.opacity(0.08), lineWidth: isSelected ? 1.5 : 1)
            )
        }
    }
}
