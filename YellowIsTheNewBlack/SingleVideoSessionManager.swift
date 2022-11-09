//
//  VideoSessionManager.swift
//  YellowIsTheNewBlack
//
//  Created by 프라이빗 on 2022/06/18.
//

import UIKit
import AVFoundation

class SingleVideoSessionManager: NSObject, VideoSessionManager {
    static let shared = SingleVideoSessionManager()
    
    // Dependencies
    private let videoFileManager: VideoFileManager
    private let videoAlbumSaver: VideoAlbumSaver
    
    let session: AVCaptureSession
    private let configuration: VideoSessionConfiguration
    
    private let workQueue: OperationQueue
    private var output: AVCaptureMovieFileOutput? {
        return session.outputs.first as? AVCaptureMovieFileOutput
    }
    
    // MARK: - Public methods and vars
    /// 세션을 세팅한다
    ///
    /// init안에서 안 돌리고 밖에서 실행하는 이유는
    /// 에러핸들링을 `init` 외에서 해 조금이나마 용이하게 하기 위함임.
    func setupSession() async throws {
        print("@@@ Enter setup")
        try await checkSessionConfigurable()
        
        try self.configureCaptureSessionOutput()
        try self.startRunningSession()
        
        return
    }
    
    /// 카메라를 돌리기 시작함
    func startRunningSession(_ completion: Action? = nil) {
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
            completion?()
        }
    }
    
    /// '녹화'를 시작함
    func startRecordingVideo(_ completion: Action? = nil) throws {
        guard let output = self.output else {
            throw VideoRecorderError.notConfigured
        }
        
        let filePath = videoFileManager.filePath
        output.startRecording(to: filePath, recordingDelegate: self)
        completion?()
    }
    
    func stopRecordingVideo(_ completion: Action? = nil) throws {
        guard let output = self.output else {
            throw VideoRecorderError.notConfigured
        }
        
        output.stopRecording()
        completion?()
    }
    
    func setSlientMode(_ isEnabled: Bool) throws -> AVCaptureSession  {
        session.beginConfiguration()
        defer {
            session.commitConfiguration()
        }
        
        if isEnabled == true {
            let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)!
            let audioInput = try AVCaptureDeviceInput(device: audioDevice)
            if session.canAddInput(audioInput) {
                session.addInput(audioInput)
            } else {
                throw VideoRecorderError.unableToSetInput
            }
        }
        
        return session
    }
    
    func setVideoQuality(_ quality: AVCaptureSession.Preset) throws -> AVCaptureSession {
        session.beginConfiguration()
        defer {
            session.commitConfiguration()
        }
        
        session.sessionPreset = quality
        return session
    }
    
    func setCameraPosition(_ position: AVCaptureDevice.Position) throws -> AVCaptureSession  {
        session.beginConfiguration()
        defer {
            session.commitConfiguration()
        }
        
        guard let device = findBestCamera(in: position) else {
            throw VideoRecorderError.invalidDevice
        }
        
        let deviceInput = try AVCaptureDeviceInput(device: device)
        if session.canAddInput(deviceInput) {
            session.addInput(deviceInput)
        } else {
            throw VideoRecorderError.unableToSetInput
        }
        
        return session
    }
    
    // MARK: - Internal methods
    func configureCaptureSessionOutput() throws {
        print("@@@ try config")

        session.beginConfiguration()

        if session.outputs.isEmpty {
            let fileOutput = AVCaptureMovieFileOutput()
            if session.canAddOutput(fileOutput) {
                session.addOutput(fileOutput)
            } else {
                throw VideoRecorderError.unableToSetOutput
            }
        }
       
        session.commitConfiguration()
        print("@@@ end config")
    }
    
    // MARK: - Init
    init(_ videoFileManager: VideoFileManager = VideoFileManager.default,
         _ videoAlbumSaver: VideoAlbumSaver = VideoAlbumSaver.shared) {
        self.videoFileManager = videoFileManager
        self.videoAlbumSaver = videoAlbumSaver
        
        self.session = AVCaptureSession()
        self.configuration = VideoSessionConfiguration()
        
        
        self.workQueue = OperationQueue()
        workQueue.qualityOfService = .background
        workQueue.maxConcurrentOperationCount = 1
        
        super.init()
        self.startRunningSession()
    }
}

extension SingleVideoSessionManager: AVCaptureFileOutputRecordingDelegate {
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
