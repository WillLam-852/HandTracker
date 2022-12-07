//
//  ViewController.swift
//
//  Created by Tomoya Hirano on 2020/01/09.
//  Copyright © 2020 Tomoya Hirano. All rights reserved.
//
import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, TrackerDelegate {
    
    let action = FingerExerciseCheck()
    let cameraFeedManager = CameraFeedManager()
//    let displayLayer: AVSampleBufferDisplayLayer = .init()
    let tracker: HandTracker = HandTracker()!
    var d = Date()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var calibrationLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
//        view.layer.addSublayer(displayLayer)
        
        // Set the sample buffer delegate and the queue for invoking callbacks
        // When a new video sample buffer is captured, it is sent to the sample buffer delegate using captureOutput(_:didOutput:from:)
        cameraFeedManager.setSampleBufferDelegate(self)
        
        //
        cameraFeedManager.startRunning()
        tracker.startGraph()
        tracker.delegate = self
        
        action.checkUpdateDelegate = self
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        displayLayer.frame = view.bounds
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        displayLayer.enqueue(sampleBuffer)
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        tracker.send(pixelBuffer, timestamp: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
//        DispatchQueue.main.async {
//            self.imageView.image = UIImage(ciImage: CIImage(cvPixelBuffer: pixelBuffer!))
//        }
    }
    
    func handTracker(_ tracker: HandTracker!, didOutputPixelBuffer pixelBuffer: CVPixelBuffer!) {
        DispatchQueue.main.async {
            self.imageView.image = UIImage(ciImage: CIImage(cvPixelBuffer: pixelBuffer))
        }
    }
    
    func didReceived(_ landmarks: [Landmark]!) {
        action.check(landmarks)
    }
    
}

extension ViewController: AbstractCheckDelegate {
    
    func didUpdateCalibrationStateDelegate(_ state: String) {
        DispatchQueue.main.async { [self] in
            calibrationLabel.text = String(state)
        }
    }
    
    
    func didUpdateCountDelegate(_ count: Int) {
        DispatchQueue.main.async { [self] in
            countLabel.text = String(count)
        }
    }
    
    func didUpdateStateDelegate(_ state: String) {
        DispatchQueue.main.async { [self] in
            stateLabel.text = String(state)
        }
    }
}

//class ViewController2: UIViewController, ARSessionDelegate, TrackerDelegate {
//
//    @IBOutlet var sceneView: ARSCNView!
//    let tracker: Tracker = Tracker()!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        sceneView.showsStatistics = true
//        let scene = SCNScene()
//        sceneView.scene = scene
//        tracker.startGraph()
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        let configuration = ARFaceTrackingConfiguration()
//        sceneView.session.delegate = self
//        sceneView.session.run(configuration)
//
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        sceneView.session.pause()
//    }
//
//    func session(_ session: ARSession, didUpdate frame: ARFrame) {
//        let bgra = try! frame.capturedImage.toBGRA()
////        print(bgra)
//        tracker.processVideoFrame(bgra)
//    }
//
//    func didReceived(_ landmarks: [Landmark]!) {
//        print(landmarks)
//    }
//}


