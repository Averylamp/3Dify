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
  var r: Float, g: Float, b: Float
}

@objc class PointCloud: NSObject {
  
  var pointCloud: [SCNVector3] = []
  var colors: [UInt8] = []
  
  public func pointCloudNode() -> SCNNode {
    let points = self.pointCloud
    var vertices = Array(repeating: PointCloudVertex(x: 0, y: 0, z: 0, r: 0, g: 0, b: 0), count: points.count)
    
    for i in 0...(points.count-1) {
      let p = points[i]
      vertices[i].x = Float(p.x)
      vertices[i].y = Float(p.y)
      vertices[i].z = Float(p.z)
      vertices[i].r = Float(colors[i * 4]) / 255.0
      vertices[i].g = Float(colors[i * 4 + 1]) / 255.0
      vertices[i].b = Float(colors[i * 4 + 2]) / 255.0
      if i % 100000 == 0 {
        print(vertices[i])
      }
    }
    
    let node = buildNode(points: vertices)
    return node
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
      componentsPerVector: 3,
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
}

@objc class DifyPointCloud: NSObject {
  
  var pointCloud: [SCNVector3] = []
  var colors: [UInt8] = []
  var width: Int = 0
  var height: Int = 0
  
  public func pointCloudNode() -> SCNNode {
    let points = self.pointCloud
    var vertices = Array(repeating: DifyPoint(x: 0, y: 0, z: 0, r: 0, g: 0, b: 0), count: points.count)
    
    var pointString: String = ""
    for index in 0...(points.count-1) {
      let point = points[index]
      vertices[index].x = Float(point.x)
      vertices[index].y = Float(point.y)
      vertices[index].z = Float(point.z)
      vertices[index].r = Float(colors[index * 4]) / 255
      vertices[index].g = Float(colors[index * 4 + 1]) / 255
      vertices[index].b = Float(colors[index * 4 + 2]) / 255
      if index % 100000 == 0 {
        print(vertices[index])
      }
//      pointString += "(\(Float(point.x)),\(Float(point.y)),\(Float(point.z)),\(Float(colors[index * 4]) / 255.0),\(Float(colors[index * 4 + 1]) / 255.0),\(Float(colors[index * 4 + 2]) / 255.0))\n"
    }
//    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
//      let fileURL = dir.appendingPathComponent("Points1.txt")
//      print(fileURL)
//      do {
//        try pointString.write(to: fileURL, atomically: false, encoding: .utf8)
//      } catch {}
//
//    }
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
    let node = SCNNode(geometry: pointsGeometry)
    
    return node
  }
  
  public func pointCloudNodeTriangulated() -> SCNNode {
    
    let points = self.pointCloud
    var vertices = Array(repeating: Array(repeating: DifyPoint(x: 0, y: 0, z: 0, r: 0, g: 0, b: 0), count: self.width), count: self.height)
    for index in 0...(points.count-1) {
      let point = points[index]
      vertices[index / height][index % width].x = Float(point.x)
      vertices[index / height][index % width].y = Float(point.y)
      vertices[index / height][index % width].z = Float(point.z)
      vertices[index / height][index % width].r = Float(colors[index * 4]) * 255
      vertices[index / height][index % width].g = Float(colors[index * 4 + 1]) * 255
      vertices[index / height][index % width].b = Float(colors[index * 4 + 2]) * 255
    }
    
    let triA = vertices[0][0]
    let triB = vertices[0][width - 1]
    let triC = vertices[height - 1][0]
    let scnnode = makeTriangle(triA: vertices[0][0], triB: vertices[0][width - 1], triC: vertices[height - 1][0])
//    let scnnode = SCNNode()
//    scnnode.addChildNode(makeSphere(tri: triA, color: .red))
//    scnnode.addChildNode(makeSphere(tri: triB, color: .blue))
//    scnnode.addChildNode(makeSphere(tri: triC, color: .green))
    return scnnode
  }
  
  func makeSphere(tri: DifyPoint, color: UIColor = .red) -> SCNNode {
    let sphereNode = SCNSphere(radius: 0.01)
    sphereNode.materials.first?.diffuse.contents = color
    let node = SCNNode(geometry: sphereNode)
    
    node.position = SCNVector3(tri.x, tri.y, tri.z)
    return node
  }
  
  func makeTriangle(triA: DifyPoint, triB: DifyPoint, triC: DifyPoint) -> SCNNode {
    let vertices: [SCNVector3] = [
      SCNVector3(triC.x, triC.y, triC.z),
      SCNVector3(triB.x, triB.y, triB.z),
      SCNVector3(triA.x, triA.y, triA.z)
    ]
    let vertexSource = SCNGeometrySource(vertices: vertices)
    
    let normals: [SCNVector3] = [
      SCNVector3(0, 0, 1),
      SCNVector3(0, 0, 1),
      SCNVector3(0, 0, 1)
    ]
    let normalSource = SCNGeometrySource(normals: normals)
    let indices: [Int32] = [0, 1, 2]
    let pointer = UnsafeRawPointer(indices)
    let indexData = NSData(bytes: pointer, length: MemoryLayout<Int32>.size * indices.count)

    let element = SCNGeometryElement(data: indexData as Data, primitiveType: .triangles, primitiveCount: indices.count, bytesPerIndex: MemoryLayout<Int32>.size)

    let geometry = SCNGeometry(sources: [vertexSource, normalSource], elements: [element])
    let material = SCNMaterial()
    
    print("triA: \(triA)")
    material.diffuse.contents = UIColor(red: CGFloat(triA.r * 255), green: CGFloat(triA.g * 255), blue: CGFloat(triA.b * 255), alpha: 1.0)
//    material.diffuse.contents = UIColor.red
    geometry.materials = [material]
    let node = SCNNode()
    node.geometry = geometry
    return node
  }
}
