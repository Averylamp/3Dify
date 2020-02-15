//
//  ViewController.swift
//  3Dify
//
//  Created by Avery Lamp on 2/14/20.
//  Copyright © 2020 Avery Lamp. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> MainViewController? {
    let vcName = String(describing: MainViewController.self)
    let storyboard = R.storyboard.<#name#>
    guard let <#Name#> = storyboard.instantiateInitialViewController() else {
      fatalError("Unable to instantiate \(vcName)")
    }
    return <#Name#>
  }
  
}
