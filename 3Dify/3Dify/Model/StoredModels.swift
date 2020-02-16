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
}

class StoredModel: Codable {
  
  var phAsset: PHAsset
  var zThreshold: Float
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: StoredModelCodingKeys.self)
    let phAssetString = try values.decode(String.self, forKey: .phAsset)
    
    guard let phAssetItem =  PHAsset.fetchAssets(withLocalIdentifiers: [], options: nil).firstObject else {
      throw StoredModelError.unknown
    }
    self.phAsset = phAssetItem
    self.zThreshold = try values.decode(Float.self, forKey: .zThreshold)
    
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: StoredModelCodingKeys.self)
    try container.encode(self.phAsset.localIdentifier, forKey: .phAsset)
    try container.encode(zThreshold, forKey: .zThreshold)
  }
  
}
