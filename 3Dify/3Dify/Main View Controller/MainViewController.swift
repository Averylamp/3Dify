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
  let cachingImageManager = PHCachingImageManager()
  
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
    
    collectionView.dataSource = self
    collectionView.delegate = self
    flowLayout.scrollDirection = UICollectionView.ScrollDirection.vertical
    self.collectionView.collectionViewLayout = flowLayout
    self.loadCollectionData()
    
    NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.modelsReloaded), name: .modelsReloaded, object: nil)
  }
  
  @objc func modelsReloaded() {
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
    guard let modelEditorVC = PointCloudEditorViewController.instantiate(model: StoredModel(phAsset: phAsset)) else {
      fatalError("Failed to instantiate model editor" )
    }
    
    self.delay(delay: 0.5) {
      
      self.navigationController?.pushViewController(modelEditorVC, animated: true)
    }
    
  }
}

// MARK: UICollectionView
extension MainViewController: UICollectionViewDataSource {
  
  func loadCollectionData() {
    
    self.collectionView.reloadData()
  }
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return DataStore.shared.allModels.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.mainCollectionViewCell.identifier, for: indexPath)
      as? MainPortraitCollectionViewCell else {
      return UICollectionViewCell()
    }
    
    cell.containingView.layer.borderColor = UIColor.white.cgColor
    cell.containingView.layer.borderWidth = 6
    cell.containingView.layer.cornerRadius = 20
    
    let currentTag: Int = indexPath.row
    cell.tag = currentTag
    
    let scale = UIScreen.main.scale
    let assetGridThumbnailSize = CGSize(width: cell.frame.size.width * scale, height: cell.frame.size.height * scale)
    self.cachingImageManager.requestImage(for: DataStore.shared.allModels[indexPath.row].phAsset,
                                     targetSize: assetGridThumbnailSize,
                                     contentMode: .aspectFill,
                                     options: nil) { (image, _) in
      if cell.tag == currentTag {
        cell.imageView.image = image
      }
    }
    return cell
  }
  
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let edgeSize: CGFloat = self.collectionView.frame.width / 2 - 8
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
