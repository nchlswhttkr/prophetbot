import AppKit
import ArgumentParser
import Foundation
import LocalAuthentication
import ProphetbotCore

enum ProphetbotCommand: String, ExpressibleByArgument {
  case clear, setup, ssh
}

@main
struct ProphetbotGpg: AsyncParsableCommand {
  @Flag(help: "Clear the stored passphrase on start")
  var clear = false

  @Flag(help: "Prompt for a new passphrase on start")
  var setup = false

  @Argument(help: "The prompt to show user for input")
  var prompt: [String] = []

  func run() async throws {
    let context = LAContext()
    var error: NSError?
    guard context.canEvaluatePolicy(ProphetbotCore.policy, error: &error) else {
      print("Cannot leverage deviceOwnerAuthenticationWithBiometrics")
      throw ExitCode.failure
    }

    if clear {
      try ProphetbotCore.clear()
    }

    if setup {
      print("Enter SSH passphrase > ", terminator: "")
      if let password = readLine() {
        let account = Account(mechanism: AccountMechanism.SSH)
        if ProphetbotCore.set(account: account, password: password) {
          print("Successfully stored passphrase")
        } else {
          print("Failed to store passphrase")
        }
      }
    }

    guard try ProphetbotCore.exists() else { throw ExitCode.failure }

    let account = Account(
      mechanism: AccountMechanism.SSH
    )

    try await context.evaluatePolicy(
      ProphetbotCore.policy, localizedReason: "unlock your SSH key passphrases")
    let password = try ProphetbotCore.get(account: account)
    print(password)
  }
}
