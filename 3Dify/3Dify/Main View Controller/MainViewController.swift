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
  
  var selectedIndices: [IndexPath] = []
  
  @IBOutlet weak var new3DModelHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var viewButtonHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var arButtonHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var mergeButtonHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var modelButton: UIButton!
  @IBOutlet weak var viewButton: UIButton!
  @IBOutlet weak var arButton: UIButton!
  @IBOutlet weak var mergeButton: UIButton!
  
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
  
  @IBAction func newModelButtonClicked(_ sender: Any) {
    guard let portraitPickerVC = PortraitPhotoPickerViewController.instantiate() else {
      fatalError("Failed to create portrait picker")
    }
    portraitPickerVC.pickerDelegate = self
    self.present(portraitPickerVC, animated: true, completion: nil)
  }
  
  @IBAction func viewModelButtonClicked(_ sender: Any) {
    guard let model = DataStore.shared.allModels.first else {
      return
    }
    guard let modelEditorVC = PointCloudEditorViewController.instantiate(model: model) else {
      fatalError("Failed to instantiate model editor" )
    }
    
    self.navigationController?.pushViewController(modelEditorVC, animated: true)
    
  }
  
  @IBAction func arButtonClicked(_ sender: Any) {
  }
  
  @IBAction func mergeButtonClicked(_ sender: Any) {
    guard let model1Index = self.selectedIndices.first,
      let model2Index = self.selectedIndices.last,
      model1Index != model2Index else {
        return
    }
    guard let mergeRotationVC = MergeRotationViewController.instantiate(model1: DataStore.shared.allModels[model1Index.row],
                                                                        model2: DataStore.shared.allModels[model2Index.row]) else {
                                                                          print("Unable to instantiate roate vc")
                                                                          return
    }
    self.navigationController?.pushViewController(mergeRotationVC, animated: true)
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
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.delay(delay: 0.3) {
      self.updateEditOptions()
    }
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
    
    cell.containingView.layer.borderWidth = 6
    cell.containingView.layer.cornerRadius = 20
    
    if self.selectedIndices.contains(indexPath) {
      cell.selectedImageView.image = R.image.iconSelected()
      cell.containingView.layer.borderColor = UIColor(red: 0.84, green: 0.59, blue: 0.73, alpha: 1.00).cgColor
    } else {
      cell.containingView.layer.borderColor = UIColor.white.cgColor
      cell.selectedImageView.image = R.image.iconUnselected()
    }
    
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
  
  func updateEditOptions() {
    self.new3DModelHeightConstraint.constant = 0
    self.viewButtonHeightConstraint.constant = 0
    self.arButtonHeightConstraint.constant = 0
    self.mergeButtonHeightConstraint.constant = 0
    switch selectedIndices.count {
    case 0:
      self.new3DModelHeightConstraint.constant = 60.0
    case 1:
      self.viewButtonHeightConstraint.constant = 60.0
      self.arButtonHeightConstraint.constant = 60.0
    case 2:
      self.mergeButtonHeightConstraint.constant = 60.0
    default:
      return
    }
    UIView.animate(withDuration: 0.35) {
      self.view.layoutIfNeeded()
      switch self.selectedIndices.count {
        
      case 0:
        self.modelButton.alpha = 1.0
        self.viewButton.alpha = 0.0
        self.arButton.alpha = 0.0
        self.mergeButton.alpha = 0.0
      case 1:
        self.modelButton.alpha = 0.0
        self.viewButton.alpha = 1.0
        self.arButton.alpha = 1.0
        self.mergeButton.alpha = 0.0
      case 2:
        self.modelButton.alpha = 0.0
        self.viewButton.alpha = 0.0
        self.arButton.alpha = 0.0
        self.mergeButton.alpha = 1.0
        
      default:
        print("This shouldn't happens")
        
      }
    }
    
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if self.selectedIndices.contains(indexPath) {
      self.selectedIndices.removeAll(where: {$0 == indexPath})
      self.collectionView.reloadItems(at: [indexPath])
    } else {
      self.selectedIndices.append(indexPath)
    }
    if self.selectedIndices.count == 3 {
      let prevInd = self.selectedIndices
      self.selectedIndices = [indexPath]
      self.collectionView.reloadItems(at: prevInd)
    } else {
      self.collectionView.reloadItems(at: [indexPath])
    }
    self.updateEditOptions()
    
  }
  
}
