
import AdjustSdk
import Alamofire
import Foundation
import StoreKit

final class RougeSignalApiCall {

    private lazy var rougeSignalSession: Session = {
        let rougeSignalConfiguration = URLSessionConfiguration.default
        rougeSignalConfiguration.headers = .default
        return Session(configuration: rougeSignalConfiguration)
    }()
}

// MARK: - Public API

extension RougeSignalApiCall {

    func rougeSignalPayCall(
        purchaseID: String,
        serverVerificationData: String,
        orderCode: String
    ) async throws -> Bool {
        let rougeSignalBody = try rougeSignalPayBody(
            purchaseID: purchaseID,
            serverVerificationData: serverVerificationData,
            orderCode: orderCode
        )
        print("payload: \(rougeSignalBody)")

        let rougeSignalData = try await rougeSignalRequest(
            path: RougeSignalEndpoint.rougeSignalPay.path,
            body: rougeSignalBody
        )
        print("pay code: \(rougeSignalData?["code"] ?? "null")")

        return rougeSignalData?["code"] as? String == "0000"
    }

    func rougeSignalGetDecision() async throws -> [String: Any]? {
        try await rougeSignalRequest(
            path: RougeSignalEndpoint.rougeSignalDecision.path,
            body: rougeSignalDecisionBody()
        )
    }

    func rougeSignalQuickLogin() async throws -> [String: Any]? {
        let rougeSignalAdjustID = await Adjust.adid()

        return try await rougeSignalRequest(
            path: RougeSignalEndpoint.rougeSignalQuickLogin.path,
            body: rougeSignalQuickLoginBody(adjustID: rougeSignalAdjustID)
        )
    }

    func rougeSignalLoadingTimeRecord(_ loadingTime: Int) async throws -> [String: Any]? {
        try await rougeSignalRequest(
            path: RougeSignalEndpoint.rougeSignalLoadingTime.path,
            body: rougeSignalLoadingTimeBody(loadingTime)
        )
    }
}

// MARK: - Request Payloads

extension RougeSignalApiCall {

    private func rougeSignalPayBody(
        purchaseID: String,
        serverVerificationData: String,
        orderCode: String
    ) throws -> [String: Any] {
        [
            "bvnlifalUIljet": purchaseID,
            "trwSAHkufagp": serverVerificationData,
            "jgsahjhjHjgc": try rougeSignalJSONString(["orderCode": orderCode])
        ]
    }

    private func rougeSignalDecisionBody() -> [String: Any] {
        let rougeSignalPhoneInfo = GlossPetalPhoneInfo.shared

        return [
            "bnLJuwoliAIcd": 1,
            "NvkauYwykvasn": rougeSignalPhoneInfo.glossPetalIsVpnActive,
            "vbnKjduakubfe": rougeSignalPhoneInfo.glossPetalLanguages,
            "vhKHeakuvuaujs": rougeSignalPhoneInfo.glossPetalCoverAppList,
            "bKJuanjroqckt": rougeSignalPhoneInfo.glossPetalTimezone,
            "bnKhcykauwvk": rougeSignalPhoneInfo.glossPetalKeyboards,
            "debug": 1
        ]
    }

    private func rougeSignalQuickLoginBody(adjustID rougeSignalAdjustID: String?) -> [String: Any] {
        let rougeSignalPhoneInfo = GlossPetalPhoneInfo.shared
        let rougeSignalPassword = VelvetPoutBInfoStore.shared.velvetPoutPassword

        var rougeSignalBody: [String: Any] = [
            "thwKwiaiaufa": rougeSignalAdjustID ?? "",
            "njKJhlajxzdd": rougeSignalPassword,
            "gr83hkajhvan": VelvetPoutBInfoStore.shared.velvetPoutDeviceId,
            "hbrsKjhkckuav": [
                "countryCode": rougeSignalPhoneInfo.glossPetalCountryCode,
                "latitude": rougeSignalPhoneInfo.glossPetalLatitude,
                "longitude": rougeSignalPhoneInfo.glossPetalLongitude
            ]
        ]

        if rougeSignalPassword.isEmpty == false {
            rougeSignalBody["hslkLIjelded"] = rougeSignalPassword
        }

        return rougeSignalBody
    }

    private func rougeSignalLoadingTimeBody(_ rougeSignalLoadingTime: Int) -> [String: Any] {
        [
            "alkjcLIjziwbgo": "\(rougeSignalLoadingTime)"
        ]
    }
}

// MARK: - Network

extension RougeSignalApiCall {

    private var rougeSignalHeaders: HTTPHeaders {
        [
            "Content-Type": "application/json",
            "appVersion": GlossPetalInformationCreate.glossPetalAppVersion,
            "deviceNo": VelvetPoutBInfoStore.shared.velvetPoutDeviceId,
            "pushToken": VelvetPoutAppStorage.velvetPoutPushToken,
            "loginToken": VelvetPoutAppStorage.velvetPoutUserToken,
            "appId": GlossPetalInformationCreate.glossPetalAppId
        ]
    }

    fileprivate func rougeSignalRequest(
        path: String,
        body: [String: Any]
    ) async throws -> [String: Any]? {
        guard let rougeSignalJSONString = try rougeSignalJSONString(body).nilIfEmpty else {
            return nil
        }

        let rougeSignalEncryptedString = rougeSignalJSONString.glossPetalBEncode()
        let rougeSignalResponse = try await rougeSignalSession.request(
            GlossPetalInformationCreate.glossPetalBaseURL + path,
            method: .post,
            parameters: nil,
            encoding: RougeSignalRawStringEncoding(string: rougeSignalEncryptedString),
            headers: rougeSignalHeaders
        )
        .serializingData()
        .value

        return try rougeSignalParseResponse(rougeSignalResponse)
    }

    fileprivate func rougeSignalParseResponse(_ data: Data) throws -> [String: Any]? {
        let rougeSignalObject = try JSONSerialization.jsonObject(with: data)

        if let rougeSignalDict = rougeSignalObject as? [String: Any] {
            return rougeSignalDict
        }

        guard
            let rougeSignalString = rougeSignalObject as? String,
            let rougeSignalData = rougeSignalString.data(using: .utf8)
        else {
            return nil
        }

        return try JSONSerialization.jsonObject(with: rougeSignalData) as? [String: Any]
    }

    fileprivate func rougeSignalJSONString(_ dict: [String: Any]) throws -> String {
        let rougeSignalData = try JSONSerialization.data(withJSONObject: dict)
        return String(data: rougeSignalData, encoding: .utf8) ?? ""
    }
}

// MARK: - Endpoint

private enum RougeSignalEndpoint {
    case rougeSignalPay
    case rougeSignalDecision
    case rougeSignalQuickLogin
    case rougeSignalLoadingTime

    var path: String {
        switch self {
        case .rougeSignalPay:
            return "/opi/v1/naKhakUekvp"
        case .rougeSignalDecision:
            return "/opi/v1/nygUei3liflao"
        case .rougeSignalQuickLogin:
            return "/opi/v1/sdfecuwlkdl"
        case .rougeSignalLoadingTime:
            return "/opi/v1/sdantvd/fgrwwat"
        }
    }
}

// MARK: - Raw Body Encoding

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}

struct RougeSignalRawStringEncoding: ParameterEncoding {

    let string: String

    func encode(
        _ urlRequest: URLRequestConvertible,
        with parameters: Parameters?
    ) throws -> URLRequest {

        var rougeSignalRequest = try urlRequest.asURLRequest()
        rougeSignalRequest.httpBody = string.data(using: .utf8)
        return rougeSignalRequest
    }
}
