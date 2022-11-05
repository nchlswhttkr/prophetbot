
import Foundation
import LocalAuthentication

let service = "cloud.nicholas.prophetbot"
let description = "unlock your GPG key"
let policy = LAPolicy.deviceOwnerAuthenticationWithBiometrics

func set(password: String) -> Bool {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: service,
        kSecValueData as String: password
    ]
    let status = SecItemAdd(query as CFDictionary, nil)

    return status == errSecSuccess
}

func get() -> String? {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: service,
        kSecMatchLimit as String: kSecMatchLimitOne,
        kSecReturnData as String: true
    ]
    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)

    guard status != errSecItemNotFound else { return nil }
    guard status == errSecSuccess,
      let passwordData = item as? Data,
      let password = String(data: passwordData, encoding:String.Encoding.utf8)
    else { exit(EXIT_FAILURE) }
    return password
}

func exists() -> Bool {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: service,
        kSecMatchLimit as String: kSecMatchLimitOne,
        kSecReturnData as String: false
    ]
    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)

    guard status != errSecItemNotFound else { return false }
    guard status == errSecSuccess else { exit(EXIT_FAILURE) }
    return true
}

let context = LAContext()
context.touchIDAuthenticationAllowableReuseDuration = 30

var error: NSError?
guard context.canEvaluatePolicy(policy, error: &error) else {
    print("Cannot leverage deviceOwnerAuthenticationWithBiometrics")
    exit(EXIT_FAILURE)
}

if exists() {
    context.evaluatePolicy(policy, localizedReason: description) { success, error in
        if success && error == nil {
            guard let password = get() else {
                print("Failed to retrieve password")
                exit(EXIT_FAILURE)
            }
            print(password)
        } else {
            exit(EXIT_FAILURE)
        }
    }
} else {
    print("Enter GPG passphrase > ", terminator: "")
    if let password = readLine() {
        if set(password: password) {
            print("Successfully stored passphrase")
        } else {
            print("Failed to store passphrase")
        }
    }
}
