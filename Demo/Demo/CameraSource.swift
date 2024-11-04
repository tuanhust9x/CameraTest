//
//  CameraSource.swift
//  MuraCommunity
//
//  Created by Anonymos on 31/10/24.
//
import AVFoundation

class CameraSource: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    let videoOutput = AVCaptureVideoDataOutput()
    var captureSession = AVCaptureSession()
    var counter = 0
    
    private var onReceiveBuffer: ((CVPixelBuffer?) -> ())?
    
    override init() {
        super.init()
        self.setup()
    }
    
    private func setup() {
        do {
            // Set camera input stream
            let device = try  getDevice()
            
            let cameraInput = try AVCaptureDeviceInput(device: device)
            self.captureSession.addInput(cameraInput)
            
            //        Set camera output stream. stream is processed by captureOutput function defined below
            self.videoOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
            
            let videoQueue = DispatchQueue(label: "my.image.handling.queue", qos: .userInteractive)
            self.videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
            self.captureSession.addOutput(self.videoOutput)
            
            //        1280x720 is the dimensionality of the model's input that we'll use
            //        the model doesn't contain any built-in preprocessing related to scaling
            //        so let's transform a video stream to a desired size beforehand
            self.captureSession.sessionPreset = AVCaptureSession.Preset.hd1280x720
        } catch {
            
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        if let pixelBuffer = getPixelBufferFromSampleBuffer(buffer: sampleBuffer) {
            if (counter % 2 == 0) {
                onReceiveBuffer?(pixelBuffer)
            }
            counter += 1
        }
    }
    
    func getPixelBufferFromSampleBuffer(buffer:CMSampleBuffer) -> CVPixelBuffer? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
            return pixelBuffer
        }
        return nil
    }
    
    func getDevice() throws -> AVCaptureDevice {
        let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                             for: .video,
                                             position: .front)
        if device == nil {
            throw NSError(domain: "", code: 0, userInfo: [:])
        }
        return device!
    }
    
    func start(onReceiveBuffer: ((CVPixelBuffer?) -> ())?) {
        self.onReceiveBuffer = onReceiveBuffer
        DispatchQueue.global().async {
            self.captureSession.startRunning()
        }
    }
}
