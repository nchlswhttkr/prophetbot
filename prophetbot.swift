import Foundation
import LocalAuthentication

let service = "cloud.nicholas.prophetbot"
let description = "unlock your GPG key"
let policy = LAPolicy.deviceOwnerAuthenticationWithBiometrics

// https://github.com/gpg/libgpg-error/blob/220a427b4f997ef6af1b2d4e82ef1dc96e0cd6ff/src/err-codes.h.in
let GPG_ERR_GENERAL = 1
let GPG_ERR_NOT_IMPLEMENTED = 69
let GPG_ERR_UNKNOWN_OPTION = 174

func set(password: String) -> Bool {
  let query: [String: Any] = [
    kSecClass as String: kSecClassGenericPassword,
    kSecAttrService as String: service,
    kSecValueData as String: password,
  ]
  let status = SecItemAdd(query as CFDictionary, nil)

  return status == errSecSuccess
}

func get() -> String? {
  let query: [String: Any] = [
    kSecClass as String: kSecClassGenericPassword,
    kSecAttrService as String: service,
    kSecMatchLimit as String: kSecMatchLimitOne,
    kSecReturnData as String: true,
  ]
  var item: CFTypeRef?
  let status = SecItemCopyMatching(query as CFDictionary, &item)

  guard status != errSecItemNotFound else { return nil }
  guard status == errSecSuccess,
    let passwordData = item as? Data,
    let password = String(data: passwordData, encoding: String.Encoding.utf8)
  else { exit(EXIT_FAILURE) }
  return password
}

func exists() -> Bool {
  let query: [String: Any] = [
    kSecClass as String: kSecClassGenericPassword,
    kSecAttrService as String: service,
    kSecMatchLimit as String: kSecMatchLimitOne,
    kSecReturnData as String: false,
  ]
  var item: CFTypeRef?
  let status = SecItemCopyMatching(query as CFDictionary, &item)

  guard status != errSecItemNotFound else { return false }
  guard status == errSecSuccess else { exit(EXIT_FAILURE) }
  return true
}

// TODO: Investigate if a different flushing approach would be better
setbuf(__stdoutp, nil)

let context = LAContext()
var error: NSError?
guard context.canEvaluatePolicy(policy, error: &error) else {
  print("Cannot leverage deviceOwnerAuthenticationWithBiometrics")
  exit(EXIT_FAILURE)
}

if exists() {
  print("OK")
  while let input = readLine() {
    switch input.lowercased().split(separator: " ")[0] {
    case "getpin":
      // TODO: Move to get() to reduce this switch block
      context.evaluatePolicy(policy, localizedReason: description) { success, _ in
        if success {
          let password = get()
          if password != nil {
            print("D \(password!)")
            print("OK")
          } else {
            print("ERR \(GPG_ERR_GENERAL) Failed to retrieve password")
          }
        } else {
          print("ERR \(GPG_ERR_GENERAL) Authentication policy evaluation failed")
        }
      }
    case "bye":
      print("OK")
      exit(EXIT_SUCCESS)
    case "option", "setkeyinfo", "setdesc", "setprompt":
      // Some commands must be implemented, so stub them out
      print("OK")
    default:
      print("ERR \(GPG_ERR_NOT_IMPLEMENTED) Command not implemented")
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
