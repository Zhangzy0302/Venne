
import Foundation
import Security

// MARK: - Secure Keys

enum VelvetPoutSecureKey {
    case velvetPoutDeviceId
    case velvetPoutPassword

    var velvetPoutKey: String {
        switch self {
        case .velvetPoutDeviceId:
            return "velvetPoutDeviceId5"
        case .velvetPoutPassword:
            return "velvetPoutPassword"
        }
    }
}

// MARK: - Keychain Store

final class VelvetPoutBInfoStore {

    static let shared = VelvetPoutBInfoStore()

    private init() {}

    var velvetPoutDeviceId: String {
        get { velvetPoutReadSecureValue(.velvetPoutDeviceId) ?? "" }
        set { _ = velvetPoutSaveSecureValue(newValue, for: .velvetPoutDeviceId) }
    }

    var velvetPoutPassword: String {
        get { velvetPoutReadSecureValue(.velvetPoutPassword) ?? "" }
        set { _ = velvetPoutSaveSecureValue(newValue, for: .velvetPoutPassword) }
    }

    private func velvetPoutSaveSecureValue(_ velvetPoutValue: String, for velvetPoutKey: VelvetPoutSecureKey) -> Bool {
        guard let velvetPoutData = velvetPoutValue.data(using: .utf8) else {
            return false
        }

        velvetPoutDeleteSecureValue(velvetPoutKey)

        var velvetPoutQuery = velvetPoutBaseSecureQuery(for: velvetPoutKey)
        velvetPoutQuery[kSecValueData as String] = velvetPoutData
        velvetPoutQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock

        return SecItemAdd(velvetPoutQuery as CFDictionary, nil) == errSecSuccess
    }

    private func velvetPoutReadSecureValue(_ velvetPoutKey: VelvetPoutSecureKey) -> String? {
        var velvetPoutQuery = velvetPoutBaseSecureQuery(for: velvetPoutKey)
        velvetPoutQuery[kSecReturnData as String] = true
        velvetPoutQuery[kSecMatchLimit as String] = kSecMatchLimitOne

        var velvetPoutResult: AnyObject?
        let velvetPoutStatus = SecItemCopyMatching(velvetPoutQuery as CFDictionary, &velvetPoutResult)

        guard
            velvetPoutStatus == errSecSuccess,
            let velvetPoutData = velvetPoutResult as? Data
        else {
            return nil
        }

        return String(data: velvetPoutData, encoding: .utf8)
    }

    private func velvetPoutDeleteSecureValue(_ velvetPoutKey: VelvetPoutSecureKey) {
        let velvetPoutQuery = velvetPoutBaseSecureQuery(for: velvetPoutKey)
        SecItemDelete(velvetPoutQuery as CFDictionary)
    }

    private func velvetPoutBaseSecureQuery(for velvetPoutKey: VelvetPoutSecureKey) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: velvetPoutKey.velvetPoutKey
        ]
    }
}

// MARK: - App Storage Keys

enum VelvetPoutAppStorageKey {
    static let velvetPoutIsB = "velvetPoutIsB"
    static let velvetPoutPushToken = "velvetPoutPushToken"
    static let velvetPoutH5Url = "velvetPoutH5Url"
    static let velvetPoutUserToken = "velvetPoutUserToken"
}

// MARK: - UserDefaults Store

final class VelvetPoutAppStorage {

    private static let velvetPoutDefaults = UserDefaults.standard

    static var velvetPoutIsB: Bool {
        get { velvetPoutDefaults.bool(forKey: VelvetPoutAppStorageKey.velvetPoutIsB) }
        set { velvetPoutDefaults.set(newValue, forKey: VelvetPoutAppStorageKey.velvetPoutIsB) }
    }

    static var velvetPoutUserToken: String {
        get { velvetPoutStringValue(for: VelvetPoutAppStorageKey.velvetPoutUserToken) }
        set { velvetPoutDefaults.set(newValue, forKey: VelvetPoutAppStorageKey.velvetPoutUserToken) }
    }

    static var velvetPoutPushToken: String {
        get { velvetPoutStringValue(for: VelvetPoutAppStorageKey.velvetPoutPushToken) }
        set { velvetPoutDefaults.set(newValue, forKey: VelvetPoutAppStorageKey.velvetPoutPushToken) }
    }

    static var velvetPoutH5Url: String {
        get { velvetPoutStringValue(for: VelvetPoutAppStorageKey.velvetPoutH5Url) }
        set { velvetPoutDefaults.set(newValue, forKey: VelvetPoutAppStorageKey.velvetPoutH5Url) }
    }

    private static func velvetPoutStringValue(for velvetPoutKey: String) -> String {
        velvetPoutDefaults.string(forKey: velvetPoutKey) ?? ""
    }
}

var velvetPoutUsersOrderCode: String = ""
