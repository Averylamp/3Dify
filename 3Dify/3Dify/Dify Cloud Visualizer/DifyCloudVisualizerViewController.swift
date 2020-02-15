//
//  DifyCloudVisualizerViewController.swift
//  3Dify
//
//  Created by Avery Lamp on 2/15/20.
//  Copyright © 2020 Avery Lamp. All rights reserved.
//

import UIKit
import Photos
import SceneKit

// swiftlint:ignore identifier_name

class DifyCloudVisualizerViewController: UIViewController {
  
  var phAsset: PHAsset!
  
  private var depthData: AVDepthData?
  private var image: UIImage?
  
  let zCamera: Float = 0.3
  private let scene = SCNScene()
  private var pointNode = SCNNode()
  
  @IBOutlet weak var sceneView: SCNView!
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(phAsset: PHAsset) -> DifyCloudVisualizerViewController? {
    let vcName = String(describing: DifyCloudVisualizerViewController.self)
    let storyboard = R.storyboard.difyCloudVisualizerViewController
    guard let difyVisualizerVC = storyboard.instantiateInitialViewController() else {
      fatalError("Unable to instantiate \(vcName)")
    }
    difyVisualizerVC.phAsset = phAsset
    return difyVisualizerVC
  }
  
}

// MARK: Life Cycle
extension  DifyCloudVisualizerViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
    self.stylize()
  }
  
  /// Setup should only be called once
  func setup() {
    self.setupScene()
    self.loadImageCloud()
  }
  
  private func  setupScene() {
    let cameraNode = SCNNode()
    cameraNode.camera = SCNCamera()
    cameraNode.camera?.zNear = 0.0
    cameraNode.camera?.zFar = 10.0
    scene.rootNode.addChildNode(cameraNode)
    
    cameraNode.position = SCNVector3(x: 0, y: 0, z: zCamera)
    
    let lightNode = SCNNode()
    lightNode.light = SCNLight()
    lightNode.light!.type = .omni
    lightNode.position = SCNVector3(x: 0, y: 3, z: 3)
    scene.rootNode.addChildNode(lightNode)
    
    let sphere = SCNSphere(radius: 0.001)
    sphere.firstMaterial?.diffuse.contents = UIColor.blue
    pointNode = SCNNode(geometry: sphere)
    
    self.sceneView.scene = scene
    self.sceneView.allowsCameraControl = true
    self.sceneView.showsStatistics = true
    self.sceneView.backgroundColor = UIColor.white
  }
  
  private func loadImageCloud() {
    self.loadImage()
  }
  
  /// Stylize should only be called once
  func stylize() {
    
  }
  
}

// MARK: Loading
extension DifyCloudVisualizerViewController {
  private func loadImage() {
    var count = 2
    self.phAsset.requestColorImage { image in
      self.image = image
      count -= 1
      print("Loaded color image")
      if count == 0 {
        DispatchQueue.main.async {
          self.drawPointCloud()
        }
      }
    }
    self.phAsset.requestContentEditingInput(with: nil) { contentEditingInput, _ in
      let imageSource = contentEditingInput!.createImageSource()
      print("Loaded Depth Data")
      self.depthData = imageSource.getDisparityData()
      count -= 1
      if count == 0 {
        DispatchQueue.main.async {
          self.drawPointCloud()
        }
      }
    }
  }
  
}

// MARK: Drawing
extension DifyCloudVisualizerViewController {
  func drawPointCloud() {
    guard let colorImage = image, let cgColorImage = colorImage.cgImage else { fatalError() }
    guard let depthData = depthData else { fatalError() }
    
    let depthPixelBuffer = depthData.depthDataMap
    let width  = CVPixelBufferGetWidth(depthPixelBuffer)
    let height = CVPixelBufferGetHeight(depthPixelBuffer)
    
    let resizeScale = CGFloat(width) / colorImage.size.width
    let resizedColorImage = CIImage(cgImage: cgColorImage).transformed(by: CGAffineTransform(scaleX: resizeScale, y: resizeScale))
    guard let pixelDataColor = resizedColorImage.createCGImage().pixelData() else { fatalError() }
    
    // Applying Histogram Equalization
    //        let depthImage = CIImage(cvPixelBuffer: depthPixelBuffer).applyingFilter("YUCIHistogramEqualization")
    //        let context = CIContext(options: nil)
    //        context.render(depthImage, to: depthPixelBuffer, bounds: depthImage.extent, colorSpace: nil)
    
    let pixelDataDepth: [Float32]
    pixelDataDepth = depthPixelBuffer.grayPixelData()
    
    // Sometimes the z values of the depth are bigger than the camera's z
    // So, determine a z scale factor to make it visible
    let zMax = pixelDataDepth.max()!
    let zNear = zCamera - 0.2
    let zScale = zMax > zNear ? zNear / zMax : 1.0
    print("z scale: \(zScale)")
    let xyScale: Float = 0.0002
    
    let pointCloud: [SCNVector3] = pixelDataDepth.enumerated().map {
      let index = $0.offset
      // Adjusting scale and translating to the center
      
      let xPoint = Float(index % width - width / 2) * xyScale
      let yPoint = Float(height / 2 - index / width) * xyScale
      // z comes as Float32 value
      let zPoint = Float($0.element) * zScale
      return SCNVector3(xPoint, yPoint, zPoint)
    }
    
    // Draw as a custom geometry
    let pCloud = DifyPointCloud()
    pCloud.pointCloud = pointCloud
    pCloud.colors = pixelDataColor
    let pcNode = pCloud.pointCloudNode()
    pcNode.position = SCNVector3(x: 0, y: 0, z: 0)
    
    scene.rootNode.addChildNode(pcNode)
    //    pcNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
    
    // Draw with Sphere nodes
    //    print("Nodes: \(pointCloud.count)")
    //    pointCloud.enumerated().forEach {
    //      let scale: Float = 0.001
    //      let index = $0.offset * 4
    //      let red = pixelDataColor[index]
    //      let green = pixelDataColor[index + 1]
    //      let blue = pixelDataColor[index + 2]
    //
    //      let pos = $0.element
    //      // reducing the points
    //      guard Int(pos.x / scale) % 10 == 0 else { return }
    //      guard Int(pos.y / scale) % 10 == 0 else { return }
    //      let clone = pointNode.clone()
    //      clone.position = SCNVector3(pos.x, pos.y, pos.z)
    //
    //      // Creating a new geometry and a new material to color for each
    //      // https://stackoverflow.com/questions/39902802/stop-sharing-nodes-geometry-with-its-clone-programmatically
    //      guard let newGeometry = pointNode.geometry?.copy() as? SCNGeometry else { fatalError() }
    //      guard let newMaterial = newGeometry.firstMaterial?.copy() as? SCNMaterial else { fatalError() }
    //      newMaterial.diffuse.contents = UIColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: 1)
    //      newGeometry.materials = [newMaterial]
    //      clone.geometry = newGeometry
    //
    //      scene.rootNode.addChildNode(clone)
    //    }
  }
}

extension CGImage {
  
  func pixelData() -> [UInt8]? {
    guard let colorSpace = colorSpace else { return nil }
    
    let totalBytes = height * bytesPerRow
    var pixelData = [UInt8](repeating: 0, count: totalBytes)
    
    guard let context = CGContext(
      data: &pixelData,
      width: width,
      height: height,
      bitsPerComponent: bitsPerComponent,
      bytesPerRow: bytesPerRow,
      space: colorSpace,
      bitmapInfo: bitmapInfo.rawValue)
      else { fatalError() }
    context.draw(self, in: CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height)))
    
    return pixelData
  }
}

extension CVPixelBuffer {
  
  func grayPixelData() -> [Float32] {
    CVPixelBufferLockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
    let width = CVPixelBufferGetWidth(self)
    let height = CVPixelBufferGetHeight(self)
    var pixelData = [Float32](repeating: 0, count: Int(width * height))
    for yMap in 0 ..< height {
      let rowData = CVPixelBufferGetBaseAddress(self)! + yMap * CVPixelBufferGetBytesPerRow(self)
      let data = UnsafeMutableBufferPointer<Float>(start: rowData.assumingMemoryBound(to: Float.self), count: width)
      for index in 0 ..< width {
        pixelData[index +  width * yMap] = Float32(data[index / 2])
      }
    }
    CVPixelBufferUnlockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
    return pixelData
  }
}
