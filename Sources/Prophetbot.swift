import AppKit
import ArgumentParser
import Foundation
import LocalAuthentication

let service = "cloud.nicholas.prophetbot"
let description = "unlock your GPG key"
let policy = LAPolicy.deviceOwnerAuthenticationWithBiometrics

// https://github.com/gpg/libgpg-error/blob/220a427b4f997ef6af1b2d4e82ef1dc96e0cd6ff/src/err-codes.h.in
let GPG_ERR_GENERAL = 1
let GPG_ERR_NOT_IMPLEMENTED = 69
let GPG_ERR_UNKNOWN_OPTION = 174

enum AccountMechanism: String {
  case GPG, SSH
}

struct Account {
  var mechanism: AccountMechanism
  var id: String
}

extension Account: CustomStringConvertible {
  var description: String {
    return "\(mechanism)"  // TODO: Add ID once implementations read key info
  }
}

func clear() throws {
  let query: [String: Any] = [
    kSecClass as String: kSecClassGenericPassword,
    kSecAttrService as String: service,
    kSecMatchLimit as String: kSecMatchLimitOne,
    kSecReturnData as String: false,
  ]
  let status = SecItemDelete(query as CFDictionary)

  guard status == errSecSuccess else { throw ExitCode.failure }
}

func set(account: Account, password: String) -> Bool {
  let query: [String: Any] = [
    kSecClass as String: kSecClassGenericPassword,
    kSecAttrAccount as String: String(describing: account),
    kSecAttrService as String: service,
    kSecValueData as String: password,
  ]
  let status = SecItemAdd(query as CFDictionary, nil)

  return status == errSecSuccess
}

func get(account: Account) throws -> String {
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

func exists() throws -> Bool {
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

enum ProphetbotCommand: String, ExpressibleByArgument {
  case clear, gpg, setup, ssh
}

@main
struct Prophetbot: AsyncParsableCommand {
  @Argument(help: "The action to execute")
  var command: ProphetbotCommand

  func run() async throws {
    if let iconUrl = Bundle.module.url(forResource: "icon", withExtension: "png") {
      let icon = NSImage(byReferencing: iconUrl)
      if let executablePath = Bundle.main.executablePath {
        NSWorkspace.shared.setIcon(icon, forFile: executablePath)
      }
    }

    // TODO: Investigate if a different flushing approach would be better
    setbuf(__stdoutp, nil)

    // TODO: Look into if/whether context should be reused
    let context = LAContext()
    var error: NSError?
    guard context.canEvaluatePolicy(policy, error: &error) else {
      print("Cannot leverage deviceOwnerAuthenticationWithBiometrics")
      throw ExitCode.failure
    }

    switch command {
    case ProphetbotCommand.clear:
      try clear()
    case ProphetbotCommand.gpg:
      try await gpg()
    case ProphetbotCommand.setup:
      setup()
    case ProphetbotCommand.ssh:
      try await ssh()
    }
  }

  func gpg() async throws {
    guard try exists() else { throw ExitCode.failure }

    let account = Account(
      mechanism: AccountMechanism.GPG,
      id: ""
    )

    print("OK")
    while let input = readLine() {
      switch input.lowercased().split(separator: " ")[0] {
      case "getpin":
        do {
          // TODO: Look into if/whether context should be reused
          let context = LAContext()
          try await context.evaluatePolicy(policy, localizedReason: description)
          let password = try get(account: account)
          print("D \(password)")
        } catch {
          print("ERR Authentication policy evaluation failed")
        }
      case "bye":
        print("OK")
        throw ExitCode.success
      case "option", "setkeyinfo", "setdesc", "setprompt":
        // Some commands must be implemented, so stub them out
        print("OK")
      default:
        print("ERR \(GPG_ERR_NOT_IMPLEMENTED) Command not implemented")
      }
    }
  }

  func setup() {
    let account = Account(
      mechanism: AccountMechanism.GPG,
      id: ""
    )
    print("Enter GPG passphrase > ", terminator: "")
    if let password = readLine() {
      if set(account: account, password: password) {
        print("Successfully stored passphrase")
      } else {
        print("Failed to store passphrase")
      }
    }
  }
  func ssh() async throws {
    guard try exists() else { throw ExitCode.failure }

    let account = Account(
      mechanism: AccountMechanism.SSH,
      id: ""
    )

    // TODO: Look into if/whether context should be reused
    let context = LAContext()
    try await context.evaluatePolicy(policy, localizedReason: description)
    let password = try get(account: account)
    print(password)
  }
}
