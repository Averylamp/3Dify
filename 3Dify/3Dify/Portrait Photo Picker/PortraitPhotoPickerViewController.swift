//
//  PortraitPhotoPickerViewController.swift
//  3Dify
//
//  Created by Avery Lamp on 2/15/20.
//  Copyright © 2020 Avery Lamp. All rights reserved.
//

import UIKit
import Photos

class PortraitPhotoPickerViewController: UIViewController {
  
  @IBOutlet weak var imageCollectionView: UICollectionView!
  @IBOutlet weak var gridSizeSegmentedControl: UISegmentedControl!
  
  weak var pickerDelegate: PortraitPhotoPickerProtocol?
  
  var assetsInRow: CGFloat = 4
  let collectionViewEdgeInset: CGFloat = 4
  let flowLayout = UICollectionViewFlowLayout()
  let cachingImageManager = PHCachingImageManager()
  fileprivate var imageAssets: [PHAsset]! {
    willSet {
      cachingImageManager.stopCachingImagesForAllAssets()
    }
    
    didSet {
      cachingImageManager.startCachingImages(for: self.imageAssets, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.aspectFill, options: nil)
    }
  }
  
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
  
  @IBAction func gridSizeSegmentedControllerChanged(_ sender: Any) {
    self.changeNumberPerRow()
  }
  
}

// MARK: Life Cycle
extension  PortraitPhotoPickerViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
    self.stylize()
  }
  
  /// Setup should only be called once
  func setup() {
    self.title = "Portrait Mode Photos"
    self.setupCollectionView()
  }
  
  func setupCollectionView() {
    self.imageCollectionView.delegate = self
    self.imageCollectionView.dataSource = self
    
    flowLayout.scrollDirection = UICollectionView.ScrollDirection.vertical
    
    self.imageCollectionView.collectionViewLayout = flowLayout
    self.loadCollectionData()

  }
  
  /// Stylize should only be called once
  func stylize() {
    
  }
  
}

// MARK: UICollectionView
extension PortraitPhotoPickerViewController: UICollectionViewDataSource {
  
  func loadCollectionData() {
    let depthAlbums = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: .smartAlbumDepthEffect, options: nil)
    var depthAlbumPlaceholder: PHAssetCollection?
    print("Depth albums: \(depthAlbums.count)")
    depthAlbums.enumerateObjects { (collection, _, _) in
      depthAlbumPlaceholder = collection
    }
    
    guard  let depthAlbum = depthAlbumPlaceholder  else {
      fatalError("No Depth Albums available")
    }
    
    let allAssetsFetch = PHAsset.fetchAssets(in: depthAlbum, options: nil)
    self.imageAssets = allAssetsFetch.objects(at: IndexSet(integersIn: Range(NSRange(location: 0, length: allAssetsFetch.count))!)).reversed()
    self.imageCollectionView.reloadData()
  }
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.imageAssets.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.portraitPhotoCollectionViewCell.identifier,
                                                        for: indexPath) as? PortraitPhotoCollectionViewCell else {
      return UICollectionViewCell()
    }
    let currentTag: Int = indexPath.row
    cell.tag = currentTag
    
    let scale = UIScreen.main.scale
    let assetGridThumbnailSize = CGSize(width: cell.frame.size.width * scale, height: cell.frame.size.height * scale)
    self.cachingImageManager.requestImage(for: self.imageAssets[indexPath.row],
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

extension PortraitPhotoPickerViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let edgeSize = ((self.imageCollectionView.frame.size.width -  2 * collectionViewEdgeInset) / (assetsInRow)) - (2 * collectionViewEdgeInset)
    return CGSize(width: edgeSize, height: edgeSize)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
     return UIEdgeInsets.init(top: collectionViewEdgeInset, left: collectionViewEdgeInset, bottom: collectionViewEdgeInset, right: collectionViewEdgeInset)
  }
  
}

extension PortraitPhotoPickerViewController: UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    print("Collection View selected item at: \(indexPath.item)")
    let photo = self.imageAssets[indexPath.item]
    if let delegate = self.pickerDelegate {
      delegate.didPickPortraitPhoto(phAsset: photo)
    }
    self.dismiss(animated: true, completion: nil)
  }
  
}

extension PortraitPhotoPickerViewController {
  func changeNumberPerRow() {
     let newNumberPerRowString = self.gridSizeSegmentedControl.titleForSegment(at: self.gridSizeSegmentedControl.selectedSegmentIndex)
     guard let newNumberPerRow = Int(newNumberPerRowString ?? "unknown") else {
       print("Unable to parse new number per row")
       return
     }
     self.assetsInRow = CGFloat(newNumberPerRow)
     
     let firstVisibleIndex = self.imageCollectionView.visibleCells.first?.tag
     self.loadCollectionData()
     if let validFirstIndex = firstVisibleIndex {
       self.imageCollectionView.scrollToItem(at: IndexPath(row: validFirstIndex, section: 0), at: .top, animated: true)
     }
   }
}
