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

  @IBOutlet weak var collectionView: UICollectionView!
  
  let flowLayout = UICollectionViewFlowLayout()
  
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
    
    flowLayout.scrollDirection = UICollectionView.ScrollDirection.vertical
    self.collectionView.collectionViewLayout = flowLayout
    collectionView.dataSource = self
    self.loadCollectionData()
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

// MARK: UICollectionView
extension MainViewController: UICollectionViewDataSource {
  
  func loadCollectionData() {
    
  }
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 10
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.mainCollectionViewCell.identifier, for: indexPath) as? MainPortraitCollectionViewCell else {
      return UICollectionViewCell()
    }
    
    return cell
  }
  
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let edgeSize: CGFloat = self.collectionView.frame.width / 2 - 14
    
    return CGSize(width: edgeSize, height: edgeSize)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets.zero
  }
  
}

extension MainViewController: UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    print("Collection View selected item at: \(indexPath.item)")
  }
  
}
