//
//  DeepFilterViewController.swift
//  Demo
//
//  Created by Anonymos on 30/10/24.
//

import UIKit
import CoreImage
import Vision

class DeepFilterViewController: UIViewController {
    
    @IBOutlet var filterImageView: UIImageView!
    @IBOutlet weak var button: UIButton!
    
    
    
    private let cameraSource = CameraSource()
    private let deepFilter = DeepFilter()
    private var filter: Filter = .none
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraSource.start { [weak self] buffer in
            self?.handleBuffer(buffer)
        }
        
    }
    
    @IBAction func blurAction(sender: UIButton) {
        
    }
    
    @IBAction func noneAction(sender: UIButton) {
        
    }
    
    @IBAction func bgAction(sender: UIButton) {
        
    }
    
    private func handleBuffer(_ buffer: CVPixelBuffer?) {
        //let size = frameSize.value
        let size = CGSize(width: 720, height: 1280)
        self.deepFilter.predict(with: buffer,
                                filter: filter,
                                frameSize: size) { image in
            DispatchQueue.main.async {
                self.filterImageView.image = image
            }
        }
    }
}
