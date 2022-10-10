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
    private let videoAlbumSaver: VideoAlbumSaver
    private var captureSession: AVCaptureSession? = nil
    private var device: AVCaptureDevice? = nil
    private var output: AVCaptureMovieFileOutput? = nil

    // MARK: - Public methods and vars
    
    /// 세션을 세팅한다
    ///
    /// init안에서 안 돌리고 밖에서 실행하는 이유는
    /// 에러핸들링을 `init` 외에서 해 조금이나마 용이하게 하기 위함임.
    func setupSession(configuration: some VideoConfigurable) async throws -> AVCaptureSession {
        do {
            try await checkSessionConfigurable()
            return try await configureCaptureSession(configuration: configuration)
        } catch let error {
            throw error
        }
    }
    
    /// 카메라를 돌리기 시작함
    func startRunningCamera() {
        DispatchQueue.global(qos: .background).async {
            self.captureSession?.startRunning()
        }
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
    private func checkSessionConfigurable() async throws {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return
        case .notDetermined:
            let isGranted = await AVCaptureDevice.requestAccess(for: .video)
            if isGranted {
                return
            } else {
                throw VideoRecorderError.permissionDenied
            }
        case .denied:
            throw VideoRecorderError.permissionDenied
        case .restricted:
            throw VideoRecorderError.permissionDenied
        @unknown default:
            throw VideoRecorderError.invalidDevice
        }
    }
    
    private func configureCaptureSession(configuration: some VideoConfigurable) async throws -> AVCaptureSession {
        let position = configuration.cameraPosition.value
        let silentMode = configuration.silentMode.value
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = configuration.videoQuality.value
        
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
                
        self.captureSession = captureSession
        self.device = device
        
        captureSession.commitConfiguration()
        
        return captureSession
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
    
    init(_ videoFileManager: VideoFileManager = VideoFileManager.default,
         _ videoAlbumSaver: VideoAlbumSaver = VideoAlbumSaver()) {
        self.videoFileManager = videoFileManager
        self.videoAlbumSaver = videoAlbumSaver
    }
}

extension VideoSessionManager: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("Record started now")
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("Record finished")
        
        if let error = error {
            print("Error recording movie: \(error.localizedDescription), \(error)")
        } else {
            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(outputFileURL.path) {
                Task(priority: .background) {
                    await self.videoAlbumSaver.save(videoURL: outputFileURL)
                }
            } else {
                print("Error while saving movie")
                return
            }
        }
    }
}
