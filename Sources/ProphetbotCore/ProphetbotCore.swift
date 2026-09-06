import AppKit
import ArgumentParser
import Foundation
import LocalAuthentication

let service = "cloud.nicholas.prophetbot"

public struct ProphetbotCore {
  public static let description = "unlock your GPG key"
  public static let policy = LAPolicy.deviceOwnerAuthenticationWithBiometrics

  public static func clear() throws {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecMatchLimit as String: kSecMatchLimitOne,
      kSecReturnData as String: false,
    ]
    let status = SecItemDelete(query as CFDictionary)

    guard status == errSecSuccess else { throw ExitCode.failure }
  }

  public static func set(account: Account, password: String) -> Bool {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: String(describing: account),
      kSecAttrService as String: service,
      kSecValueData as String: password,
    ]
    let status = SecItemAdd(query as CFDictionary, nil)

    return status == errSecSuccess
  }

  public static func get(account: Account) throws -> String {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: String(describing: account),
      kSecAttrService as String: service,
      kSecMatchLimit as String: kSecMatchLimitOne,
      kSecReturnData as String: true,
    ]
    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)

    guard status != errSecItemNotFound else { throw ExitCode.failure }
    guard status == errSecSuccess,
      let passwordData = item as? Data,
      let password = String(data: passwordData, encoding: String.Encoding.utf8)
    else { throw ExitCode.failure }
    return password
  }

  public static func exists() throws -> Bool {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecMatchLimit as String: kSecMatchLimitOne,
      kSecReturnData as String: false,
    ]
    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)

    guard status != errSecItemNotFound else { return false }
    guard status == errSecSuccess else { throw ExitCode.failure }
    return true
  }

  public static func setIcon(executablePath: String?) {
    if let iconUrl = Bundle.module.url(forResource: "icon", withExtension: "png") {
      let icon = NSImage(byReferencing: iconUrl)
      if let forFile = executablePath {
        NSWorkspace.shared.setIcon(icon, forFile: forFile)
      }
    }
  }
}

public enum AccountMechanism: String {
  case GPG, SSH
}

public struct Account {
  public var mechanism: AccountMechanism
  public var id: String

  public init(mechanism: AccountMechanism, id: String = "") {
    self.mechanism = mechanism
    self.id = id
  }
}

extension Account: CustomStringConvertible {
  public var description: String {
    return "\(mechanism)"  // TODO: Add ID once implementations read key info
  }
}
