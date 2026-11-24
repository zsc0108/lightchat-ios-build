import SwiftUI

/// 个人中心与合规设置视图 (含 StoreKit 2 VIP 黑金卡、免短信绑定手机、卡密兑换、EULA/隐私政策与账号注销)
public struct ProfileCenterView: View {
    @StateObject private var net = NetworkService.shared
    @Binding public var showVipSheet: Bool
    
    @State private var showBindPhoneSheet: Bool = false
    @State private var bindPhoneInput: String = ""
    @State private var bindPinInput: String = ""
    @State private var showDeleteConfirm: Bool = false
    @State private var statusMessage: String? = nil
    
    public init(showVipSheet: Binding<Bool>) {
        self._showVipSheet = showVipSheet
    }
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                // 1. 旅人个人信息头部
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.85, green: 0.61, blue: 0.35).opacity(0.2))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Circle().stroke(Color(red: 0.85, green: 0.61, blue: 0.35).opacity(0.5), lineWidth: 1.5)
                            )
                        Text(String((net.currentUser?.nickname ?? "星").prefix(1)))
                            .font(.system(size: 22, weight: .bold, design: .serif))
                            .foregroundColor(Color(red: 0.92, green: 0.78, blue: 0.57))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(net.currentUser?.nickname ?? "星河旅人")
                                .font(.system(size: 18, weight: .bold, design: .serif))
                                .foregroundColor(.white)
                            
                            Text(net.currentUser?.isVip == true ? "VIP尊享" : "Lv.3 倾听者")
                                .font(.system(size: 10, weight: .semibold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color(red: 0.85, green: 0.61, blue: 0.35).opacity(0.2))
                                .foregroundColor(Color(red: 0.92, green: 0.78, blue: 0.57))
                                .clipShape(Capsule())
                        }
                        Text(net.currentUser?.signature ?? "“在喧嚣的人间，寻一处安静的轻语”")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.top, 12)
                
                // 2. StoreKit 2 黑胶尊享 VIP 会员黑金卡片
                Button(action: { showVipSheet = true }) {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.85, green: 0.61, blue: 0.35).opacity(0.2))
                                .frame(width: 44, height: 44)
                            Image(systemName: "crown.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Color(red: 0.92, green: 0.78, blue: 0.57))
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 6) {
                                Text("轻语黑胶尊享 VIP")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                if let user = net.currentUser, user.isVip {
                                    Text("剩 \(user.remainingVipDays) 天")
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 1.5)
                                        .background(Color.green.opacity(0.2))
                                        .foregroundColor(.green)
                                        .cornerRadius(6)
                                }
                            }
                            Text("180s 超长语音 · 30MB 原图 · 隐身访问 · 免广告")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text(net.currentUser?.isVip == true ? "续费" : "立即开启")
                            .font(.system(size: 11, weight: .bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(red: 0.85, green: 0.61, blue: 0.35))
                            .foregroundColor(.black)
                            .clipShape(Capsule())
                    }
                    .padding(16)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(red: 0.85, green: 0.61, blue: 0.35).opacity(0.45), lineWidth: 1)
                    )
                }
                
                // 3. 免短信 0 资费手机号与设备绑定卡片
                HStack(spacing: 12) {
                    Image(systemName: "iphone.radiowaves.left.and.right")
                        .font(.system(size: 18))
                        .foregroundColor(Color(red: 0.92, green: 0.78, blue: 0.57))
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(12)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text("手机号多端同步绑定")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                            Text(net.currentUser?.isPhoneBound == true ? "已绑定" : "设备直登")
                                .font(.system(size: 9, design: .monospaced))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 1.5)
                                .background(Color.white.opacity(0.08))
                                .foregroundColor(Color(red: 0.92, green: 0.78, blue: 0.57))
                                .cornerRadius(6)
                        }
                        Text(net.currentUser?.phone?.isEmpty == false ? "已绑定: \(net.currentUser!.phone!)" : "设备码: \(net.deviceIdentifier)")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button("绑定手机") {
                        showBindPhoneSheet = true
                    }
                    .font(.system(size: 11, weight: .semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.08))
                    .foregroundColor(Color(red: 0.92, green: 0.78, blue: 0.57))
                    .clipShape(Capsule())
                }
                .padding(16)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                
                // 4. Apple 审核合规：服务协议 (EULA)、隐私政策与彻底注销账号 (Guideline 1.2 & 5.1.1(v))
                VStack(spacing: 0) {
                    Link(destination: URL(string: "http://117.72.83.144/lightchat/terms")!) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(Color(red: 0.92, green: 0.78, blue: 0.57))
                            Text("用户服务协议与最终用户许可协议 (EULA)")
                                .font(.system(size: 13))
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                        .padding(15)
                    }
                    
                    Divider().background(Color.white.opacity(0.08))
                    
                    Link(destination: URL(string: "http://117.72.83.144/lightchat/privacy")!) {
                        HStack {
                            Image(systemName: "hand.raised")
                                .foregroundColor(Color(red: 0.92, green: 0.78, blue: 0.57))
                            Text("隐私保护政策与权限清单")
                                .font(.system(size: 13))
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                        .padding(15)
                    }
                    
                    Divider().background(Color.white.opacity(0.08))
                    
                    Button(action: { showDeleteConfirm = true }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("彻底注销账号与清除云端数据")
                                .font(.system(size: 13))
                                .foregroundColor(.red)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                        .padding(15)
                    }
                }
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                
                if let msg = statusMessage {
                    Text(msg)
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.92, green: 0.78, blue: 0.57))
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 24)
        }
        .sheet(isPresented: $showBindPhoneSheet) {
            VStack(spacing: 16) {
                Text("免短信绑定手机号")
                    .font(.system(size: 17, weight: .bold))
                    .padding(.top, 20)
                Text("输入11位手机号与4位安全码即可绑定当前设备并开启多端云漫游")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                TextField("输入11位手机号码", text: $bindPhoneInput)
                    .keyboardType(.numberPad)
                    .padding(12)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(12)
                    .padding(.horizontal)
                
                SecureField("设置4位数字安全码 (可选)", text: $bindPinInput)
                    .keyboardType(.numberPad)
                    .padding(12)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(12)
                    .padding(.horizontal)
                
                Button(action: {
                    Task {
                        let ok = await net.bindPhone(phone: bindPhoneInput, pinCode: bindPinInput)
                        statusMessage = ok ? "手机号绑定成功，已开启多端漫游" : "请输入正确的11位手机号"
                        if ok { showBindPhoneSheet = false }
                    }
                }) {
                    Text("确认绑定")
                        .font(.system(size: 14, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(Color(red: 0.85, green: 0.61, blue: 0.35))
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                Spacer()
            }
            .preferredColorScheme(.dark)
        }
        .alert("确认彻底注销账号？", isPresented: $showDeleteConfirm) {
            Button("确认注销并抹除数据", role: .destructive) {
                Task {
                    await net.deleteAccount()
                    statusMessage = "账号及云端关联数据已彻底注销清除"
                }
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("根据 Apple Guideline 5.1.1(v) 规范，注销后您的云端轻语、私聊记录及账号资料将立即永久清除且不可恢复。")
        }
    }
}
