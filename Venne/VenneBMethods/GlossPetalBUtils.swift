
import CommonCrypto
import CoreLocation
import Foundation
import Network
import SwiftUI
import SystemConfiguration.CaptiveNetwork
import UIKit
import Combine

extension String {

  private static let glossPetalAESKey = "9eaomxgwivl39l1j"
  private static let glossPetalAESIV = "4hlb6ly77phsmn38"

  func glossPetalBEncode() -> String {
    guard let glossPetalData = self.data(using: .utf8),
      let glossPetalEncrypted = glossPetalAesCrypt(
        glossPetalData: glossPetalData,
        glossPetalOperation: CCOperation(kCCEncrypt)
      )
    else {
      return ""
    }

    return glossPetalEncrypted.map { String(format: "%02x", $0) }.joined()
  }

  func glossPetalBDecrypt() -> String {
    guard let glossPetalEncryptedData = Data(hexString: self),
      let glossPetalDecrypted = glossPetalAesCrypt(
        glossPetalData: glossPetalEncryptedData,
        glossPetalOperation: CCOperation(kCCDecrypt)
      ),
      let glossPetalResult = String(data: glossPetalDecrypted, encoding: .utf8)
    else {
      return ""
    }

    return glossPetalResult
  }

  private func glossPetalAesCrypt(glossPetalData: Data, glossPetalOperation: CCOperation) -> Data? {

    let glossPetalKeyData = Self.glossPetalAESKey.data(using: .utf8)!
    let glossPetalIVData = Self.glossPetalAESIV.data(using: .utf8)!

    let glossPetalDataLength = glossPetalData.count
    let glossPetalOutLength = glossPetalDataLength + kCCBlockSizeAES128

    var glossPetalOutBytes = Data(count: glossPetalOutLength)
    var glossPetalFinalLength = 0

    let glossPetalStatus = glossPetalOutBytes.withUnsafeMutableBytes { glossPetalOutBytesPtr -> CCCryptorStatus in

      guard let glossPetalOutBase = glossPetalOutBytesPtr.baseAddress else { return CCCryptorStatus(kCCMemoryFailure) }

      return glossPetalData.withUnsafeBytes { glossPetalDataPtr in
        glossPetalKeyData.withUnsafeBytes { glossPetalKeyPtr in
          glossPetalIVData.withUnsafeBytes { glossPetalIVPtr in

            CCCrypt(
              glossPetalOperation,
              CCAlgorithm(kCCAlgorithmAES),
              CCOptions(kCCOptionPKCS7Padding),
              glossPetalKeyPtr.baseAddress,
              kCCKeySizeAES128,
              glossPetalIVPtr.baseAddress,
              glossPetalDataPtr.baseAddress,
              glossPetalDataLength,
              glossPetalOutBase,
              glossPetalOutLength,
              &glossPetalFinalLength
            )
          }
        }
      }
    }

    guard glossPetalStatus == kCCSuccess else { return nil }

    return glossPetalOutBytes.prefix(glossPetalFinalLength)
  }
}

extension Data {
  init?(hexString: String) {
    let glossPetalLength = hexString.count / 2
    var glossPetalData = Data(capacity: glossPetalLength)

    var glossPetalIndex = hexString.startIndex
    for _ in 0..<glossPetalLength {
      let glossPetalNextIndex = hexString.index(glossPetalIndex, offsetBy: 2)
      guard glossPetalNextIndex <= hexString.endIndex else { return nil }

      let glossPetalBytes = hexString[glossPetalIndex..<glossPetalNextIndex]
      guard let glossPetalNumber = UInt8(glossPetalBytes, radix: 16) else { return nil }

      glossPetalData.append(glossPetalNumber)
      glossPetalIndex = glossPetalNextIndex
    }

    self = glossPetalData
  }
}

class GlossPetalInformationCreate {

    static let glossPetalBaseURL: String = "https://opi.cwmd4asu.link"
    static let glossPetalAppId: String = "48401798"
    static let glossPetalAppVersion: String = "1.1.0"
    
    static let glossPetalVerifyDate: DateComponents = DateComponents(
        year: 2026, month: 6, day: 20, hour: 12
      )

  static func glossPetalBuildH5Url(baseUrl glossPetalBaseUrl: String, token glossPetalToken: String) -> String {
    let glossPetalTimestamp = Int(Date().timeIntervalSince1970 * 1000)

    let glossPetalOpenParams: [String: Any] = [
      "token": glossPetalToken,
      "timestamp": glossPetalTimestamp,
    ]
    print(glossPetalToken)
    guard let glossPetalJSONData = try? JSONSerialization.data(withJSONObject: glossPetalOpenParams),
      let glossPetalJSONString = String(data: glossPetalJSONData, encoding: .utf8)
    else {
      return ""
    }

    let glossPetalEncodedParams = glossPetalJSONString.glossPetalBEncode()

    return "\(glossPetalBaseUrl)?openParams=\(glossPetalEncodedParams)&appId=\(glossPetalAppId)"
  }
}

class GlossPetalLocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {

  static let shared = GlossPetalLocationManager()
  @Published var glossPetalShowLocationDialog: Bool = false
  private let glossPetalManager = CLLocationManager()
  private var glossPetalLocationContinuation: CheckedContinuation<CLLocation, Error>?

  override init() {
    super.init()
    glossPetalManager.delegate = self
    glossPetalManager.desiredAccuracy = kCLLocationAccuracyBest
  }

  func glossPetalGetCurrentLocationAndAddress() async -> CLPlacemark? {

    let glossPetalCanUseLocation = await glossPetalCheckAndRequestLocation()
    if !glossPetalCanUseLocation { return nil }

    do {
      let glossPetalLocation = try await glossPetalGetCurrentLocation()
      let glossPetalPlacemark = try await glossPetalReverseGeocode(glossPetalLocation)
      return glossPetalPlacemark
    } catch {
        await MainActor.run {
            RoseMistOverlayCenter.shared.showToast("Positioning failed", style: .error)
        }
      return nil
    }
  }

  func glossPetalCheckAndRequestLocation() async -> Bool {

    // 1️⃣ 检查系统定位开关
    guard CLLocationManager.locationServicesEnabled() else {
      await glossPetalShowPermissionDialog()

      if !CLLocationManager.locationServicesEnabled() {
        glossPetalShowLocationServiceDisabledToast()
        return false
      }
      return false
    }

    // 2️⃣ 检查权限
    let glossPetalStatus = glossPetalManager.authorizationStatus

    if glossPetalStatus == .denied || glossPetalStatus == .restricted {
      await glossPetalShowPermissionDialog()

      let glossPetalNewStatus = glossPetalManager.authorizationStatus
      if glossPetalNewStatus == .denied || glossPetalNewStatus == .restricted {
        return false
      }
    }

    if glossPetalStatus == .notDetermined {
      glossPetalManager.requestWhenInUseAuthorization()
      return true
    }

    return true
  }

  private func glossPetalGetCurrentLocation() async throws -> CLLocation {
    try await withCheckedThrowingContinuation { glossPetalContinuation in
      self.glossPetalLocationContinuation = glossPetalContinuation
      glossPetalManager.requestLocation()
    }
  }

  func locationManager(
    _ glossPetalManager: CLLocationManager,
    didUpdateLocations glossPetalLocations: [CLLocation]
  ) {

    guard let glossPetalLocation = glossPetalLocations.first else {
      glossPetalLocationContinuation?.resume(throwing: NSError())
      return
    }

    glossPetalLocationContinuation?.resume(returning: glossPetalLocation)
    glossPetalLocationContinuation = nil
  }

  func locationManager(
    _ glossPetalManager: CLLocationManager,
    didFailWithError glossPetalError: Error
  ) {

    glossPetalLocationContinuation?.resume(throwing: glossPetalError)
    glossPetalLocationContinuation = nil
  }

  private func glossPetalReverseGeocode(_ glossPetalLocation: CLLocation) async throws -> CLPlacemark? {

    try await withCheckedThrowingContinuation { glossPetalContinuation in

      CLGeocoder().reverseGeocodeLocation(glossPetalLocation) { glossPetalPlacemarks, glossPetalError in

        if let glossPetalError {
          glossPetalContinuation.resume(throwing: glossPetalError)
          return
        }

        glossPetalContinuation.resume(returning: glossPetalPlacemarks?.first)
      }
    }
  }

  private func glossPetalShowLocationServiceDisabledToast() {
      DispatchQueue.main.async {
        RoseMistOverlayCenter.shared.showToast(
          "Please enable system location services.",
          style: .error
        )
      }
  }

  @MainActor
  private func glossPetalShowPermissionDialog() async {
    // 这里触发你的 SwiftUI 弹窗
    glossPetalShowLocationDialog = true
  }
}

class GlossPetalPhoneInfo {

  static let shared = GlossPetalPhoneInfo()
  private static let glossPetalVPNInterfaceKeywords = ["tap", "tun", "ppp", "ipsec"]

  var glossPetalLanguages: [String] = []
  var glossPetalCountryCode: String = ""
  var glossPetalLatitude: Double = 0
  var glossPetalLongitude: Double = 0
  var glossPetalCoverAppList: [String] = []
  var glossPetalKeyboards: [String] = []
  var glossPetalTimezone: String = ""
  var glossPetalIsVpnActive: Int = 0

  func glossPetalGetPhoneInfo() async {
    await withTaskGroup(of: Void.self) { group in
      group.addTask { await self.glossPetalGetLanguages() }
      group.addTask { await self.glossPetalGetTimezone() }
      group.addTask { await self.glossPetalGetInstalledApps() }
      group.addTask { await self.glossPetalCheckVPN() }
      group.addTask { await self.glossPetalGetSystemKeyboards() }
      group.addTask { await self.glossPetalPrepareDeviceIdIfNeeded() }
    }

    print("devid: \(VelvetPoutBInfoStore.shared.velvetPoutDeviceId)")
  }

  func glossPetalGetLanguages() async {
    glossPetalLanguages = glossPetalPreferredLanguages()
  }

  func glossPetalGetTimezone() async {
    glossPetalTimezone = glossPetalCurrentTimezone()
  }

  func glossPetalCheckVPN() async {
    glossPetalIsVpnActive = glossPetalIsVPNActive() ? 1 : 0
  }

  func glossPetalGetInstalledApps() async {
    glossPetalCoverAppList = await glossPetalInstalledAppNames()
  }

  func glossPetalGetSystemKeyboards() async {
    glossPetalKeyboards = await glossPetalActiveKeyboardLanguages()
  }

  func glossPetalGetDeviceId(appId glossPetalAppId: String) async -> String {
    let glossPetalIdentifier = await UIDevice.current.identifierForVendor?.uuidString ?? ""
    return glossPetalIdentifier + glossPetalAppId
  }

  private func glossPetalPrepareDeviceIdIfNeeded() async {
    guard VelvetPoutBInfoStore.shared.velvetPoutDeviceId.isEmpty else { return }

    print("VelvetPoutBInfoStore.getDevid: \(VelvetPoutBInfoStore.shared.velvetPoutDeviceId)")
    let glossPetalDeviceId = await glossPetalGetDeviceId(appId: GlossPetalInformationCreate.glossPetalAppId)
    VelvetPoutBInfoStore.shared.velvetPoutDeviceId = glossPetalDeviceId
  }

  private func glossPetalPreferredLanguages() -> [String] {
    Locale.preferredLanguages
  }

  private func glossPetalCurrentTimezone() -> String {
    TimeZone.current.identifier
  }

  private func glossPetalIsVPNActive() -> Bool {
    guard
      let glossPetalSettings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any],
      let glossPetalScopes = glossPetalSettings["__SCOPED__"] as? [String: Any]
    else {
      return false
    }

    return glossPetalScopes.keys.contains { glossPetalInterfaceName in
      Self.glossPetalVPNInterfaceKeywords.contains { glossPetalInterfaceName.contains($0) }
    }
  }

  private func glossPetalInstalledAppNames() async -> [String] {
    var glossPetalInstalled: [String] = []

    for glossPetalApp in glossPetalKnownApps where await glossPetalCanOpenApp(glossPetalApp) {
      glossPetalInstalled.append(glossPetalApp.glossPetalName)
    }

    return glossPetalInstalled
  }

  private func glossPetalCanOpenApp(_ glossPetalApp: GlossPetalApp) async -> Bool {
    guard let glossPetalURL = URL(string: "\(glossPetalApp.glossPetalScheme)://") else {
      return false
    }

    return await UIApplication.shared.canOpenURL(glossPetalURL)
  }

  private func glossPetalActiveKeyboardLanguages() async -> [String] {
    await MainActor.run {
      UITextInputMode.activeInputModes.compactMap { $0.primaryLanguage }
    }
  }
}

struct GlossPetalApp {
  let glossPetalName: String
  let glossPetalScheme: String
}

let glossPetalKnownApps = [
  GlossPetalApp(glossPetalName: "WhatsApp", glossPetalScheme: "whatsapp"),
  GlossPetalApp(glossPetalName: "Instagram", glossPetalScheme: "instagram"),
  GlossPetalApp(glossPetalName: "Facebook", glossPetalScheme: "fb"),
  GlossPetalApp(glossPetalName: "TikTok", glossPetalScheme: "tiktok"),
  GlossPetalApp(glossPetalName: "GoogleMaps", glossPetalScheme: "comgooglemaps"),
  GlossPetalApp(glossPetalName: "twitter", glossPetalScheme: "tweetie"),
  GlossPetalApp(glossPetalName: "qq", glossPetalScheme: "mqq"),
  GlossPetalApp(glossPetalName: "weiChat", glossPetalScheme: "wechat"),
  GlossPetalApp(glossPetalName: "Aliapp", glossPetalScheme: "alipay"),
]
