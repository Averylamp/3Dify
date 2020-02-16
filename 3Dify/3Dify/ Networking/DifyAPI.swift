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

    func sendImage(aggregate: [PointCloudVertex], image: [PointCloudVertex], completion: @escaping (([String: AnyObject]) -> Void)) {
        
    print("Initiating request")
        let res1: [[Float]] = image.map{[$0.r, $0.g, $0.b, $0.x, $0.y, $0.z]}
        let res2: [[Float]] = aggregate.map{[$0.r, $0.g, $0.b, $0.x, $0.y, $0.z]}
        
    let data_to_send = [0 : res1, 1: res2]

    var request = URLRequest(url: URL(string: "http://127.0.0.1:5000/upload/photo")!)
    request.httpMethod = "POST"
    request.httpBody = try? JSONSerialization.data(withJSONObject: data_to_send, options: [])
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let session = URLSession.shared
    let task = session.dataTask(with: request, completionHandler: { data, _, _ -> Void in
//        print(response!)
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
