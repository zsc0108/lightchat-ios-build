import Foundation
import StoreKit

/// 基于 Apple StoreKit 2 的现代化应用内购买 (IAP) 管理器
@MainActor
public class StoreKitManager: ObservableObject {
    public static let shared = StoreKitManager()
    
    // 商品 ID 定义（与京东云服务端 APPLE_PRODUCT_MAP 一致）
    public static let productIdentifiers: Set<String> = [
        "com.example.lightchat.vip.month1",
        "com.example.lightchat.vip.month3",
        "com.example.lightchat.vip.month12",
        "com.example.lightchat.vip.automonth"
    ]
    
    @Published public var products: [Product] = []
    @Published public var purchasedProductIDs = Set<String>()
    @Published public var isPurchasing: Bool = false
    @Published public var errorMessage: String?
    
    private var updateListenerTask: Task<Void, Error>? = nil
    
    public init() {
        // 开启全局交易流监听
        updateListenerTask = listenForTransactions()
        
        Task {
            await requestProducts()
            await updateCustomerProductStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    /// 从 Apple 服务器加载最新定价与商品元数据
    public func requestProducts() async {
        do {
            let fetchedProducts = try await Product.products(for: Self.productIdentifiers)
            self.products = fetchedProducts.sorted { $0.price < $1.price }
        } catch {
            self.errorMessage = "加载内购套餐失败: \(error.localizedDescription)"
        }
    }
    
    /// 发起原生 StoreKit 2 购买流程 (触发 Face ID / 密码)
    public func purchase(_ product: Product) async -> Bool {
        isPurchasing = true
        defer { isPurchasing = false }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // 校验 JWS 签名完整性
                let transaction = try checkVerified(verification)
                
                // 向京东云服务器同步 JWS 凭证进行权威校验
                await syncTransactionToServer(verification)
                
                // 提交交易确认完成
                await transaction.finish()
                
                await updateCustomerProductStatus()
                return true
                
            case .userCancelled:
                return false
                
            case .pending:
                // 家长控制或银行延迟审批
                return false
                
            @unknown default:
                return false
            }
        } catch {
            self.errorMessage = "购买失败: \(error.localizedDescription)"
            return false
        }
    }
    
    /// 恢复购买 (Restore Purchases)
    public func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updateCustomerProductStatus()
        } catch {
            self.errorMessage = "恢复购买失败: \(error.localizedDescription)"
        }
    }
    
    /// 监听后台交易变化 (自动续期、家庭共享、退款撤回等)
    private func listenForTransactions() -> Task<Void, Error> {
        return Task {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.syncTransactionToServer(result)
                    await transaction.finish()
                    await self.updateCustomerProductStatus()
                } catch {
                    print("[StoreKit2] 交易核验失败: \(error)")
                }
            }
        }
    }
    
    /// 检查 JWS 安全签名
    nonisolated private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }
    
    /// 更新本地有效订阅状态
    public func updateCustomerProductStatus() async {
        var purchasedIDs = Set<String>()
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if transaction.revocationDate == nil {
                    purchasedIDs.insert(transaction.productID)
                }
            } catch {
                print("[StoreKit2] 权益读取失败: \(error)")
            }
        }
        
        self.purchasedProductIDs = purchasedIDs
    }
    
    /// 将加密 JWS 凭证上传至京东云后端 (/vip/apple/notify) 执行服务端验证
    private func syncTransactionToServer(_ verification: VerificationResult<Transaction>) async {
        let signedJWS = verification.jwsRepresentation
        guard let url = URL(string: "http://117.72.83.144/lightchat/vip/apple/notify") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["signedPayload": signedJWS]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        _ = try? await URLSession.shared.data(for: request)
    }
}
