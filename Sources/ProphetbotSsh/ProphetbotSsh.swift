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
  @Argument(help: "The action to execute")
  var command: ProphetbotCommand = ProphetbotCommand.ssh

  func run() async throws {
    ProphetbotCore.setIcon(executablePath: Bundle.main.executablePath)

    let context = LAContext()
    var error: NSError?
    guard context.canEvaluatePolicy(ProphetbotCore.policy, error: &error) else {
      print("Cannot leverage deviceOwnerAuthenticationWithBiometrics")
      throw ExitCode.failure
    }

    switch command {
    case ProphetbotCommand.clear:
      try clear()
    case ProphetbotCommand.ssh:
      try await ssh()
    case ProphetbotCommand.setup:
      setup()
    }
  }

  func clear() throws {
    try ProphetbotCore.clear()
  }

  func setup() {
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

  func ssh() async throws {
    guard try ProphetbotCore.exists() else { throw ExitCode.failure }

    let account = Account(
      mechanism: AccountMechanism.SSH
    )

    let context = LAContext()
    try await context.evaluatePolicy(
      ProphetbotCore.policy, localizedReason: ProphetbotCore.description)
    let password = try ProphetbotCore.get(account: account)
    print(password)
  }
}
