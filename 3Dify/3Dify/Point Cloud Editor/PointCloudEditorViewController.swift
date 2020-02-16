//
//  PointCloudEditorViewController.swift
//  3Dify
//
//  Created by Avery Lamp on 2/16/20.
//  Copyright © 2020 Avery Lamp. All rights reserved.
//

import UIKit

class PointCloudEditorViewController: UIViewController {
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> PointCloudEditorViewController? {
    let vcName = String(describing: PointCloudEditorViewController.self)
    let storyboard = R.storyboard.pointCloudEditorViewController
    guard let pointCloudEditorVC = storyboard.instantiateInitialViewController() else {
      fatalError("Unable to instantiate \(vcName)")
    }
    return pointCloudEditorVC
  }
  
}
