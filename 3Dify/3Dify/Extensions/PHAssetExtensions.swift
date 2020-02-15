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
      PHImageManager.default().requestImage(for: self, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.aspectFit, options: nil) { (image, _) in
          handler(image)
      }
  }
}
