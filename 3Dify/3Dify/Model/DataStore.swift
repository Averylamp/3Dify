//
//  DataStore.swift
//  3Dify
//
//  Created by Avery Lamp on 2/16/20.
//  Copyright © 2020 Avery Lamp. All rights reserved.
//

import Foundation

enum UserDefaultKeys: String {
  case allModels
}

extension Notification.Name {
  static let modelsReloaded = Notification.Name("modelsReloaded")
}

class DataStore: NSObject {

  static let shared = DataStore()

  private override init() {
    super.init()
    self.loadAllModelsFromUserDefaults()
  }
  
  var allModels: [StoredModel] = []
  
  func loadAllModelsFromUserDefaults() {
    if let allModelData = UserDefaults.standard.data(forKey: UserDefaultKeys.allModels.rawValue) {
     let decoder = JSONDecoder()
      do {
        let storedModels = try decoder.decode([StoredModel].self, from: allModelData)
        self.allModels = storedModels
        NotificationCenter.default.post(name: .modelsReloaded, object: nil)
      } catch {
          print("Failed to decode JSON")
      }
    }
  }
  
  func saveAllModelsToUserDefaults() {
    let encoder = JSONEncoder()
    do {
      let data = try encoder.encode(self.allModels)
      UserDefaults.standard.set(data, forKey: UserDefaultKeys.allModels.rawValue)
    } catch {
      print("Failed to encode object")
    }
    NotificationCenter.default.post(name: .modelsReloaded, object: nil)
  }
  
}
