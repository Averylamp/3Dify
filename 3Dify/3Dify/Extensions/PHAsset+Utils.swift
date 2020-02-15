//
//  PHAssetExtensions.swift
//  3Dify
//
//  Created by Avery Lamp on 2/15/20.
//  Copyright © 2020 Avery Lamp. All rights reserved.
//

import UIKit
import Photos

extension PHAsset {
  func requestColorImage(handler: @escaping (UIImage?) -> Void) {
    let requestOptions = PHImageRequestOptions()
    requestOptions.isSynchronous = true
    PHImageManager.default().requestImage(for: self, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.aspectFit, options: requestOptions) { (image, _) in
      handler(image)
    }
  }
  
  func getURL(completionHandler : @escaping ((_ responseURL: URL?) -> Void)) {
    let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
    options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
      return true
    }
    self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, _: [AnyHashable: Any]) -> Void in
      if let contentEditingInput = contentEditingInput, let fullSizeURL = contentEditingInput.fullSizeImageURL {
        completionHandler(fullSizeURL)
      } else {
        completionHandler(nil)
      }
    })
    
  }
  
}

extension PHContentEditingInput {
    func createDepthImage() -> CIImage {
        guard let url = fullSizeImageURL else { fatalError() }
        return CIImage(contentsOf: url, options: [CIImageOption.auxiliaryDisparity: true])!
    }
    
    func createImageSource() -> CGImageSource {
        guard let url = fullSizeImageURL else { fatalError() }
        return CGImageSourceCreateWithURL(url as CFURL, nil)!
    }
}
