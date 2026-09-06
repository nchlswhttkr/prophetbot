import AppKit
import ArgumentParser
import Foundation

@main
struct SetIcon: ParsableCommand {
  @Argument(help: "The Prophetbot binary to set icons on")
  var binary: String

  func run() throws {
    if let iconUrl = Bundle.module.url(forResource: "icon", withExtension: "png") {
      let icon = NSImage(byReferencing: iconUrl)
      let forFile = "\(FileManager.default.currentDirectoryPath)/\(binary)"

      let result = NSWorkspace.shared.setIcon(icon, forFile: forFile)
      guard result else { throw ExitCode.failure }
    }
  }
}
