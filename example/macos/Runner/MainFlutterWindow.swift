import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController
    self.setContentSize(NSSize(width: 1320, height: 920))
    self.minSize = NSSize(width: 480, height: 500)
    self.center()
    self.title = "Ianvs Design"
    self.titlebarAppearsTransparent = true
    self.appearance = NSAppearance(named: .darkAqua)

    let windowChannel = FlutterMethodChannel(
      name: "ianvs_design_gallery/window",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    windowChannel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "appearance", let mode = call.arguments as? String else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.appearance = NSAppearance(named: mode == "dark" ? .darkAqua : .aqua)
      result(nil)
    }

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
