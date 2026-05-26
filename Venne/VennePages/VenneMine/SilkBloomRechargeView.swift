import SwiftUI
import StoreKit
import Combine

struct SilkBloomRechargeView: View {
    @Environment(\.crystalBlushRouter) private var silkBloomRouter
    @EnvironmentObject private var roseMistOverlayCenter: RoseMistOverlayCenter
    @EnvironmentObject private var silkBloomIAPManager: SilkBloomRechargeIAPManager

    @State private var silkBloomSelectedPackageID: String?
    @State private var silkBloomCurrentUser: BlushBloomUserModel?

    var body: some View {
        ZStack(alignment: .bottom) {
            GlowMuseTheme.blushBloomPrimaryText
                .ignoresSafeArea()
            ZStack{
                
                VStack{
                    ZStack{
                        RougeRibbonGuideBackground()
                            .clipShape(CrystalBlushUnevenRoundedRectangle(bottomLeadingRadius: 52))
                            .ignoresSafeArea()
                        VStack(spacing: 0){
                            HStack(spacing: 12) {
                                Button {
                                    silkBloomRouter?.pop()
                                } label: {
                                    Image("VENNECNavBack")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 52, height: 52)
                                }
                                .buttonStyle(.plain)

                                Text("MY WALLET")
                                    .font(GlowMuseTheme.blushBloomSerifFont(size: 16, weight: .black))
                                    .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                                Spacer()
                            }
                            .padding(.top, 60)
                            .padding(.bottom, 10)
                            .padding(.horizontal, 20)
                            ScrollView(showsIndicators: false) {
                                VStack(alignment: .leading, spacing: 0) {
                                    
                                    silkBloomWalletCard
                                        .padding(.top, 12)

                                    LazyVGrid(
                                        columns: [
                                            GridItem(.flexible(), spacing: 12),
                                            GridItem(.flexible(), spacing: 12)
                                        ],
                                        spacing: 12
                                    ) {
                                        ForEach(silkBloomRechargeProducts) { silkBloomPackage in
                                            silkBloomPackageCard(silkBloomPackage)
                                        }
                                    }
                                    .padding(.top, 20)
                                    .padding(.bottom, 120)
                                }
                                .padding(.horizontal, 18)
                            }
                        }
                    }.clipShape(CrystalBlushUnevenRoundedRectangle(bottomLeadingRadius: 52))
                        .ignoresSafeArea()
                    
                    
                    VStack {
                        PetalLuxeButton(title: "RECHARGE", style: .primary, height: 48) {
                            silkBloomStartRecharge()
                        }
                            .padding(.horizontal, 18)
                            .padding(.top, 14)
                            .padding(.bottom, 20)
                    }
                    .frame(maxWidth: .infinity)
                    .background(GlowMuseTheme.blushBloomPrimaryText)
                }
                
            }

            

            
        }
        .onAppear {
            silkBloomSelectedPackageID = silkBloomRechargeProducts.first?.silkBloomProductKeyID
            silkBloomLoadCurrentUser()
            silkBloomIAPManager.silkBloomFetchProducts()
        }
    }

    private var silkBloomWalletCard: some View {
        Image("VENNEWalletBg")
            .resizable()
            .frame(height: 92)
            .overlay(
                HStack(spacing: 0) {
                    Image("VENNEDiamond")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .padding(.leading, 28)
                        .padding(.trailing, 48)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("MY WALLET")
                            .font(GlowMuseTheme.blushBloomSerifFont(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                        Text("\(silkBloomCurrentUser?.blushBloomCoinCount ?? 0)")
                            .font(GlowMuseTheme.blushBloomSerifFont(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .padding(.leading, 14)

                    Spacer()

                    
                }
            )
    }

    private func silkBloomPackageCard(_ silkBloomPackage: SilkBloomRechargePackage) -> some View {
        let silkBloomSelected = silkBloomSelectedPackageID == silkBloomPackage.id

        return Button(action: {
            silkBloomSelectedPackageID = silkBloomPackage.id
        }) {
            VStack(spacing: 12) {
                Text("\(silkBloomPackage.silkBloomCoinCount)")
                    .font(GlowMuseTheme.blushBloomBodyFont(size: 18))
                    .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)

                Text("\(silkBloomPackage.silkBloomPriceText)")
                    .font(GlowMuseTheme.blushBloomSerifFont(size: 18, weight: .bold))
                    .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 94)
            .background(Color.white.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(1)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        silkBloomSelected
                        ? AnyShapeStyle(GlowMuseTheme.velvetAuraAccentGradient)
                        : AnyShapeStyle(Color.clear)
                    )
            )
            
        }
        .buttonStyle(.plain)
    }

    private func silkBloomLoadCurrentUser() {
        guard let silkBloomCurrentUserID = SilkBloomLoginSessionStore.currentUserID else {
            silkBloomCurrentUser = nil
            return
        }

        do {
            silkBloomCurrentUser = try RadiantDewLocalDataCenter.shared.radiantDewUsers.read(id: silkBloomCurrentUserID)
        } catch {
            roseMistOverlayCenter.showToast("Wallet data failed to load.", style: .error)
        }
    }

    private func silkBloomStartRecharge() {
        guard let silkBloomSelectedPackageID else {
            roseMistOverlayCenter.showToast("Please select a package.", style: .normal)
            return
        }

        roseMistOverlayCenter.showLoading()
        silkBloomIAPManager.silkBloomRecharge(productKeyID: silkBloomSelectedPackageID) { silkBloomResult in
            roseMistOverlayCenter.hideLoading()

            switch silkBloomResult {
            case .success(let silkBloomCoins):
                silkBloomAddCoins(silkBloomCoins)
            case .cancelled:
                roseMistOverlayCenter.showToast("Purchase cancelled.", style: .normal)
            case .pending:
                roseMistOverlayCenter.showToast("Purchase pending.", style: .normal)
            case .failed(let silkBloomMessage):
                roseMistOverlayCenter.showToast(silkBloomMessage, style: .error)
            }
        }
    }

    private func silkBloomAddCoins(_ silkBloomCoins: Int) {
        guard let silkBloomCurrentUserID = SilkBloomLoginSessionStore.currentUserID else {
            roseMistOverlayCenter.showToast("Please sign in first.", style: .normal)
            return
        }

        do {
            guard var silkBloomUser = try RadiantDewLocalDataCenter.shared.radiantDewUsers.read(id: silkBloomCurrentUserID) else {
                roseMistOverlayCenter.showToast("Wallet data failed to load.", style: .error)
                return
            }

            silkBloomUser.blushBloomCoinCount += silkBloomCoins
            try RadiantDewLocalDataCenter.shared.radiantDewUsers.update(silkBloomUser)
            silkBloomCurrentUser = silkBloomUser
            roseMistOverlayCenter.showToast("Recharge successful.", style: .success)
        } catch {
            roseMistOverlayCenter.showToast("Recharge save failed.", style: .error)
        }
    }
}

struct SilkBloomRechargePackage: Identifiable {
    let silkBloomProductKeyID: String
    let silkBloomCoinCount: Int
    let silkBloomPrice: Double

    var id: String {
        silkBloomProductKeyID
    }

    var silkBloomPriceText: String {
        String(format: "$%.2f", silkBloomPrice)
    }
}

let silkBloomRechargeProducts: [SilkBloomRechargePackage] = [
    .init(silkBloomProductKeyID: "kfjlddxvsqtchcuw", silkBloomCoinCount: 400, silkBloomPrice: 0.99),
    .init(silkBloomProductKeyID: "qkaqznlytfbqfllu", silkBloomCoinCount: 800, silkBloomPrice: 1.99),
    .init(silkBloomProductKeyID: "mzkqvbrltyxnpafh", silkBloomCoinCount: 1780, silkBloomPrice: 3.99),
    .init(silkBloomProductKeyID: "cmbfsbsszfbamaak", silkBloomCoinCount: 2450, silkBloomPrice: 4.99),
    .init(silkBloomProductKeyID: "yqgshbdynhmamvkh", silkBloomCoinCount: 5150, silkBloomPrice: 9.99),
    .init(silkBloomProductKeyID: "mahlyshlxhzdznfw", silkBloomCoinCount: 10800, silkBloomPrice: 19.99),
    .init(silkBloomProductKeyID: "qjwdcseunhprgklo", silkBloomCoinCount: 14900, silkBloomPrice: 29.99),
    .init(silkBloomProductKeyID: "herxrexajkgqjqxk", silkBloomCoinCount: 29400, silkBloomPrice: 49.99),
    .init(silkBloomProductKeyID: "vbtfzmxqaylewrin", silkBloomCoinCount: 34500, silkBloomPrice: 69.99),
    .init(silkBloomProductKeyID: "zrnvahqmueviabzl", silkBloomCoinCount: 63700, silkBloomPrice: 99.99)
]

enum SilkBloomRechargePurchaseResult {
    case success(coins: Int)
    case cancelled
    case pending
    case failed(message: String)
}

final class SilkBloomRechargeIAPManager: NSObject, ObservableObject {
    static let shared = SilkBloomRechargeIAPManager()

    @Published var silkBloomStoreProducts: [SKProduct] = []
    @Published var silkBloomIsPurchasing = false

    private var silkBloomRequest: SKProductsRequest?
    private var silkBloomPurchaseCompletion: ((SilkBloomRechargePurchaseResult) -> Void)?
    private var silkBloomRetryCount = 0
    private var silkBloomTotalRequestCount = 0
    private let silkBloomMaxTotalRequestCount = 10
    private let silkBloomMaxRetryCount = 10
    private var silkBloomIsRequesting = false

    private override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }

    deinit {
        silkBloomRequest?.cancel()
        SKPaymentQueue.default().remove(self)
    }

    func silkBloomFetchProducts() {
        guard silkBloomTotalRequestCount < silkBloomMaxTotalRequestCount else { return }
        guard silkBloomIsRequesting == false else { return }
        guard silkBloomStoreProducts.isEmpty else { return }

        silkBloomIsRequesting = true
        silkBloomTotalRequestCount += 1

        let silkBloomProductIDs = Set(silkBloomRechargeProducts.map(\.silkBloomProductKeyID))
        silkBloomRequest?.cancel()
        silkBloomRequest = SKProductsRequest(productIdentifiers: silkBloomProductIDs)
        silkBloomRequest?.delegate = self
        silkBloomRequest?.start()
    }

    func silkBloomRecharge(
        productKeyID silkBloomProductKeyID: String,
        completion: @escaping (SilkBloomRechargePurchaseResult) -> Void
    ) {
        guard SKPaymentQueue.canMakePayments() else {
            completion(.failed(message: "Payments not allowed."))
            return
        }

        guard let silkBloomProduct = silkBloomStoreProducts.first(where: {
            $0.productIdentifier == silkBloomProductKeyID
        }) else {
            silkBloomFetchProducts()
            completion(.failed(message: "Product not found. Please try again later."))
            return
        }

        silkBloomIsPurchasing = true
        silkBloomPurchaseCompletion = completion

        let silkBloomPayment = SKPayment(product: silkBloomProduct)
        SKPaymentQueue.default().add(silkBloomPayment)
    }

    private func silkBloomProductConfig(productID silkBloomProductID: String) -> SilkBloomRechargePackage? {
        silkBloomRechargeProducts.first {
            $0.silkBloomProductKeyID == silkBloomProductID
        }
    }

    private func silkBloomFinishPurchase(_ silkBloomResult: SilkBloomRechargePurchaseResult) {
        DispatchQueue.main.async {
            self.silkBloomIsPurchasing = false
            self.silkBloomPurchaseCompletion?(silkBloomResult)
            self.silkBloomPurchaseCompletion = nil
        }
    }
}

extension SilkBloomRechargeIAPManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.silkBloomIsRequesting = false
            self.silkBloomRetryCount = 0
            self.silkBloomStoreProducts = response.products

            if response.products.isEmpty {
                self.silkBloomRetryFetch()
            }
        }
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.silkBloomIsRequesting = false
            self.silkBloomRetryFetch()
        }
    }

    private func silkBloomRetryFetch() {
        silkBloomRetryCount += 1

        guard silkBloomRetryCount < silkBloomMaxRetryCount,
              silkBloomTotalRequestCount < silkBloomMaxTotalRequestCount else {
            return
        }

        let silkBloomDelay = pow(2.0, Double(silkBloomRetryCount))
        DispatchQueue.main.asyncAfter(deadline: .now() + silkBloomDelay) {
            self.silkBloomFetchProducts()
        }
    }
}

extension SilkBloomRechargeIAPManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for silkBloomTransaction in transactions {
            switch silkBloomTransaction.transactionState {
            case .purchased:
                SKPaymentQueue.default().finishTransaction(silkBloomTransaction)

                guard let silkBloomProduct = silkBloomProductConfig(
                    productID: silkBloomTransaction.payment.productIdentifier
                ) else {
                    silkBloomFinishPurchase(.failed(message: "Product not found."))
                    continue
                }

                silkBloomFinishPurchase(.success(coins: silkBloomProduct.silkBloomCoinCount))

            case .failed:
                SKPaymentQueue.default().finishTransaction(silkBloomTransaction)

                if let silkBloomError = silkBloomTransaction.error as? SKError,
                   silkBloomError.code == .paymentCancelled {
                    silkBloomFinishPurchase(.cancelled)
                } else {
                    silkBloomFinishPurchase(
                        .failed(message: silkBloomTransaction.error?.localizedDescription ?? "Unknown error.")
                    )
                }

            case .restored:
                SKPaymentQueue.default().finishTransaction(silkBloomTransaction)
                DispatchQueue.main.async {
                    self.silkBloomIsPurchasing = false
                }

            case .purchasing:
                break

            case .deferred:
                silkBloomPurchaseCompletion?(.pending)

            @unknown default:
                break
            }
        }
    }
}

private extension SKProduct {
    var silkBloomLocalizedPriceText: String {
        let silkBloomFormatter = NumberFormatter()
        silkBloomFormatter.numberStyle = .currency
        silkBloomFormatter.locale = priceLocale
        return silkBloomFormatter.string(from: price) ?? String(format: "$%.2f", price.doubleValue)
    }
}
