import SwiftUI

@main
public struct LightChatApp: App {
    @StateObject private var storeKit = StoreKitManager.shared
    @StateObject private var net = NetworkService.shared
    
    public init() {
        // 全局外观配置
        configureAppearance()
    }
    
    public var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.dark) // 强制沉浸黑夜黑胶风格
                .environmentObject(storeKit)
                .environmentObject(net)
        }
    }
    
    private func configureAppearance() {
        // 配置全局导航与标签栏毛玻璃通透材质
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
    }
}
