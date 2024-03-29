//
//  MergeRotationViewController.swift
//  3Dify
//
//  Created by Avery Lamp on 2/16/20.
//  Copyright © 2020 Avery Lamp. All rights reserved.
//

import UIKit
import LTMorphingLabel

class MergeRotationViewController: UIViewController {
  
  var model1: StoredModel!
  var model2: StoredModel!
  
  @IBOutlet weak var model1ContainerView: UIView!
  @IBOutlet weak var model2ContainerView: UIView!
  
  @IBOutlet weak var confirmButton: UIButton!
  
  weak var model1VC: DifyCloudVisualizerViewController?
  weak var model2VC: DifyCloudVisualizerViewController?
  
  let rotationLabel = UILabel()
  var rotation: Double = 0.0
  
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
  @IBAction func panGestureRecognizerSwiped(_ sender: UIPanGestureRecognizer) {
    let translation = sender.translation(in: self.model2ContainerView).x
    print(translation)
    if let model2VC = self.model2VC {
      rotation += Double(translation) / 100
      self.rotationLabel.text = "Rotation: \(Double(round(1000 * rotation)/1000))"
      sender.setTranslation(CGPoint.zero, in: self.model2ContainerView)
      model2VC.anchorNode.eulerAngles.y += Float(translation) / 100
    }
  }
  
  @IBAction func confirmButtonClicked(_ sender: Any) {
    guard let transformVC = MergeTransformationViewController.instantiate(model1: self.model1, model2: self.model2, rotation: rotation) else {
      fatalError("failed to make transform vc")
    }
    self.navigationController?.pushViewController(transformVC, animated: true)
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
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
    self.setupModel2()
    self.view.addSubview(rotationLabel)
    rotationLabel.translatesAutoresizingMaskIntoConstraints = false
    rotationLabel.textColor = UIColor.white
    if let font = R.font.ibmPlexSans(size: 16) {
      rotationLabel.font = font
    }
    self.view.addConstraints([
      NSLayoutConstraint(item: rotationLabel, attribute: .centerX, relatedBy: .equal,
                         toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: rotationLabel, attribute: .bottom, relatedBy: .equal,
      toItem: self.confirmButton, attribute: .top, multiplier: 1.0, constant: -8.0)
    ])
  }
  
  func setupModel1() {
    guard let visualizerVC = DifyCloudVisualizerViewController.instantiate(phAsset: self.model1.phAsset) else {
      fatalError("Failed to instantiate visualizer")
    }
    self.model1VC = visualizerVC
    
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
    visualizerVC.sceneView.isUserInteractionEnabled = false
    visualizerVC.sceneView.showsStatistics = false
  }
  
  func setupModel2() {
    guard let visualizerVC = DifyCloudVisualizerViewController.instantiate(phAsset: self.model2.phAsset) else {
      fatalError("Failed to instantiate visualizer")
    }
    
    self.model2VC = visualizerVC
    
    visualizerVC.distance = self.model1.distance
    visualizerVC.zScale = self.model1.zScale
    visualizerVC.zThreshold = self.model1.zThreshold
    visualizerVC.smoothing = self.model1.smoothing
    
    self.addChild(visualizerVC)
    visualizerVC.view.translatesAutoresizingMaskIntoConstraints = false
    self.model2ContainerView.addSubview(visualizerVC.view)
    
    self.model2ContainerView.addConstraints([
      NSLayoutConstraint(item: self.model2ContainerView as Any, attribute: .centerX, relatedBy: .equal,
                         toItem: visualizerVC.view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: self.model2ContainerView as Any, attribute: .centerY, relatedBy: .equal,
      toItem: visualizerVC.view, attribute: .centerY, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: self.model2ContainerView as Any, attribute: .width, relatedBy: .equal,
      toItem: visualizerVC.view, attribute: .width, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: self.model2ContainerView as Any, attribute: .height, relatedBy: .equal,
      toItem: visualizerVC.view, attribute: .height, multiplier: 1.0, constant: 0.0)
    ])
    
    visualizerVC.didMove(toParent: self)
    visualizerVC.sceneView.isUserInteractionEnabled = false
    visualizerVC.sceneView.showsStatistics = false
    self.delay(delay: 2) {
      if let model1VC = self.model1VC {
        let model1PointCloud = model1VC.getPointCloud()
        model1PointCloud.opacity = 0.3
        visualizerVC.sceneView.scene?.rootNode.addChildNode(model1PointCloud)
      }
    }
  }
  
  /// Stylize should only be called once
  func stylize() {
    self.confirmButton.layer.borderWidth = 6
    self.confirmButton.layer.borderColor = UIColor.white.cgColor
    self.confirmButton.layer.cornerRadius = 20
  }
  
}
