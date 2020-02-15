//
//  PortraitPhotoPickerViewController.swift
//  3Dify
//
//  Created by Avery Lamp on 2/15/20.
//  Copyright © 2020 Avery Lamp. All rights reserved.
//

import UIKit

class PortraitPhotoPickerViewController: UIViewController {
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> PortraitPhotoPickerViewController? {
    let vcName = String(describing: PortraitPhotoPickerViewController.self)
    let storyboard = R.storyboard.portraitPhotoPickerViewController
    guard let portraitPhotoVC = storyboard.instantiateInitialViewController() else {
      fatalError("Unable to instantiate \(vcName)")
    }
    return portraitPhotoVC
  }
  
}
