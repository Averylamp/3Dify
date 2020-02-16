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
  func sendImage(image: [PointCloudVertex],
                 completion: @escaping (([String: AnyObject]) -> Void))
}

class NetworkingDifyAPI {
  static let shared = NetworkingDifyAPI()
}

extension NetworkingDifyAPI {

  func sendImage(image: [PointCloudVertex], completion: @escaping (([String: AnyObject]) -> Void)) {
    print("Initiating request")
    let params = ["todo": 1] as [String: Int]

    var request = URLRequest(url: URL(string: "http://127.0.0.1:5000/upload/photo")!)
    request.httpMethod = "POST"
    request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let session = URLSession.shared
    let task = session.dataTask(with: request, completionHandler: { data, response, _ -> Void in
        print(response!)
        do {
          guard let json = try JSONSerialization.jsonObject(with: data!) as? [String: AnyObject] else {
            fatalError("JSON Serialization failed")
          }
            completion(json)
        } catch {
            print("error")
        }
    })
    task.resume()
    print("Completed request")
  }
}
