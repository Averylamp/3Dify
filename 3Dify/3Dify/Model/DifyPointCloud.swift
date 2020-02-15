//
//  DifyPointCloud.swift
//  3Dify
//
//  Created by Avery Lamp on 2/15/20.
//  Copyright © 2020 Avery Lamp. All rights reserved.
//

import Foundation
import SceneKit

@objc class DifyPointCloud: NSObject {
  
  var pointCloud: [SCNVector3] = []
  var colors: [UInt8] = []
  
  public func pointCloudNode() -> SCNNode {
    let points = self.pointCloud
    var vertices = Array(repeating: DifyPoint(x: 0, y: 0, z: 0, r: 0, g: 0, b: 0), count: points.count)
    
    for index in 0...(points.count-1) {
      let point = points[index]
      vertices[index].x = Float(point.x)
      vertices[index].y = Float(point.y)
      vertices[index].z = Float(point.z)
      vertices[index].r = Float(colors[index * 4]) / 255.0
      vertices[index].g = Float(colors[index * 4 + 1]) / 255.0
      vertices[index].b = Float(colors[index * 4 + 2]) / 255.0
    }
    
    let node = buildNode(points: vertices)
    return node
  }
  
  private func buildNode(points: [DifyPoint]) -> SCNNode {
    let vertexData = NSData(
      bytes: points,
      length: MemoryLayout<DifyPoint>.size * points.count
    )
    let positionSource = SCNGeometrySource(
      data: vertexData as Data,
      semantic: SCNGeometrySource.Semantic.vertex,
      vectorCount: points.count,
      usesFloatComponents: true,
      componentsPerVector: 3,
      bytesPerComponent: MemoryLayout<Float>.size,
      dataOffset: 0,
      dataStride: MemoryLayout<DifyPoint>.size
    )
    let colorSource = SCNGeometrySource(
      data: vertexData as Data,
      semantic: SCNGeometrySource.Semantic.color,
      vectorCount: points.count,
      usesFloatComponents: true,
      componentsPerVector: 3,
      bytesPerComponent: MemoryLayout<Float>.size,
      dataOffset: MemoryLayout<Float>.size * 3,
      dataStride: MemoryLayout<DifyPoint>.size
    )
    let element = SCNGeometryElement(
      data: nil,
      primitiveType: .point,
      primitiveCount: points.count,
      bytesPerIndex: MemoryLayout<Int>.size
    )
    
    // for bigger dots
    element.pointSize = 1
    element.minimumPointScreenSpaceRadius = 1
    element.maximumPointScreenSpaceRadius = 5
    
    let pointsGeometry = SCNGeometry(sources: [positionSource, colorSource], elements: [element])
    
    return SCNNode(geometry: pointsGeometry)
  }
}
