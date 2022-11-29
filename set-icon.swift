import AppKit

let path = FileManager.default.currentDirectoryPath;
let image = NSImage(contentsOfFile: "\(path)/icon.png")
NSWorkspace.shared.setIcon(image, forFile: "/usr/local/bin/prophetbot")
