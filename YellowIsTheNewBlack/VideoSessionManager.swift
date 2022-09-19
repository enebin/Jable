//
//  VideoSessionManager.swift
//  YellowIsTheNewBlack
//
//  Created by 프라이빗 on 2022/06/18.
//

import UIKit
import AVFoundation

class VideoSessionManager: NSObject {
    static let shared = VideoSessionManager()
    
    // Dependencies
    private let videoFileManager: VideoFileManager
    private var captureSession: AVCaptureSession? = nil
    private var device: AVCaptureDevice? = nil
    private var output: AVCaptureMovieFileOutput? = nil

    // MARK: - Public methods and vars
    
    var previewLayer: AVCaptureVideoPreviewLayer? {
        guard let captureSession = captureSession else { return nil }

        return AVCaptureVideoPreviewLayer(session: captureSession)
    }
    
    /// 세션을 세팅한다
    ///
    /// init안에서 안 돌리고 밖에서 실행하는 이유는
    /// 에러핸들링을 `init` 외에서 해 조금이나마 용이하게 하기 위함임.
    func setupSession(quality: AVCaptureSession.Preset = .medium,
                      position: AVCaptureDevice.Position = .back) throws
    {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = quality
        
        try checkIsSessionConfigurable(session: captureSession, position: position)
    }
    
    /// 카메라를 돌리기 시작함
    func startRunningCamera() {
        self.captureSession?.startRunning()
    }
    
    /// '녹화'를 시작함
    func startRecordingVideo() throws {
        guard let output = self.output else {
            throw VideoRecorderError.notConfigured
        }
        
        let filePath = videoFileManager.filePath
        output.startRecording(to: filePath, recordingDelegate: self)
    }
    
    func stopRecordingVideo() throws {
        guard let output = self.output else {
            throw VideoRecorderError.notConfigured
        }
        
        output.stopRecording()
    }
    
    // MARK: - Internal methods
    
    private func checkIsSessionConfigurable(session: AVCaptureSession?, position: AVCaptureDevice.Position) throws {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            try self.setUpCaptureSession(session, position: position)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    do {
                        try self.setUpCaptureSession(session, position: position)
                    }
                    catch let error {
                        print(error.localizedDescription)
                    }
                }
            }
        case .denied:
            return
        case .restricted:
            return
        @unknown default:
            fatalError()
        }
    }
    
    private func setUpCaptureSession(_ session: AVCaptureSession?, position: AVCaptureDevice.Position) throws {
        guard let device = findBestCamera(in: position) else {
            throw VideoRecorderError.invalidDevice
        }
        
        guard let captureSession = captureSession else {
            throw VideoRecorderError.notConfigured
        }

        captureSession.beginConfiguration()
        
        let deviceInput = try AVCaptureDeviceInput(device: device)
        if captureSession.canAddInput(deviceInput) {
            captureSession.addInput(deviceInput)
        } else {
            throw VideoRecorderError.unableToSetInput
        }
        
        let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)!
        let audioInput = try AVCaptureDeviceInput(device: audioDevice)
        if captureSession.canAddInput(audioInput) {
            captureSession.addInput(audioInput)
        } else {
            throw VideoRecorderError.unableToSetInput
        }
        
        let fileOutput = AVCaptureMovieFileOutput()
        if captureSession.canAddOutput(fileOutput) {
            self.output = fileOutput
            captureSession.addOutput(fileOutput)
        } else {
            throw VideoRecorderError.unableToSetOutput
        }
        
        self.captureSession = captureSession
        self.device = device
        
        captureSession.commitConfiguration()
    }
    
    /// Finds the best camera among the several cameras
    ///
    /// Only back postion is supported now
    private func findBestCamera(in position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: position) {
            return device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) {
            return device
        } else {
            return nil
        }
    }
    
    // MARK: - Init
    
    init(_ videoFileManager: VideoFileManager = VideoFileManager.default) {
        self.videoFileManager = videoFileManager
    }
}

extension VideoSessionManager: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error recording movie: \(error.localizedDescription), \(error)")
        } else {
            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(outputFileURL.path) {
                // Save to the album roll
                UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, self, nil, nil)
                
                // Add to the local memory
                videoFileManager.addAfterEncode(at: outputFileURL)
            } else {
                print("Error while saving movie")
                return
            }
        }
    }
}
