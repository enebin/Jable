//
//  MultiVideoSessionManager.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/10/12.
//

import AVFoundation
//
class MultiVideoSessionManager: NSObject, SessionManager {
    
    // Dependencies
    private let videoFileManager: VideoFileManager
    private let videoAlbumSaver: VideoAlbumSaver
    private var session: AVCaptureMultiCamSession?
    private var device: AVCaptureDevice?
    private var output: AVCaptureMovieFileOutput?
    
    func setupSession(configuration: some VideoConfigurable) async throws -> AVCaptureSession {
        do {
            try await checkSessionConfigurable()
            return try await configureCaptureSession(configuration: configuration)
        } catch let error {
            throw error
        }
    }
    
    func startRunningCamera() {
        DispatchQueue.global(qos: .background).async {
            self.session?.startRunning()
        }
    }
    
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
    private func configureCaptureSession(configuration: some VideoConfigurable) async throws -> AVCaptureSession {
        let position = configuration.cameraPosition.value
        let silentMode = configuration.silentMode.value
        
        let captureSession = AVCaptureMultiCamSession()
        
        guard let device = findBestCamera(in: position) else {
            throw VideoRecorderError.invalidDevice
        }
        
        captureSession.beginConfiguration()

        let deviceInput = try AVCaptureDeviceInput(device: device)
        if captureSession.canAddInput(deviceInput) {
            captureSession.addInput(deviceInput)
        } else {
            throw VideoRecorderError.unableToSetInput
        }
        
        if silentMode == false {
            let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)!
            let audioInput = try AVCaptureDeviceInput(device: audioDevice)
            if captureSession.canAddInput(audioInput) {
                captureSession.addInput(audioInput)
            } else {
                throw VideoRecorderError.unableToSetInput
            }
        }

        let fileOutput = AVCaptureMovieFileOutput()
        if captureSession.canAddOutput(fileOutput) {
            self.output = fileOutput
            captureSession.addOutput(fileOutput)
        } else {
            throw VideoRecorderError.unableToSetOutput
        }
                
        self.session = captureSession
        self.device = device
        
        captureSession.commitConfiguration()
        
        return captureSession
    }
}

extension MultiVideoSessionManager: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
    }
}
