//
//  DeepFilter.swift
//  MuraCommunity
//
//  Created by Anonymos on 31/10/24.
//
import CoreImage
import Vision
import UIKit

enum Filter {
    case none
    case blur
    case replaceBackground(image: UIImage)
}

class DeepFilter {
    private var request: VNCoreMLRequest?
    private var visionModel: VNCoreMLModel?
    private var originalBuffer: CVPixelBuffer?
    private var filter: Filter = .blur
    private var targetSize: CGSize = .zero
    
    private var onResult: ((UIImage?) -> ())?
    
    let segmentationModel: DeepLabV3 = {
        do {
            let config = MLModelConfiguration()
            return try DeepLabV3(configuration: config)
        } catch(let error) {
            abort()
        }
    }()
    
    init() {
        self.setup()
    }
    
    private func setup() {
        do {
            let visionModel = try VNCoreMLModel(for: self.segmentationModel.model)
            self.visionModel = visionModel
            self.request = VNCoreMLRequest(model: visionModel, completionHandler: self.visionRequestDidComplete)
            self.request?.imageCropAndScaleOption = .scaleFill
        } catch {
            print("error \(error)")
        }
    }
    
    func predict(with buffer: CVPixelBuffer?,
                 filter: Filter,
                 frameSize: CGSize,
                 onResult: @escaping (UIImage?) -> ()) {
        guard let request, let buffer  else {
            return
        }
        switch filter {
        case .none:
            onResult(buffer.toImage())
            return
        default:
            break
        }
        self.targetSize = frameSize
        self.onResult = onResult
        self.originalBuffer = buffer
        self.filter = filter
        let handler = VNImageRequestHandler(cvPixelBuffer: buffer)
        try? handler.perform([request])
    }
    
    fileprivate func applyBackgroundMask(_ maskImage: UIImage) {
        guard let mainImage = originalBuffer?.toCIImage() else {
            return
        }
        let originalSize = mainImage.extent.size
        
        // scale to maskImage equal origin image
        let maskImage = maskImage.resized(to: originalSize).toCIImage()
        
        let bgImage: CIImage?
        switch filter {
        case .blur:
            bgImage = mainImage.applyingGaussianBlur(sigma: 3)
        case .replaceBackground(let image):
            let cropSize = CGSize(width: targetSize.height, height: targetSize.width)
            let croppedImage = image
                .cropScale(targetSize: cropSize)
                //.crop(ratio: targetSize.width / targetSize.height)
                .rotated(by: 270)
//                .resized(to: originalSize)
            bgImage = CIImage(cgImage: croppedImage.cgImage!)
            

            print("==== image size \(croppedImage.size)")
            
//            onResult?(bgImage)
//            return
        case .none:
            bgImage = nil
        }
        
        let filter = CIFilter(name: "CIBlendWithMask")
        filter?.setValue(bgImage, forKey: kCIInputBackgroundImageKey)
        filter?.setValue(mainImage, forKey: kCIInputImageKey)
        filter?.setValue(maskImage, forKey: kCIInputMaskImageKey)
        
        if let ciImage = filter?.outputImage {
            let image = UIImage(ciImage: ciImage, scale: 1, orientation: .right)
            self.onResult?(image)
        }
    }
    
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
        if let observations = request.results as? [VNCoreMLFeatureValueObservation],
           let multiArrayValue = observations.first?.featureValue.multiArrayValue {
            guard let maskUIImage = multiArrayValue.image(min: 0.0, max: 1.0) else { return }
            self.applyBackgroundMask(maskUIImage)
        }
    }
}

private extension CVPixelBuffer {
    func toImage() -> UIImage {
        let ciImage = CIImage(cvPixelBuffer: self)
        return UIImage(ciImage: ciImage, scale: 1, orientation: .right)
    }
    
    func toCIImage() -> CIImage {
        return CIImage(cvPixelBuffer: self)
    }
}

extension UIImage {
    func toCIImage() -> CIImage? {
        if let cgImage = self.cgImage {
            return CIImage(cgImage: cgImage)
        }
        return nil
    }
}

extension UIImage {
    func cropScale(targetSize: CGSize) -> UIImage {
        let cropRect = self.croppedRect(ratio: targetSize.width / targetSize.height)
        return self.scale(fromRect: cropRect, targetSize: targetSize)
    }
    
    func crop(ratio: CGFloat) -> UIImage {
        let cropRect = self.croppedRect(ratio: ratio)
        guard let ciImage = self.toCIImage() else {
            return self
        }
        return UIImage(ciImage: ciImage.cropped(to: cropRect))
    }
    
    func croppedRect(ratio: CGFloat) -> CGRect {
        let cropRect: CGRect
        
        // ratio = W / H
        let targetRatio = ratio
        let mRatio = self.size.width / self.size.height
        
        if targetRatio == mRatio {
            return CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        }
        
        if mRatio > targetRatio {
            // Cut Width
            let nH = self.size.height
            let nW = nH * targetRatio
            
            // get rect
            let offset = (self.size.width - nW) / 2
            cropRect = CGRect(x: offset, y: 0, width: nW, height: nH)
        } else {
            // Cut Height
            let nW = self.size.width
            let nH = nW / targetRatio
            
            // get rect
            let offset = (self.size.height - nH) / 2
            cropRect = CGRect(x: 0, y: offset, width: nW, height: nH)
        }
        
        return cropRect
    }
    
    func scale(fromRect: CGRect = .zero, targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { context in
            // UIImage and CGContext coordinates are flipped.
            var transform = CGAffineTransform(translationX: 0.0, y: targetSize.height)
            transform = transform.scaledBy(x: 1, y: -1)
            context.cgContext.concatenate(transform)
            // UIImage -> cropped CGImage
            let makeCroppedCGImage: (UIImage) -> CGImage? = { image in
                guard let cgImage = image.cgImage else { return nil }
                guard !fromRect.isEmpty else { return cgImage }
                return cgImage.cropping(to: fromRect)
            }
            if let cgImage = makeCroppedCGImage(self) {
                context.cgContext.draw(cgImage, in: CGRect(origin: .zero, size: targetSize))
            }
            else if let ciImage = self.ciImage {
                var transform = CGAffineTransform(translationX: 0.0, y: self.size.height)
                transform = transform.scaledBy(x: 1, y: -1)
                let adjustedFromRect = fromRect.applying(transform)
                let ciContext = CIContext(cgContext: context.cgContext, options: nil)
                ciContext.draw(ciImage, in: CGRect(origin: .zero, size: targetSize), from: adjustedFromRect)
            }
        }
    }
}
