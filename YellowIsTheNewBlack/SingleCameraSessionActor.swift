//
//  SingleCameraActorManager.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/11/09.
//

import Foundation
import UIKit
import AVFoundation

actor SingleVideoSessionActor: NSObject {
    static let shared = SingleVideoSessionManager()
    
    // Dependencies
    private let videoFileManager: VideoFileManager
    private let videoAlbumSaver: VideoAlbumSaver
    private let captureSession: AVCaptureSession

    // MARK: - Public methods and vars
    
    var session: AVCaptureSession? {
        return self.captureSession
    }
    
    private var output: AVCaptureMovieFileOutput? {
        return session?.outputs.first as? AVCaptureMovieFileOutput
    }
    
    /// 세션을 세팅한다
    ///
    /// init안에서 안 돌리고 밖에서 실행하는 이유는
    /// 에러핸들링을 `init` 외에서 해 조금이나마 용이하게 하기 위함임.
    func setupSession(configuration: some VideoConfigurable) async throws {
        print("@@@ 4Enter setup")
        try await checkSessionConfigurable()
        try self.configureCaptureSession(session: self.captureSession,
                                         configuration: configuration)
        try self.startRunningSession()
        return
    }
    
    /// 카메라를 돌리기 시작함
    func startRunningSession() throws {
        Task(priority: .background) {
            self.captureSession.startRunning()
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
    private func configureCaptureSession(session: AVCaptureSession, configuration: some VideoConfigurable) throws -> AVCaptureSession {
        let position = configuration.cameraPosition.value
        let silentMode = configuration.silentMode.value
        
        let captureSession = session
        print("@@@ 5try config")
        captureSession.beginConfiguration()

        captureSession.sessionPreset = configuration.videoQuality.value

        guard let device = findBestCamera(in: position) else {
            throw VideoRecorderError.invalidDevice
        }
        
        if captureSession.inputs.isEmpty {
            let deviceInput = try AVCaptureDeviceInput(device: device)
            if captureSession.canAddInput(deviceInput) {
                captureSession.addInput(deviceInput)
            } else {
                throw VideoRecorderError.unableToSetInput
            }
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

        if captureSession.outputs.isEmpty {
            let fileOutput = AVCaptureMovieFileOutput()
            if captureSession.canAddOutput(fileOutput) {
                captureSession.addOutput(fileOutput)
            } else {
                throw VideoRecorderError.unableToSetOutput
            }
        }
       
        captureSession.commitConfiguration()
        print("@@@ 6end config")

        return captureSession
    }
    
    // MARK: - Init
    init(_ videoFileManager: VideoFileManager = VideoFileManager.default,
         _ videoAlbumSaver: VideoAlbumSaver = VideoAlbumSaver.shared) {
        self.videoFileManager = videoFileManager
        self.videoAlbumSaver = videoAlbumSaver
        self.captureSession = AVCaptureSession()
    }
}

extension SingleVideoSessionActor: AVCaptureFileOutputRecordingDelegate {
    nonisolated func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("Record started now")
    }
    
    nonisolated func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
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

extension SingleVideoSessionActor {
    func findBestCamera(in position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: position) {
            return device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) {
            return device
        } else {
            return nil
        }
    }
    
    func checkSessionConfigurable() async throws {
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
}
