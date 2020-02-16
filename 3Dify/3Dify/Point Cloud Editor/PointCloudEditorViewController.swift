//
//  PointCloudEditorViewController.swift
//  3Dify
//
//  Created by Avery Lamp on 2/16/20.
//  Copyright © 2020 Avery Lamp. All rights reserved.
//

import UIKit

class PointCloudEditorViewController: UIViewController {
  
  @IBOutlet weak var sceneViewContainer: UIView!

  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var distanceSlider: UISlider!
  
  @IBOutlet weak var backgroundLabel: UILabel!
  @IBOutlet weak var backgroundSlider: UISlider!
  
  @IBOutlet weak var depthLabel: UILabel!
  @IBOutlet weak var depthSlider: UISlider!
  
  @IBOutlet weak var smoothingLabel: UILabel!
  @IBOutlet weak var smoothingSlider: UISlider!
  
  var model: StoredModel!
  
  var sceneVC: DifyCloudVisualizerViewController?

  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(model: StoredModel) -> PointCloudEditorViewController? {
    let vcName = String(describing: PointCloudEditorViewController.self)
    let storyboard = R.storyboard.pointCloudEditorViewController
    guard let pointCloudEditorVC = storyboard.instantiateInitialViewController() else {
      fatalError("Unable to instantiate \(vcName)")
    }
    pointCloudEditorVC.model = model
    return pointCloudEditorVC
  }
  
  @IBAction func updateButtonClicked(_ sender: Any) {
    self.updateSceneView()
  }
  @IBAction func continueButtonClicked(_ sender: Any) {
  }
}

// MARK: Life Cycle
extension  PointCloudEditorViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
    self.stylize()
  }
  
  /// Setup should only be called once
  func setup() {
    
    self.backgroundSlider.value = self.model.zThreshold
    
    self.loadSceneView()
  }
  
  func loadSceneView() {
    if let sceneVC = self.sceneVC {
      sceneVC.sceneView.scene?.rootNode.childNodes.forEach({ $0.removeFromParentNode() })
      sceneVC.view.removeFromSuperview()
      sceneVC.removeFromParent()
      self.sceneViewContainer.subviews.forEach({ $0.removeFromSuperview() })
    }
    
    guard let visualizerVC = DifyCloudVisualizerViewController.instantiate(phAsset: self.model.phAsset) else {
      fatalError("Failed to instantiate visualizer")
    }
    
    visualizerVC.zThreshold = model.zThreshold
    visualizerVC.distance = model.distance
    
    self.sceneVC  = visualizerVC
    self.addChild(visualizerVC)
    visualizerVC.view.translatesAutoresizingMaskIntoConstraints = false
    self.sceneViewContainer.addSubview(visualizerVC.view)
    
    self.sceneViewContainer.addConstraints([
      NSLayoutConstraint(item: self.sceneViewContainer as Any, attribute: .centerX, relatedBy: .equal,
                         toItem: visualizerVC.view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: self.sceneViewContainer as Any, attribute: .centerY, relatedBy: .equal,
      toItem: visualizerVC.view, attribute: .centerY, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: self.sceneViewContainer as Any, attribute: .width, relatedBy: .equal,
      toItem: visualizerVC.view, attribute: .width, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: self.sceneViewContainer as Any, attribute: .height, relatedBy: .equal,
      toItem: visualizerVC.view, attribute: .height, multiplier: 1.0, constant: 0.0)
    ])
    
    visualizerVC.didMove(toParent: self)
  }
  
  func updateModelWithSliders() {
    self.model.distance = self.distanceSlider.value
    self.model.zScale = self.depthSlider.value
    self.model.zThreshold = self.backgroundSlider.value
//    self.model.zScale = self.smoothingSlider.value
  }
  
  func updateSceneView() {
    if let sceneVC = self.sceneVC {
      self.updateModelWithSliders()
      sceneVC.distance = self.model.distance
      sceneVC.zScale = self.model.zScale
      sceneVC.zThreshold = self.model.zThreshold
      sceneVC.update()
    }
  }
  
  /// Stylize should only be called once
  func stylize() {
    self.depthLabel.addCharacterSpacing(kernValue: 5)
    self.backgroundLabel.addCharacterSpacing(kernValue: 5)
    self.distanceLabel.addCharacterSpacing(kernValue: 5)
    self.smoothingLabel.addCharacterSpacing(kernValue: 5)
  }
  
}
