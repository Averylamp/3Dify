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
import Vision

class DifyCloudVisualizerViewController: UIViewController {
  
  var phAsset: PHAsset!
  
  private var depthData: AVDepthData?
  private var image: UIImage?
  
  let zCamera: Float = 0.3
  var zScale: Float = 0.022
  var zThreshold: Float = 0.5
  var distance: Float = 2
  private let scene = SCNScene()
  private var anchorNode = SCNNode()
  
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
    self.loadAsset(self.phAsset)
  }
  
  /// Setup should only be called once
  func setup() {
    setupScene()
  }
  
  private func setupScene() {
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
    anchorNode = SCNNode(geometry: sphere)
    scene.rootNode.addChildNode(anchorNode)
    
    sceneView.scene = scene
    sceneView.allowsCameraControl = true
    sceneView.showsStatistics = true
    sceneView.backgroundColor = UIColor(red: 0.10, green: 0.07, blue: 0.27, alpha: 1.00)
  }
  
  private func loadAsset(_ asset: PHAsset) {
    asset.requestColorImage { image in
      self.image = image    
      asset.requestContentEditingInput(with: nil) { contentEditingInput, _ in
        let imageSource = contentEditingInput!.createImageSource()
        self.depthData = imageSource.getDisparityData()
        self.update()
      }
    }
  }
  
  /// Stylize should only be called once
  func stylize() {
    
  }
  
}

extension DifyCloudVisualizerViewController {
  private func drawPointCloud() {
    print("Drawing point cloud")
    print("Parameters\nzThresh: \(self.zThreshold)\nDistance: \(distance)\nzScale: \(zScale)")
    guard let colorImage = image, let cgColorImage = colorImage.cgImage else { fatalError() }
    guard let depthData = depthData else { fatalError() }
    
    let depthPixelBuffer = depthData.depthDataMap
    let width  = CVPixelBufferGetWidth(depthPixelBuffer)
    let height = CVPixelBufferGetHeight(depthPixelBuffer)
    
    let resizeScale = CGFloat(width) / colorImage.size.width
    let resizedColorImage = CIImage(cgImage: cgColorImage).transformed(by: CGAffineTransform(scaleX: resizeScale, y: resizeScale))
    guard let pixelDataColor = resizedColorImage.createCGImage().pixelData() else { fatalError() }
        
    let pixelDataDepth: [Float32]
    pixelDataDepth = depthPixelBuffer.grayPixelData()
    
    // Sometimes the z values of the depth are bigger than the camera's z
    // So, determine a z scale factor to make it visible
    guard let zMax = pixelDataDepth.max(),
      let zMin = pixelDataDepth.min() else {
        fatalError("Failed to get max and min")
    }
        
    print("z scale: \(zScale)")
    let xyScale: Float = 0.0002
    
    let pointCloud: [SCNVector3] = pixelDataDepth.enumerated().map {
      let index = $0.offset
      // Adjusting scale and translating to the center
      let x = Float(index % width - width / 2) * xyScale
      let y = Float(height / 2 - index / width) * xyScale
      // z comes as Float32 value
      if $0.element - zMin < (zMax - zMin) * zThreshold {
        return SCNVector3(x, y, 0)
      }
      let centerDistance = sqrt(x * x + y * y)
      let theta = asin(centerDistance / $0.element)
      let realZ = cos(theta) * $0.element
      let z = realZ * zScale
      return SCNVector3(x, y, z)
    }
    
    // Draw as a custom geometry
    let pc = PointCloud()
    pc.pointCloud = pointCloud
    pc.colors = pixelDataColor
    pc.width = width
    pc.height = height
    
    let pcNode = pc.pointCloudNode()
    pcNode.position = SCNVector3(x: 0, y: 0, z: 0)
    self.anchorNode.addChildNode(pcNode)
  }
  
  public func update() {
    self.anchorNode.childNodes.forEach { childNode in
      childNode.removeFromParentNode()
    }
    
    drawPointCloud()
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
