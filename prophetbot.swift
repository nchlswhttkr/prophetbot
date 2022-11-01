
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
    if status == errSecSuccess {
        return true
    }
    if let message = SecCopyErrorMessageString(status, nil) {
        print(message)
    }
    return false
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

    guard status == errSecSuccess,
      let passwordData = item as? Data,
      let password = String(data: passwordData, encoding:String.Encoding.utf8)
    else { return nil }

    return password
}

let context = LAContext()
context.touchIDAuthenticationAllowableReuseDuration = 30

var error: NSError?
guard context.canEvaluatePolicy(policy, error: &error) else {
    print("Cannot leverage deviceOwnerAuthenticationWithBiometrics")
    exit(EXIT_FAILURE)
}

let _ = set(password: "Hello world!")
context.evaluatePolicy(policy, localizedReason: description) { success, error in
    if success && error == nil {
        guard let password = get() else {
            print("Failed to retrieve password")
            exit(EXIT_FAILURE)
        }
        print(password)
    } else {
        let errorDescription = error?.localizedDescription ?? "Unknown error"
        print(errorDescription)
    }
}
dispatchMain()