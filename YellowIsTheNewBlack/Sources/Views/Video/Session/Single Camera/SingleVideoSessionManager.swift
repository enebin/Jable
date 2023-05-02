//
//  VideoSessionManager.swift
//  YellowIsTheNewBlack
//
//  Created by 프라이빗 on 2022/06/18.
//

import UIKit
import AVFoundation

import RxRelay

class SingleVideoSessionManager: NSObject, VideoSessionManaging {
    typealias SessionHandler = (AVCaptureSession) -> Void

    static let shared = SingleVideoSessionManager()

    // MARK: Dependencies
    private let videoFileManager: VideoFileManager
    private let videoAlbumSaver: VideoAlbumSaver
    private let videoStreamProcessor: VideoRecorder

    // MARK: - Public properties
    let session: AVCaptureSession
    var statusObserver: ReplayRelay<Error>?

    var currentZoomFactor: CGFloat? {
        guard let videoDevice = videoDevice else { return nil }

        return videoDevice.device.videoZoomFactor
    }

    var maxZoomFactor: CGFloat? {
        guard let videoDevice = videoDevice else { return nil }

        return videoDevice.device.activeFormat.videoMaxZoomFactor
    }

    // MARK: - Private properties
    private let configuration: VideoSessionConfiguration
    private let workQueue: OperationQueue
    private let videoQueue: DispatchQueue

    private var output: AVCaptureMovieFileOutput? {
        return session.outputs.first as? AVCaptureMovieFileOutput
    }

    private var audioDevice: AVCaptureDeviceInput?
    private var videoDevice: AVCaptureDeviceInput?

    init(_ videoFileManager: VideoFileManager = VideoFileManager.default,
         _ videoAlbumSaver: VideoAlbumSaver = VideoAlbumSaver.shared) {
        self.videoFileManager = videoFileManager
        self.videoAlbumSaver = videoAlbumSaver

        self.workQueue = OperationQueue()
        workQueue.qualityOfService = .background
        workQueue.maxConcurrentOperationCount = 1
        workQueue.isSuspended = true

        self.videoQueue = DispatchQueue(label: "com.video.enebin", qos: .utility)

        self.session = AVCaptureSession()
        self.configuration = VideoSessionConfiguration()

        self.videoStreamProcessor = VideoRecorder(captureSession: session)

        super.init()

        self.startRunningSession()
    }
}

extension SingleVideoSessionManager {
    // MARK: - Public methods and vars
    /// 세션을 세팅한다
    ///
    /// init안에서 안 돌리고 밖에서 실행하는 이유는
    /// 에러핸들링을 `init` 외에서 해 조금이나마 용이하게 하기 위함임.
    func setupSession() async throws {
        try await checkPermissionForCaptureSession()
//        try configureCaptureSessionOutput()
    }

    /// '녹화'를 시작함
    func startRecordingVideo(_ completion: Action?) throws {
        // 세션이 구성되지 않았으면 에러를 반환
        guard let output = self.output else {
            throw VideoRecorderError.notConfigured
        }

        let filePath = videoFileManager.filePath
//        output.startRecording(to: filePath, recordingDelegate: self)
        completion?()
    }

    /// '녹화'를 시작함
    func startRecordingVideo() async throws {
        // 세션이 구성되지 않았으면 에러를 반환
        let filePath = videoFileManager.filePath
        videoStreamProcessor.startRecording(to: filePath)
    }

    func stopRecordingVideo(_ completion: Action? = nil) throws {
        guard let output = self.output else {
            throw VideoRecorderError.notConfigured
        }

        output.stopRecording()
        completion?()
    }

    func stopRecordingVideo() async throws {
        let url = try await videoStreamProcessor.stopRecording()
        writeOutputFile(to: url)
    }

    func pauseRecordingVideo() async throws {
        try await videoStreamProcessor.pauseRecording()
    }

    func resumeRecordingVideo(_ completion: Action? = nil) async throws {
        try await self.startRecordingVideo()
    }
}

extension SingleVideoSessionManager {
    // MARK: - Configuration setters(editting session)
    func setSlientMode(_ isEnabled: Bool,
                       currentCamPosition: AVCaptureDevice.Position,
                       _ completion: @escaping SessionHandler) {
        workQueue.addOperation { [weak self] in
            guard let self = self else { return }

            do {
                let session = self.session
                session.beginConfiguration()
                defer {
                    session.commitConfiguration()
                }

                if isEnabled == false {
                    // Add audio
                    guard let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio) else {
                        print("Audio input's not available")
                        return
                    }
                    let audioInput = try AVCaptureDeviceInput(device: audioDevice)

                    if session.canAddInput(audioInput) {
                        session.addInput(audioInput)
                    } else {
                        print("audio input error")
                    }

                    self.audioDevice = audioInput
                    completion(session)
                } else {
                    guard let audioDevice = self.audioDevice else {
                        return
                    }

                    self.session.removeInput(audioDevice)
                }
            } catch let error {
                print(error)
            }
        }
    }

    func setVideoQuality(_ quality: AVCaptureSession.Preset, _ completion: @escaping SessionHandler) {
        workQueue.addOperation { [weak self] in
            guard let self = self else { return }

            let session = self.session

            session.beginConfiguration()
            defer {
                session.commitConfiguration()
            }

            session.sessionPreset = quality

            completion(session)
        }
    }

    func setCameraPosition(_ position: AVCaptureDevice.Position, _ completion: @escaping SessionHandler) {
        workQueue.addOperation { [weak self] in
            guard let self = self else { return }

            do {
                let session = self.session

                session.beginConfiguration()
                defer {
                    session.commitConfiguration()
                }

                if let existingDevice = self.videoDevice {
                    session.removeInput(existingDevice)
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

                self.videoDevice = deviceInput
                completion(session)
            } catch let error {
                print(error)
            }
        }
    }

    func setZoom(_ factor: CGFloat) {
        guard let videoDevice = videoDevice else {
            return
        }

        do {
            try videoDevice.device.lockForConfiguration()
            defer {
                videoDevice.device.unlockForConfiguration()
            }

            videoDevice.device.videoZoomFactor = factor
        } catch {
            return
        }
    }

    @available(iOS 16, *)
    func setBackgroundMode(_ isEnabled: Bool, _ completion: @escaping SessionHandler) {
        workQueue.addOperation { [weak self] in
            guard let self = self else { return }
            let session = self.session

            session.beginConfiguration()
            defer {
                session.commitConfiguration()
            }

            session.isMultitaskingCameraAccessEnabled = isEnabled == true

            completion(session)
        }
    }
}

extension SingleVideoSessionManager {
    // MARK: - Internal methods

    /// 세션을 시작함
    ///
    /// Config을 수정하기 전에 무조건 먼저 시작해놔야함. 변경 도중엔 실행 못함.
    private func startRunningSession(_ completion: Action? = nil) {
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
            try? self.videoStreamProcessor.setupCaptureSession()
            self.workQueue.isSuspended = false
            completion?()
        }
    }

    /// 앨범에 파일 저장
    func writeOutputFile(to outputFileURL: URL) {
        if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(outputFileURL.path) {
            Task(priority: .background) {
                do {
                    try await self.videoAlbumSaver.save(videoURL: outputFileURL)
                } catch let error {
                    self.statusObserver?.accept(error)
                }
            }
        } else {
            print("Error while saving movie")
            self.statusObserver?.accept(VideoAlbumError.unabledToAccessAlbum)
            return
        }
    }

//    private func configureCaptureSessionOutput(with output: AVCaptureOutput) throws {
//        session.beginConfiguration()
//
//        if session.outputs.isEmpty {
//            if session.canAddOutput(output) {
//                session.addOutput(output)
//            } else {
//                throw VideoRecorderError.unableToSetOutput
//            }
//        }
//
//        session.commitConfiguration()
//    }
}
