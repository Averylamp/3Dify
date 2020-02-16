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
    self.loadAsset(self.phAsset)
  }
  
  /// Setup should only be called once
  func setup() {
    setupScene()
    
    PHPhotoLibrary.requestAuthorization({ status in
      switch status {
      case .authorized:
        self.phAsset.getURL { (url) in
          if let url = url {
            self.loadImage(at: url)
          }
        }
        
      default:
        fatalError()
      }
    })
    
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
    pointNode = SCNNode(geometry: sphere)
    
    sceneView.scene = scene
    sceneView.allowsCameraControl = true
    sceneView.showsStatistics = true
    sceneView.backgroundColor = UIColor.black
  }
  
  private func loadImage(at url: URL) {
    let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil)!
    depthData = imageSource.getDisparityData()
    guard let image = UIImage(contentsOfFile: url.path) else { fatalError() }
    self.image = image
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
    guard let colorImage = image, let cgColorImage = colorImage.cgImage else { fatalError() }
    guard let depthData = depthData else { fatalError() }
    
    let depthPixelBuffer = depthData.depthDataMap
    let width  = CVPixelBufferGetWidth(depthPixelBuffer)
    let height = CVPixelBufferGetHeight(depthPixelBuffer)
    
    let resizeScale = CGFloat(width) / colorImage.size.width
    let resizedColorImage = CIImage(cgImage: cgColorImage).transformed(by: CGAffineTransform(scaleX: resizeScale, y: resizeScale))
    guard var pixelDataColor = resizedColorImage.createCGImage().pixelData() else { fatalError() }
    
    // Applying Histogram Equalization
//            let depthImage = CIImage(cvPixelBuffer: depthPixelBuffer).applyingFilter("YUCIHistogramEqualization")
//            let context = CIContext(options: nil)
//            context.render(depthImage, to: depthPixelBuffer, bounds: depthImage.extent, colorSpace: nil)
    
    let pixelDataDepth: [Float32]
    pixelDataDepth = depthPixelBuffer.grayPixelData()
    
    // Sometimes the z values of the depth are bigger than the camera's z
    // So, determine a z scale factor to make it visible
    let zMax = pixelDataDepth.max()!
    
    let zNear = zCamera - 0.2
    var zScale = zMax > zNear ? zNear / zMax : 1.0
    zScale = 0.022
    
    print("z scale: \(zScale)")
    let xyScale: Float = 0.0002
    
    let pointCloud: [SCNVector3] = pixelDataDepth.enumerated().map {
      let index = $0.offset
      // Adjusting scale and translating to the center
      let x = Float(index % width - width / 2) * xyScale
      let y = Float(height / 2 - index / width) * xyScale
      // z comes as Float32 value
      let z = Float($0.element) * zScale
      return SCNVector3(x, y, z)
    }
    
    func zToKey(z: Float32) -> Int {
      return Int(z * 100)
    }
    var zCount: [Int: Int] = [:]
    pointCloud.forEach({
      let key = zToKey(z: $0.z)
      if zCount[key] != nil {
        zCount[key] = zCount[key]! + 1
      } else {
        zCount[key] = 1
      }
    })
    var maxCount = 0
    var maxKey = 0
    zCount.forEach { (item) in
      if item.value > maxCount {
        maxCount = item.value
        maxKey = item.key
      }
    }
    pointCloud.enumerated().map {
      let index = $0.offset
      if zToKey(z: $0.element.z) == maxKey {
        pixelDataColor[index * 4] = 0
        pixelDataColor[index * 4 + 1] = 0
        pixelDataColor[index * 4 + 2] = 0
      }
    }
    
    // Draw as a custom geometry
    let pc = PointCloud()
    pc.pointCloud = pointCloud
    pc.colors = pixelDataColor
    pc.width = width
    pc.height = height
    let pcNode = pc.pointCloudNode()
//    let pcNode = pc.pointCloudNodeTriangulated()
    pcNode.position = SCNVector3(x: 0, y: 0, z: 0)
    scene.rootNode.addChildNode(pcNode)
    //        pcNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
    
    // Draw with Sphere nodes
    //        pointCloud.enumerated().forEach {
    //            let index = $0.offset * 4
    //            let r = pixelDataColor[index]
    //            let g = pixelDataColor[index + 1]
    //            let b = pixelDataColor[index + 2]
    //
    //            let pos = $0.element
    //            // reducing the points
    //            guard Int(pos.x / scale) % 10 == 0 else { return }
    //            guard Int(pos.y / scale) % 10 == 0 else { return }
    //            let clone = pointNode.clone()
    //            clone.position = SCNVector3(pos.x, pos.y, pos.z)
    //
    //            // Creating a new geometry and a new material to color for each
    //            // https://stackoverflow.com/questions/39902802/stop-sharing-nodes-geometry-with-its-clone-programmatically
    //            guard let newGeometry = pointNode.geometry?.copy() as? SCNGeometry else { fatalError() }
    //            guard let newMaterial = newGeometry.firstMaterial?.copy() as? SCNMaterial else { fatalError() }
    //            newMaterial.diffuse.contents = UIColor(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: 1)
    //            newGeometry.materials = [newMaterial]
    //            clone.geometry = newGeometry
    //
    //            scene.rootNode.addChildNode(clone)
    //        }
  }
  
  private func update() {
    scene.rootNode.childNodes.forEach { childNode in
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
