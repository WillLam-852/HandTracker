//
//  CameraFeedManager.swift
//  Example
//
//  Created by Tomoya Hirano on 2020/04/02.
//  Copyright © 2020 Tomoya Hirano. All rights reserved.
//

import AVFoundation

/// Manage the camera pipeline
final class CameraFeedManager: NSObject {
    
    lazy private var captureSession: AVCaptureSession = .init()
    lazy private var captureDeviceInput: AVCaptureDeviceInput? = nil
    lazy private var captureDeviceOutput: AVCaptureVideoDataOutput? = nil
    
    private var setupResult: SessionSetupResult = .success

    private let outputVideoSettings: [String : OSType] = [kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_32BGRA]

    // Communicate with the session and other session objects on this queue.
    private let captureSessionQueue = DispatchQueue(label: "capture session queue")

    
    override init() {
        super.init()
        self.requestUserAuthorization()
        do {
            try self.setCaptureDevice()
        } catch CameraFeedManagerError.CaptureDeviceNotFound {
            print("ERROR: Capture device is not found in CameraFeedManager")
        } catch CameraFeedManagerError.InputCannotBeAdded {
            print("ERROR: Input cannot be added in CameraFeedManager")
        } catch CameraFeedManagerError.OutputCannotBeAdded {
            print("ERROR: Output cannot be added in CameraFeedManager")
        } catch {
            print("ERROR: \(error.localizedDescription) in CameraFeedManager")
        }
    }
    
    
    public func setSampleBufferDelegate(_ delegate: AVCaptureVideoDataOutputSampleBufferDelegate) {
//        self.captureDeviceOutput?.setSampleBufferDelegate(delegate, queue: .main)
        self.captureDeviceOutput?.setSampleBufferDelegate(delegate, queue: self.captureSessionQueue)
    }

    
    public func startRunning() {
        self.captureSessionQueue.async {
            self.captureSession.startRunning()
        }
    }
    
    
    public func stopRunning() {
        self.captureSessionQueue.async {
            self.captureSession.stopRunning()
        }
    }
    
    
    /// Check the video authorization status. Video access is required and audio access is optional. If the user denies audio access, AVCam won't record audio during movie recording.
    private func requestUserAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // The user has previously granted access to the camera.
            break
            
        case .notDetermined:
            // The user has not yet been presented with the option to grant video access. Suspend the session queue to delay session setup until the access request has completed.
            self.captureSessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.captureSessionQueue.resume()
            })
            
        default:
            // The user has previously denied access.
            self.setupResult = .notAuthorized
        }
    }
    
        
    private func setCaptureDevice() throws {
        self.captureSession.beginConfiguration()
        
        // MARK: Configure Camera Input

        guard let captureDevice: AVCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            throw CameraFeedManagerError.CaptureDeviceNotFound
        }
        let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
        
        // MARK: Add Camera Input
        
        if self.captureSession.canAddInput(captureDeviceInput) {
            self.captureSession.addInput(captureDeviceInput)
            self.captureDeviceInput = captureDeviceInput
        } else {
            throw CameraFeedManagerError.InputCannotBeAdded
        }
        
        // MARK: Configure Camera Output
        
        let captureVideoDataOutput = AVCaptureVideoDataOutput()
        captureVideoDataOutput.videoSettings = outputVideoSettings
        captureVideoDataOutput.alwaysDiscardsLateVideoFrames = true
        captureVideoDataOutput.connection(with: .video)?.videoOrientation = .portrait
        captureVideoDataOutput.connection(with: .video)?.isVideoMirrored = false
//        captureVideoDataOutput.setSampleBufferDelegate(self, queue: self.videoDataOutputQueue)

        // MARK: Add Camera Output

        if self.captureSession.canAddOutput(captureVideoDataOutput) {
            self.captureSession.addOutput(captureVideoDataOutput)
            self.captureDeviceOutput = captureVideoDataOutput
        } else {
            throw CameraFeedManagerError.OutputCannotBeAdded
        }
        
        self.captureSession.commitConfiguration()
    }
    
    
    // MARK: - Session Management
    
    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }

}


// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraFeedManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    

}
