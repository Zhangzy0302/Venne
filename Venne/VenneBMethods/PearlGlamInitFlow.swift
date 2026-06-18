import CoreLocation
import Foundation
import SwiftUI
import UIKit
import Combine

enum PearlGlamBRoute {
  case pearlGlamAgreement(pearlGlamURL: String)
}

final class PearlGlamInitUtils {

  static let shared = PearlGlamInitUtils()
  private init() {}

  var pearlGlamApiCallResponse: [String: Any]?
  var pearlGlamShouldFetchLocation: Bool = true

  func pearlGlamFetchDecision() async {
    do {
      pearlGlamApiCallResponse = try await RougeSignalApiCall().rougeSignalGetDecision()
    } catch {
      // 忽略错误（与原逻辑一致）
    }
  }
  func pearlGlamGoLogin() async -> PearlGlamBRoute? {
    do {

      if pearlGlamShouldFetchLocation {
        try await pearlGlamHandleLocation()
      }

      guard let pearlGlamResponse = try await RougeSignalApiCall().rougeSignalQuickLogin() else {
          await MainActor.run {
              RoseMistOverlayCenter.shared.showToast("error", style: .error)
          }
        return nil
      }

      return await pearlGlamProcessLoginResponse(pearlGlamResponse)

    } catch {
        await MainActor.run {
            RoseMistOverlayCenter.shared.showToast("error", style: .error)
        }
      return nil
    }
  }

  func pearlGlamHandleLocation() async throws {

    guard
      let pearlGlamPlacemark = await GlossPetalLocationManager.shared
        .glossPetalGetCurrentLocationAndAddress()
    else {
      throw NSError(domain: "LocationError", code: -1)
    }

    if let pearlGlamLocation = pearlGlamPlacemark.location {
      GlossPetalPhoneInfo.shared.glossPetalLatitude = pearlGlamLocation.coordinate.latitude
      GlossPetalPhoneInfo.shared.glossPetalLongitude = pearlGlamLocation.coordinate.longitude
    }
  }

  func pearlGlamProcessLoginResponse(_ pearlGlamResponse: [String: Any]) async -> PearlGlamBRoute? {

    guard let pearlGlamCode = pearlGlamResponse["code"] as? String else { return nil }

    if pearlGlamCode != "0000" {
        await MainActor.run {
            RoseMistOverlayCenter.shared.showToast("Login Error", style: .error)
        }
      return nil
    }

    guard let pearlGlamResultEncrypted = pearlGlamResponse["result"] as? String else { return nil }

    let pearlGlamDecrypted = pearlGlamResultEncrypted.glossPetalBDecrypt()

    guard let pearlGlamJSONData = pearlGlamDecrypted.data(using: .utf8),
      let pearlGlamResultDict = try? JSONSerialization.jsonObject(with: pearlGlamJSONData) as? [String: Any]
    else { return nil }

    await pearlGlamUpdateUserState(pearlGlamResultDict)

    let pearlGlamURL = GlossPetalInformationCreate.glossPetalBuildH5Url(
      baseUrl: VelvetPoutAppStorage.velvetPoutH5Url,
      token: VelvetPoutAppStorage.velvetPoutUserToken
    )

    print("h5url: \(pearlGlamURL) ------end")

      return PearlGlamBRoute.pearlGlamAgreement(pearlGlamURL: pearlGlamURL)
  }

  func pearlGlamUpdateUserState(_ pearlGlamResult: [String: Any]) async {

    if VelvetPoutBInfoStore.shared.velvetPoutPassword.isEmpty,
      let pearlGlamPassword = pearlGlamResult["password"] as? String
    {
      VelvetPoutBInfoStore.shared.velvetPoutPassword = pearlGlamPassword
    }

    if let pearlGlamToken = pearlGlamResult["token"] as? String {
        VelvetPoutAppStorage.velvetPoutUserToken = pearlGlamToken
//        VelvetPoutBInfoStore.saveUserToken(token)
    }
  }

  func pearlGlamHandleDeviceAndPolling() async {

    await pearlGlamFetchDecision()

    let pearlGlamPollingInterval: UInt64 = 2_000_000_000
    let pearlGlamMaxErrorInterval: UInt64 = 10_000_000_000

    var pearlGlamElapsed: UInt64 = 0

    while pearlGlamApiCallResponse == nil {

      try? await Task.sleep(nanoseconds: pearlGlamPollingInterval)
      pearlGlamElapsed += pearlGlamPollingInterval

      await pearlGlamFetchDecision()

      if pearlGlamElapsed >= pearlGlamMaxErrorInterval {
        pearlGlamElapsed = 0
          await MainActor.run {
              RoseMistOverlayCenter.shared.showToast("Network Error", style: .error)
          }
      }
    }
  }
}

enum PearlGlamInitStatus {
  case pearlGlamLoading
  case pearlGlamB
  case pearlGlamA
}

@MainActor
final class PearlGlamInitViewModel: ObservableObject {

  @Published var pearlGlamStatus: PearlGlamInitStatus = .pearlGlamLoading
  @Published var pearlGlamNextRoute: PearlGlamBRoute?

  private let pearlGlamInitUtils = PearlGlamInitUtils.shared

  // MARK: - 主入口
  func pearlGlamStartBInit() async {
    await GlossPetalPhoneInfo.shared.glossPetalGetPhoneInfo()
    await pearlGlamInitUtils.pearlGlamHandleDeviceAndPolling()
    await pearlGlamProcessApiResponse()
  }

  //处理 API 响应
  func pearlGlamProcessApiResponse() async {

    guard pearlGlamIsResponseValid() else {
      pearlGlamSetFailureStatus()
      return
    }

    VelvetPoutAppStorage.velvetPoutIsB = true

    let pearlGlamDecryptedData = pearlGlamDecryptResult()
    print("openValue: \(pearlGlamDecryptedData["openValue"] ?? "null")")
    VelvetPoutAppStorage.velvetPoutH5Url = pearlGlamDecryptedData["openValue"] as? String ?? ""
    await pearlGlamInitUtils.pearlGlamUpdateUserState(pearlGlamDecryptedData)

    let pearlGlamLoginFlag = pearlGlamIntValue(from: pearlGlamDecryptedData["loginFlag"])
    let pearlGlamHasLogin = pearlGlamLoginFlag == 1 && !VelvetPoutAppStorage.velvetPoutUserToken.isEmpty

    if pearlGlamHasLogin {
      let pearlGlamRoute = await pearlGlamBuildRedirectRoute()

      pearlGlamNextRoute = pearlGlamRoute
      pearlGlamUpdateStatus(.pearlGlamB)
    } else {
      await pearlGlamHandleLocationFlow(pearlGlamDecryptedData)
    }
  }

  //校验响应
  private func pearlGlamIsResponseValid() -> Bool {
    guard let pearlGlamResponse = pearlGlamInitUtils.pearlGlamApiCallResponse else {
      return false
    }
    print(pearlGlamResponse)
    return (pearlGlamResponse["code"] as? String) == "0000"
  }

  //解密数据
  private func pearlGlamDecryptResult() -> [String: Any] {
    guard let pearlGlamResultString = pearlGlamInitUtils.pearlGlamApiCallResponse?["result"] as? String
    else {
      return [:]
    }

    let pearlGlamDecryptedString = pearlGlamResultString.glossPetalBDecrypt()

    guard let pearlGlamJSONData = pearlGlamDecryptedString.data(using: .utf8) else {
      return [:]
    }

    guard let pearlGlamResultDict = try? JSONSerialization.jsonObject(with: pearlGlamJSONData) as? [String: Any]
    else {
      return [:]
    }
    return pearlGlamResultDict
  }

  private func pearlGlamIntValue(from pearlGlamValue: Any?) -> Int {
    if let pearlGlamInt = pearlGlamValue as? Int {
      return pearlGlamInt
    }

    if let pearlGlamNumber = pearlGlamValue as? NSNumber {
      return pearlGlamNumber.intValue
    }

    if let pearlGlamString = pearlGlamValue as? String {
      return Int(pearlGlamString.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
    }

    return 0
  }

  //处理定位流程
  private func pearlGlamHandleLocationFlow(_ pearlGlamDecryptedData: [String: Any]) async {

    let pearlGlamLocationFlag = pearlGlamIntValue(from: pearlGlamDecryptedData["locationFlag"])

    pearlGlamInitUtils.pearlGlamShouldFetchLocation = (pearlGlamLocationFlag == 1)

    if pearlGlamInitUtils.pearlGlamShouldFetchLocation {
      _ = await GlossPetalLocationManager.shared.glossPetalCheckAndRequestLocation()
    }

    pearlGlamUpdateStatus(.pearlGlamB)
  }

  //✅ 7️⃣ 失败状态
  private func pearlGlamSetFailureStatus() {
    pearlGlamUpdateStatus(.pearlGlamA)
  }

  //✅ 8️⃣ 成功跳转
  func pearlGlamBuildRedirectRoute() async -> PearlGlamBRoute {
    let pearlGlamURL = GlossPetalInformationCreate.glossPetalBuildH5Url(
      baseUrl: VelvetPoutAppStorage.velvetPoutH5Url,
      token: VelvetPoutAppStorage.velvetPoutUserToken
    )
      return PearlGlamBRoute.pearlGlamAgreement(pearlGlamURL: pearlGlamURL)
  }

  //✅ 9️⃣ 状态更新
  private func pearlGlamUpdateStatus(_ pearlGlamNewStatus: PearlGlamInitStatus) {
    pearlGlamStatus = pearlGlamNewStatus
  }

  // 初始化流程（等价 initState）
  func pearlGlamInitFlow() async {
    // 修复点1：处理日期组件的可选值（原代码强制解包! 有崩溃风险）
    guard
      let pearlGlamTargetDate = Calendar.current.date(
        from: GlossPetalInformationCreate.glossPetalVerifyDate)
    else {
      // 日期解析失败时的兜底逻辑
      pearlGlamUpdateStatus(.pearlGlamA)
      return
    }

    // 修复点2：替换不存在的 isBefore 方法（用 Date 的比较运算符实现）
    let pearlGlamCurrentDate = Date()
    let pearlGlamIsTimeOver = !(pearlGlamCurrentDate < pearlGlamTargetDate)  // currentDate >= targetDate 即时间已过

    if !pearlGlamIsTimeOver {
      pearlGlamUpdateStatus(.pearlGlamA)
      return
    }
    VelvetPoutAppStorage.velvetPoutIsB = false
    if !VelvetPoutAppStorage.velvetPoutIsB {
      await pearlGlamStartBInit()

    } else {
      pearlGlamUpdateStatus(.pearlGlamB)
    }
  }
}
