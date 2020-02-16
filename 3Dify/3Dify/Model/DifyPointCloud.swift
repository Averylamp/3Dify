//
//  DifyPointCloud.swift
//  3Dify
//
//  Created by Avery Lamp on 2/15/20.
//  Copyright © 2020 Avery Lamp. All rights reserved.
//

import Foundation
import SceneKit

// swiftlint:ignore identifier_name
struct PointCloudVertex {
  var x: Float, y: Float, z: Float
  var r: Float, g: Float, b: Float, a: Float
}

@objc class PointCloud: NSObject {
  
  var pointCloud: [SCNVector3] = []
  var colors: [UInt8] = []
  var width: Int = 0
  var height: Int = 0
  var smoothing: Int = 0
  let apiInstance = NetworkingDifyAPI()
  
  public func pointCloudNode() -> SCNNode {
    let points = self.pointCloud
    var vertices = Array(repeating: PointCloudVertex(x: 0, y: 0, z: 0, r: 0, g: 0, b: 0, a: 0), count: points.count)
    
    for i in 0...(points.count-1) {
      let p = points[i]
      vertices[i].x = Float(p.x)
      vertices[i].y = Float(p.y)
      vertices[i].z = Float(p.z)
      vertices[i].r = Float(colors[i * 4]) / 255.0
      vertices[i].g = Float(colors[i * 4 + 1]) / 255.0
      vertices[i].b = Float(colors[i * 4 + 2]) / 255.0
      vertices[i].a = Float(colors[i * 4 + 3]) / 255.0
      if vertices[i].z == 0 {
        vertices[i].a = 0
      }
    }
    
    func vertexDistance(v1: SCNVector3, v2: SCNVector3) -> Float {
      return (v2.x - v1.x)  * (v2.x - v1.x) + (v2.y - v1.y) * (v2.y - v1.y) + (v2.z - v1.z) * (v2.z - v1.z)
    }
    
    for i in 1..<(points.count-1) {
      let pa = points[i - 1]
      let pb = points[i ]
      let pc = points[i + 1]
      let pab = vertexDistance(v1: pa, v2: pb)
      let pbc = vertexDistance(v1: pb, v2: pc)
      let threshold: Float = 0.00100
      if pab > threshold || pbc > threshold {
        vertices[i - 1].a = 0
        vertices[i ].a = 0
        vertices[i + 1].a = 0
      }
    }
    
    return self.buildNode2(points: vertices)
  }
  
  private func buildNode(points: [PointCloudVertex]) -> SCNNode {
    let vertexData = NSData(
      bytes: points,
      length: MemoryLayout<PointCloudVertex>.size * points.count
    )
    let positionSource = SCNGeometrySource(
      data: vertexData as Data,
      semantic: SCNGeometrySource.Semantic.vertex,
      vectorCount: points.count,
      usesFloatComponents: true,
      componentsPerVector: 3,
      bytesPerComponent: MemoryLayout<Float>.size,
      dataOffset: 0,
      dataStride: MemoryLayout<PointCloudVertex>.size
    )
    let colorSource = SCNGeometrySource(
      data: vertexData as Data,
      semantic: SCNGeometrySource.Semantic.color,
      vectorCount: points.count,
      usesFloatComponents: true,
      componentsPerVector: 4,
      bytesPerComponent: MemoryLayout<Float>.size,
      dataOffset: MemoryLayout<Float>.size * 3,
      dataStride: MemoryLayout<PointCloudVertex>.size
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
  
  private func buildNode2(points: [PointCloudVertex]) -> SCNNode {
    let vertexData = NSData(
      bytes: points,
      length: MemoryLayout<PointCloudVertex>.size * points.count
    )
    let positionSource = SCNGeometrySource(
      data: vertexData as Data,
      semantic: SCNGeometrySource.Semantic.vertex,
      vectorCount: points.count,
      usesFloatComponents: true,
      componentsPerVector: 3,
      bytesPerComponent: MemoryLayout<Float>.size,
      dataOffset: 0,
      dataStride: MemoryLayout<PointCloudVertex>.size
    )
    let colorSource = SCNGeometrySource(
      data: vertexData as Data,
      semantic: SCNGeometrySource.Semantic.color,
      vectorCount: points.count,
      usesFloatComponents: true,
      componentsPerVector: 4,
      bytesPerComponent: MemoryLayout<Float>.size,
      dataOffset: MemoryLayout<Float>.size * 3,
      dataStride: MemoryLayout<PointCloudVertex>.size
    )
    
    var fullNode = SCNNode()
    var topRow = 0
    var currentRow = 0
    var columnIndex = 0
    while true {
      var indices: [Int32] = []
      
      while true {
        //        let pointIndex = currentRow * width + columnIndex
        //        if !(points[pointIndex].r == 0 && points[pointIndex].b == 0 && points[pointIndex].g == 0) {
        //          indices.append(Int32(currentRow * width + columnIndex))
        //        }
        
        indices.append(Int32(currentRow * width + columnIndex))
        
        if topRow % 2 == 0 {
          // Going right
          if currentRow == topRow {
            // Go down
            currentRow += 1
            if columnIndex == width - 1 {
              topRow += 1
            }
          } else {
            // Move up right
            currentRow -= 1
            columnIndex += 1
          }
        } else {
          // Going Left
          if currentRow == topRow {
            currentRow += 1
            if columnIndex == 0 {
              topRow += 1
              if indices.count > 100000 {
                break
              }
            }
          } else {
            // Move up left
            currentRow -= 1
            columnIndex -= 1
          }
          if topRow == height - 1 {
            break
          }
        }
      }
      print("indicies:\(indices.count)")
      
      let pointer = UnsafeRawPointer(indices)
      let indexData = NSData(bytes: pointer, length: MemoryLayout<Int32>.size * indices.count)
      
      let element = SCNGeometryElement(data: indexData as Data, primitiveType: .triangleStrip, primitiveCount: indices.count - 2, bytesPerIndex: MemoryLayout<Int32>.size)
      
      let pointsGeometry = SCNGeometry(sources: [positionSource, colorSource], elements: [element])
      
      fullNode.addChildNode(SCNNode(geometry: pointsGeometry))
      if topRow == height - 1 {
        break
      }
    }
    return fullNode
  }
  
}
