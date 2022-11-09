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
        
        return
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
    
    // MARK: - Configuration setters
    func setSlientMode(_ isEnabled: Bool,
                       currentCamPosition: AVCaptureDevice.Position,
                       _ completion: @escaping (AVCaptureSession) -> Void) {
        workQueue.addOperation {
            do {
                let session = self.session
                session.beginConfiguration()
                defer {
                    session.commitConfiguration()
                }
                
                if isEnabled == false {
                    guard let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio) else {
                        print("Audio input's not usable")
                        return
                    }
                    let audioInput = try AVCaptureDeviceInput(device: audioDevice)
                    
                    if session.canAddInput(audioInput) {
                        session.addInput(audioInput)
                    } else {
                        print("audio input error")
                    }
                    
                    completion(session)
                } else {
                    session.inputs.forEach { input in
                        session.removeInput(input)
                    }
                    
                    self.setCameraPosition(currentCamPosition) { session in
                        completion(session)
                    }
                }
                
            } catch let error {
                print(error)
            }
        }
    }
    
    func setVideoQuality(_ quality: AVCaptureSession.Preset, _ completion: @escaping (AVCaptureSession) -> Void) {
        workQueue.addOperation {
            let session = self.session

            session.beginConfiguration()
            defer {
                session.commitConfiguration()
            }
            
            session.sessionPreset = quality
            
            completion(session)
        }
    }
    
    func setCameraPosition(_ position: AVCaptureDevice.Position, _ completion: @escaping (AVCaptureSession) -> Void)  {
        workQueue.addOperation {
            do {
                let session = self.session

                session.beginConfiguration()
                defer {
                    session.commitConfiguration()
                }
                
                session.inputs.forEach { input in
                    session.removeInput(input)
                }
                
                guard let device = self.findBestCamera(in: position) else {
                    throw VideoRecorderError.invalidDevice
                }

                let deviceInput = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(deviceInput) {
                    session.addInput(deviceInput)
                } else {
                    throw VideoRecorderError.unableToSetInput
                }
                
                completion(session)
            } catch let error {
                print(error)
            }
        }
    }
    
    // MARK: - Internal methods

    /// 세션을 시작함
    ///
    /// Config을 수정하기 전에 무조건 먼저 시작해놔야함. 변경 도중엔 실행 못함.
    private func startRunningSession(_ completion: Action? = nil) {
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
            self.workQueue.isSuspended = false
            completion?()
        }
    }
    
    private func configureCaptureSessionOutput() throws {
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
        workQueue.isSuspended = true
        
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
