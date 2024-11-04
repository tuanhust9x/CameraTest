//
//  ViewController.swift
//  Demo
//
//  Created by Anonymos on 30/10/24.
//

import UIKit
import OSLog
import Vision
import CoreImage
import AVFoundation

//enum Filter {
//    case non
//    case blur
//    case replaceBackground(image: UIImage)
//}

class ViewController: UIViewController {

    @IBOutlet var filtermageView: UIImageView!
    
//    private var segmentationRequest: VNGeneratePersonSegmentationRequest?
//        
//    var originalBuffer: CVPixelBuffer?
//    var cropRect: CGRect?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    
//        segmentationRequest = VNGeneratePersonSegmentationRequest()
//        segmentationRequest?.qualityLevel = .balanced
//        segmentationRequest?.outputPixelFormat = kCVPixelFormatType_OneComponent8
//        
//        
//        let camera = CameraController()
//        self.addChild(camera)
//        self.view.addSubview(camera.view)
//        
//        camera.onReceiveBuffer = { buffer in
//            self.originalBuffer = buffer
//            self.startFilter()
//        }
//        
//    }
//    
//    fileprivate func applyBackgroundMask(_ maskImage: CIImage, filter: Filter = .blur) {
//        guard let mainImage = originalBuffer?.toCIImage() else {
//            return
//        }
//        let originalSize = mainImage.extent.size
//        
//        let scaleX = originalSize.width / maskImage.extent.width
//        let scaleY = originalSize.height / maskImage.extent.height
//        let maskCI = maskImage.transformed(by: .init(scaleX: scaleX, y: scaleY))
//        
//        DispatchQueue.main.async {
//            
//            let bgImage: CIImage
//            switch filter {
//            case .blur:
//                bgImage = mainImage.applyingFilter("CIGaussianBlur")
//            case .replaceBackground(let image):
//                bgImage = CIImage(cgImage: image.resized(to: originalSize).cgImage!)
//            }
//            
//            if let filter = CIFilter(name: "CIBlendWithMask") {
//                filter.setValue(bgImage, forKey: kCIInputBackgroundImageKey)
//                filter.setValue(mainImage, forKey: kCIInputImageKey)
//                filter.setValue(maskCI, forKey: kCIInputMaskImageKey)
//                
//                if let ciImage = filter.outputImage {
//                    let img = UIImage(ciImage: ciImage, scale: 1, orientation: .right)
//                    self.filtermageView.image = img
//                }
//            }
//        }
//    }
//    
//    func startFilter() {
//        guard let buffer = originalBuffer, let segmentationRequest = self.segmentationRequest else { return }
//
//        let handler = VNImageRequestHandler(ciImage: buffer.toCIImage())
//        
//        try? handler.perform([segmentationRequest])
//        
//        guard let maskPixelBuffer =
//                segmentationRequest.results?.first?.pixelBuffer else { return }
//        
//        applyBackgroundMask(maskPixelBuffer.toCIImage())
//    }
}

//class CameraSource: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
//    let targetFps = Int32(10)
//    let videoOutput = AVCaptureVideoDataOutput()
//    var captureSession = AVCaptureSession()
//    var counter = 0
//    
//    var onReceiveBuffer: ((CVPixelBuffer?) -> ())?
//    var onReceiveImage: ((UIImage?) -> ())?
//    
//    //    Get front camera device
//    func getDevice() -> AVCaptureDevice {
//        return AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: .video, position: .front)!
//    }
//    
//    func setup() {
//        let device = getDevice()
//        //        Set camera input stream
//        let cameraInput = try! AVCaptureDeviceInput(device: device)
//
//        self.captureSession.addInput(cameraInput)
//        
//        //        Set camera output stream. stream is processed by captureOutput function defined below
//        self.videoOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
//        let videoQueue = DispatchQueue(label: "videoQueue", qos: .userInteractive)
//        self.videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
//        
//        self.captureSession.addOutput(self.videoOutput)
//
//        self.captureSession.automaticallyConfiguresCaptureDeviceForWideColor = true
//        
//
//        //        1280x720 is the dimentionality of the model's input that we'll use
//        //        the model doesn't contain any built-in preprocessing related to scaling
//        //        so let's transform a video stream to a desired size beforehand
//        self.captureSession.sessionPreset = AVCaptureSession.Preset.vga640x480
//        DispatchQueue.global().async {
//            self.captureSession.startRunning()
//        }
//    }
//    
//    //    Process output video stream
//    func captureOutput(_ output: AVCaptureOutput,
//                       didOutput sampleBuffer: CMSampleBuffer,
//                       from connection: AVCaptureConnection) {
//        if let pixelBuffer = getPixelBufferFromSampleBuffer(buffer: sampleBuffer) {
//            if (counter % 2 == 0) {
//                onReceiveBuffer?(pixelBuffer)
//            }
//            counter += 1
//        }
//    }
//    
//    func getPixelBufferFromSampleBuffer(buffer:CMSampleBuffer) -> CVPixelBuffer? {
//        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
//            return pixelBuffer
//        }
//        return nil
//    }
//}
//
//extension CVPixelBuffer {
//    func toImage() -> UIImage {
//        let ciImage = CIImage(cvPixelBuffer: self)
//        return UIImage(ciImage: ciImage)
//    }
//    
//    func toCIImage() -> CIImage {
//        return CIImage(cvPixelBuffer: self)
//    }
//}
//
//extension UIImage {
//    func toCIImage() -> CIImage? {
//        if let cgImage = self.cgImage {
//            return CIImage(cgImage: cgImage)
//        }
//        return nil
//    }
//}
