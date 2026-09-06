import AppKit
import ArgumentParser
import Foundation
import LocalAuthentication
import ProphetbotCore

// https://github.com/gpg/libgpg-error/blob/220a427b4f997ef6af1b2d4e82ef1dc96e0cd6ff/src/err-codes.h.in
let GPG_ERR_GENERAL = 1
let GPG_ERR_NOT_IMPLEMENTED = 69
let GPG_ERR_UNKNOWN_OPTION = 174

enum ProphetbotCommand: String, ExpressibleByArgument {
  case clear, gpg, setup
}

@main
struct ProphetbotGpg: AsyncParsableCommand {
  @Argument(help: "The action to execute")
  var command: ProphetbotCommand = ProphetbotCommand.gpg

  func run() async throws {
    // TODO: Investigate if a different flushing approach would be better
    setbuf(__stdoutp, nil)

    let context = LAContext()
    var error: NSError?
    guard context.canEvaluatePolicy(ProphetbotCore.policy, error: &error) else {
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
    }
  }

  func clear() throws {
    try ProphetbotCore.clear()
  }

  func gpg() async throws {
    guard try ProphetbotCore.exists() else { throw ExitCode.failure }

    let account = Account(
      mechanism: AccountMechanism.GPG,
    )

    print("OK")
    while let input = readLine() {
      switch input.lowercased().split(separator: " ")[0] {
      case "getpin":
        do {
          // TODO: Look into if/whether context should be reused
          let context = LAContext()
          try await context.evaluatePolicy(
            ProphetbotCore.policy, localizedReason: ProphetbotCore.description)
          let password = try ProphetbotCore.get(account: account)
          print("D \(password)")
          print("OK")
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
    print("Enter GPG passphrase > ", terminator: "")
    if let password = readLine() {
      let account = Account(mechanism: AccountMechanism.GPG)
      if ProphetbotCore.set(account: account, password: password) {
        print("Successfully stored passphrase")
      } else {
        print("Failed to store passphrase")
      }
    }
  }
}
