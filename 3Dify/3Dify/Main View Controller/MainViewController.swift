//
//  ViewController.swift
//  3Dify
//
//  Created by Avery Lamp on 2/14/20.
//  Copyright © 2020 Avery Lamp. All rights reserved.
//

import UIKit
import Photos

class MainViewController: UIViewController {

  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> MainViewController? {
    let vcName = String(describing: MainViewController.self)
    let storyboard = R.storyboard.mainViewController
    guard let mainVC  = storyboard.instantiateInitialViewController() else {
      fatalError("Unable to instantiate \(vcName)")
    }
    return mainVC
  }

  @IBAction func pickerClicked(_ sender: Any) {
    guard let portraitPickerVC = PortraitPhotoPickerViewController.instantiate() else {
      fatalError("Failed to create portrait picker")
    }
    portraitPickerVC.pickerDelegate = self
    self.present(portraitPickerVC, animated: true, completion: nil)
    
  }
  
}

// MARK: Life Cycle
extension  MainViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
    self.stylize()
  }
  
  /// Setup should only be called once
  func setup() {
    let status = PHPhotoLibrary.authorizationStatus()
    switch status {
    case .denied, .notDetermined, .restricted:
      self.requestPhotoLibraryPermissions()
    default:
      print("Photo Library Permission granted")

    }

  }
  
  func requestPhotoLibraryPermissions() {
    PHPhotoLibrary.requestAuthorization { (status) in
      print(status)
    }
  }
  
  /// Stylize should only be called once
  func stylize() {
    
  }
  
}

extension MainViewController: PortraitPhotoPickerProtocol {
  
  func didPickPortraitPhoto(phAsset: PHAsset) {
    guard let cloudVisualizerVC = DifyCloudVisualizerViewController.instantiate(phAsset: phAsset) else {
      fatalError("Failed to instantiate Cloud Visualizer")
    }
    
    self.navigationController?.pushViewController(cloudVisualizerVC, animated: true)
    
  }
}
