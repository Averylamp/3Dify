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
    print("Initiating request")
    let params = ["todo":1] as Dictionary<String, Int>

    var request = URLRequest(url: URL(string: "http://127.0.0.1:5000/upload/photo")!)
    request.httpMethod = "POST"
    request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let session = URLSession.shared
    let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
        print(response!)
        do {
            let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
            print(json)
        } catch {
            print("error")
        }
    })
    task.resume()
    print("Completed request")
  }
  
}
