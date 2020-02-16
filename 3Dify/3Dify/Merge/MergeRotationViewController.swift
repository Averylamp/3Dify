//
//  MergeRotationViewController.swift
//  3Dify
//
//  Created by Avery Lamp on 2/16/20.
//  Copyright © 2020 Avery Lamp. All rights reserved.
//

import UIKit

class MergeRotationViewController: UIViewController {
  
  var model1: StoredModel!
  var model2: StoredModel!
  
  @IBOutlet weak var model1ContainerView: UIView!
  @IBOutlet weak var model2ContainerView: UIView!
  
  @IBOutlet weak var confirmButton: UIButton!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(model1: StoredModel, model2: StoredModel) -> MergeRotationViewController? {
    let vcName = String(describing: MergeRotationViewController.self)
    let storyboard = R.storyboard.mergeRotationViewController
    guard let mergeRotateVC = storyboard.instantiateInitialViewController() else {
      fatalError("Unable to instantiate \(vcName)")
    }
    mergeRotateVC.model1 = model1
    mergeRotateVC.model2 = model2
    return mergeRotateVC
  }
  
  @IBAction func confirmButtonClicked(_ sender: Any) {
    
  }
  
}

// MARK: Life Cycle
extension  MergeRotationViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
    self.stylize()
  }
  
  /// Setup should only be called once
  func setup() {
    self.setupModel1()
  }
  
  func setupModel1() {
    guard let visualizerVC = DifyCloudVisualizerViewController.instantiate(phAsset: self.model1.phAsset) else {
      fatalError("Failed to instantiate visualizer")
    }
    
    visualizerVC.distance = self.model1.distance
    visualizerVC.zScale = self.model1.zScale
    visualizerVC.zThreshold = self.model1.zThreshold
    visualizerVC.smoothing = self.model1.smoothing
    
    self.addChild(visualizerVC)
    visualizerVC.view.translatesAutoresizingMaskIntoConstraints = false
    self.model1ContainerView.addSubview(visualizerVC.view)
    
    self.model1ContainerView.addConstraints([
      NSLayoutConstraint(item: self.model1ContainerView as Any, attribute: .centerX, relatedBy: .equal,
                         toItem: visualizerVC.view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: self.model1ContainerView as Any, attribute: .centerY, relatedBy: .equal,
      toItem: visualizerVC.view, attribute: .centerY, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: self.model1ContainerView as Any, attribute: .width, relatedBy: .equal,
      toItem: visualizerVC.view, attribute: .width, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: self.model1ContainerView as Any, attribute: .height, relatedBy: .equal,
      toItem: visualizerVC.view, attribute: .height, multiplier: 1.0, constant: 0.0)
    ])
    
    visualizerVC.didMove(toParent: self)
  }
  
  /// Stylize should only be called once
  func stylize() {
    self.confirmButton.layer.borderWidth = 6
    self.confirmButton.layer.borderColor = UIColor.white.cgColor
    self.confirmButton.layer.cornerRadius = 20
  }
  
}
