//
//  PortraitPhotoPickerProtocol.swift
//  3Dify
//
//  Created by Avery Lamp on 2/15/20.
//  Copyright © 2020 Avery Lamp. All rights reserved.
//

import Foundation
import Photos

protocol PortraitPhotoPickerProtocol: AnyObject {
  func didPickPortraitPhoto(phAsset: PHAsset) 
}
