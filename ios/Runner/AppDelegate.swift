import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  private var pendingAvatarResult: FlutterResult?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    configureAvatarPickerChannel()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func configureAvatarPickerChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }

    let channel = FlutterMethodChannel(
      name: "numi/avatar_picker",
      binaryMessenger: controller.binaryMessenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "pickAvatar" else {
        result(FlutterMethodNotImplemented)
        return
      }

      self?.pickAvatar(result: result)
    }
  }

  private func pickAvatar(result: @escaping FlutterResult) {
    guard pendingAvatarResult == nil else {
      result(
        FlutterError(
          code: "picker_active",
          message: "An avatar picker is already open.",
          details: nil
        )
      )
      return
    }

    guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
      result(
        FlutterError(
          code: "picker_unavailable",
          message: "Photo library is not available.",
          details: nil
        )
      )
      return
    }

    pendingAvatarResult = result
    let picker = UIImagePickerController()
    picker.sourceType = .photoLibrary
    picker.delegate = self
    window?.rootViewController?.present(picker, animated: true)
  }

  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true)
    pendingAvatarResult?(nil)
    pendingAvatarResult = nil
  }

  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
  ) {
    picker.dismiss(animated: true)

    do {
      let path = try copyAvatarToCache(info: info)
      pendingAvatarResult?(path)
    } catch {
      pendingAvatarResult?(
        FlutterError(
          code: "avatar_copy_failed",
          message: error.localizedDescription,
          details: nil
        )
      )
    }

    pendingAvatarResult = nil
  }

  private func copyAvatarToCache(info: [UIImagePickerController.InfoKey: Any]) throws -> String {
    let fileManager = FileManager.default
    let cacheDirectory = fileManager.temporaryDirectory

    if let imageUrl = info[.imageURL] as? URL {
      let destination = cacheDirectory.appendingPathComponent(
        "avatar_\(Int(Date().timeIntervalSince1970 * 1000)).\(imageUrl.pathExtension)"
      )
      if fileManager.fileExists(atPath: destination.path) {
        try fileManager.removeItem(at: destination)
      }
      try fileManager.copyItem(at: imageUrl, to: destination)
      return destination.path
    }

    guard let image = info[.originalImage] as? UIImage,
          let data = image.jpegData(compressionQuality: 0.92) else {
      throw NSError(
        domain: "numi.avatar_picker",
        code: 0,
        userInfo: [NSLocalizedDescriptionKey: "Unable to read selected avatar."]
      )
    }

    let destination = cacheDirectory.appendingPathComponent(
      "avatar_\(Int(Date().timeIntervalSince1970 * 1000)).jpg"
    )
    try data.write(to: destination)
    return destination.path
  }
}
