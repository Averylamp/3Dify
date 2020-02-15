//
//  Result.swift
//  3Dify
//
//  Created by Avery Lamp on 2/15/20.
//  Copyright © 2020 Avery Lamp. All rights reserved.
//

enum Result<T, Error> {
  case success(T)
  case failure(Error)
}
