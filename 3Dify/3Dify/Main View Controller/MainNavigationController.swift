//
//  MainNavigationController.swift
//  3Dify
//
//  Created by Avery Lamp on 2/15/20.
//  Copyright © 2020 Avery Lamp. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> MainNavigationController? {
    let vcName = String(describing: MainNavigationController.self)
    let storyboard = R.storyboard.mainNavigationController
    guard let mainNavVC = storyboard.instantiateInitialViewController() else {
      fatalError("Unable to instantiate \(vcName)")
    }
    return mainNavVC
  }
  
}
