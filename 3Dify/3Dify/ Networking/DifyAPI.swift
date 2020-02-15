//
//  3DifyAPI.swift
//  3Dify
//
//  Created by Avery Lamp on 2/15/20.
//  Copyright © 2020 Avery Lamp. All rights reserved.
//

import Foundation
import UIKit

enum DifyAPIError: Error {
  case unknownError(message: String?)
}

protocol DifyAPI {
  func sendImage(image: UIImage,
                 completion: @escaping(Result<[DifyPoint], DifyAPIError>) -> Void)
}

class NetworkingDifyAPI {
  static let shared = NetworkingDifyAPI()
  
  private init() {
  }

}

extension NetworkingDifyAPI: DifyAPI {

  func sendImage(image: UIImage, completion: @escaping (Result<[DifyPoint], DifyAPIError>) -> Void) {
    
  }
  
}
