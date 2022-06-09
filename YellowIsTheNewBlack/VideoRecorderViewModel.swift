//
//  CameraViewController.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/06/07.
//

import AVFoundation

class VideoRecoderViewModel: NSObject {
    // Dependencies
    private let videoFileManager: VideoFileManager
    private let captureSession: AVCaptureSession
    private var device: AVCaptureDevice? = nil
    private var output: AVCaptureMovieFileOutput? = nil
    
    // MARK: - Public methods and vars
    
    var getPreviewLayer: AVCaptureVideoPreviewLayer {
        AVCaptureVideoPreviewLayer(session: self.captureSession)
    }
    
    /// Set up the AV session
    ///
    /// 밖에서 무조건 실행되어야 함.
    /// 에러핸들링을 `init` 외에서 해 조금이나마 용이하게 하기 위함임.
    func setupSession() throws {
        guard let device = self.device else {
            throw VideoRecorderError.invalidDevice
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
        
        captureSession.commitConfiguration()
    }
    
    // ???: Should be executed outside?
    func startRunningCamera() {
        self.captureSession.startRunning()
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
    
    /// Finds best camera for the device
    private func findBestCamera(in position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        var deviceTypes: [AVCaptureDevice.DeviceType]!
        
        if #available(iOS 11.1, *) {
            deviceTypes = [.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera]
        } else {
            deviceTypes = [.builtInDualCamera, .builtInWideAngleCamera]
        }
        
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: deviceTypes,
            mediaType: .video,
            position: .unspecified
        )
        
        let devices = discoverySession.devices
        guard devices.isEmpty else {
            return nil
        }
        
        return devices.first(where: { device in device.position == position })
    }
    
    // MARK: - Init
    
    init(_ captureSession: AVCaptureSession = AVCaptureSession(),
         _ videoFileManager: VideoFileManager = VideoFileManager(),
         quality: AVCaptureSession.Preset = .low,
         position: AVCaptureDevice.Position = .back
    ) {
        captureSession.sessionPreset = quality
        
        self.captureSession = captureSession
        self.videoFileManager = videoFileManager
        
        super.init() // Why?

        let deviceFound = self.findBestCamera(in: position)
        self.device = deviceFound
    }
}

extension VideoRecoderViewModel: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error recording movie: \(error.localizedDescription)")
        } else {
            videoFileManager.save(path: outputFileURL)
        }
    }
}
