//
//  StoredModels.swift
//  3Dify
//
//  Created by Avery Lamp on 2/16/20.
//  Copyright © 2020 Avery Lamp. All rights reserved.
//

import Foundation
import Photos

enum StoredModelError: Error {
  case unknown
}

enum StoredModelCodingKeys: String, CodingKey {
  case phAsset
  case zThreshold
  case zScale
  case distance
  case smoothing
}

class StoredModel: Codable {
  
  var phAsset: PHAsset
  var zThreshold: Float
  var zScale: Float
  var distance: Float
  var smoothing: Int
  
  init(phAsset: PHAsset) {
    self.phAsset = phAsset
    self.zThreshold = 0.4
    self.zScale = 0.022
    self.distance = 0.5
    self.smoothing = 0
  }
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: StoredModelCodingKeys.self)
    let phAssetString = try values.decode(String.self, forKey: .phAsset)
    
    guard let phAssetItem =  PHAsset.fetchAssets(withLocalIdentifiers: [phAssetString], options: nil).firstObject else {
      throw StoredModelError.unknown
    }
    self.phAsset = phAssetItem
    self.zThreshold = try values.decode(Float.self, forKey: .zThreshold)
    self.distance = try values.decode(Float.self, forKey: .distance)
    self.zScale = try values.decode(Float.self, forKey: .zScale)
    self.smoothing = try values.decode(Int.self, forKey: .smoothing)
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: StoredModelCodingKeys.self)
    try container.encode(self.phAsset.localIdentifier, forKey: .phAsset)
    try container.encode(zThreshold, forKey: .zThreshold)
    try container.encode(distance, forKey: .distance)
    try container.encode(zScale, forKey: .zScale)
    try container.encode(smoothing, forKey: .smoothing)
  }
  
}
