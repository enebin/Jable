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
    
    private let dataOutputQueue = DispatchQueue(label: "data output queue")
    
    init(_ videoFileManager: VideoFileManager = VideoFileManager.default,
         _ videoAlbumSaver: VideoAlbumSaver = VideoAlbumSaver.shared) {
        self.videoFileManager = videoFileManager
        self.videoAlbumSaver = videoAlbumSaver
    }
    
    func setupSession(configuration: some VideoConfigurable) async throws -> AVCaptureSession {
        do {
            try await checkSessionConfigurable()
            return try await configureSessoion(configuration)
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
    private func configureSessoion(_ configuration: some VideoConfigurable) throws -> AVCaptureSession {
        guard AVCaptureMultiCamSession.isMultiCamSupported else {
            print("MultiCam not supported on this device")
            throw VideoRecorderError.notSupportedDevice
        }
        
        guard let session = self.session else {
            throw VideoRecorderError.notConfigured
        }
        
        // When using AVCaptureMultiCamSession, it is best to manually add connections from AVCaptureInputs to AVCaptureOutputs
        session.beginConfiguration()
        defer {
            session.commitConfiguration()
        }
        
        try configureBackCamera(session)
        try configureFrontCamera(session)
        if configuration.silentMode.value == false {
            try configureMicrophone(session)
        }
        
        return session
    }
    
    private func configureBackCamera(_ session: AVCaptureMultiCamSession) throws {
        session.beginConfiguration()
        defer {
            session.commitConfiguration()
        }
        
        // Find the back camera
        guard let backCamera = findBestCamera(in: .back) else {
            throw VideoRecorderError.unableToSetOutput
        }
        
        // Add the back camera input to the session
        
        let backCameraDeviceInput = try AVCaptureDeviceInput(device: backCamera)
        session.addInputWithNoConnections(backCameraDeviceInput)
        
        // Find the back camera device input's video port
        guard let backCameraVideoPort = backCameraDeviceInput.ports(for: .video,
                                                                    sourceDeviceType: backCamera.deviceType,
                                                                    sourceDevicePosition: backCamera.position).first else {
            throw VideoRecorderError.unableToSetInput
        }
        
        // Add the back camera video data output
        let backCameraVideoDataOutput = AVCaptureVideoDataOutput()
        guard session.canAddOutput(backCameraVideoDataOutput) else {
            throw VideoRecorderError.unableToSetOutput
        }
        
        session.addOutputWithNoConnections(backCameraVideoDataOutput)
        // Check if CVPixelFormat Lossy or Lossless Compression is supported
        
        if backCameraVideoDataOutput.availableVideoPixelFormatTypes.contains(kCVPixelFormatType_Lossy_32BGRA) {
            // Set the Lossy format
            print("Selecting lossy pixel format")
            backCameraVideoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_Lossy_32BGRA)]
        } else if backCameraVideoDataOutput.availableVideoPixelFormatTypes.contains(kCVPixelFormatType_Lossless_32BGRA) {
            // Set the Lossless format
            print("Selecting a lossless pixel format")
            backCameraVideoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_Lossless_32BGRA)]
        } else {
            // Set to the fallback format
            print("Selecting a 32BGRA pixel format")
            backCameraVideoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        }
        
        backCameraVideoDataOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
        
        // Connect the back camera device input to the back camera video data output
        let backCameraVideoDataOutputConnection = AVCaptureConnection(inputPorts: [backCameraVideoPort], output: backCameraVideoDataOutput)
        guard session.canAddConnection(backCameraVideoDataOutputConnection) else {
            print("Could not add a connection to the back camera video data output")
            throw VideoRecorderError.unableToSetOutput
        }
        session.addConnection(backCameraVideoDataOutputConnection)
        backCameraVideoDataOutputConnection.videoOrientation = .portrait
        
        // Connect the back camera device input to the back camera video preview layer
        // TODO:
        //        guard let backCameraVideoPreviewLayer = backCameraVideoPreviewLayer else {
        //            throw VideoRecorderError.unableToSetOutput
        //        }
        //        let backCameraVideoPreviewLayerConnection = AVCaptureConnection(inputPort: backCameraVideoPort, videoPreviewLayer: backCameraVideoPreviewLayer)
        //        guard session.canAddConnection(backCameraVideoPreviewLayerConnection) else {
        //            print("Could not add a connection to the back camera video preview layer")
        //            throw VideoRecorderError.unableToSetOutput
        //        }
        //        session.addConnection(backCameraVideoPreviewLayerConnection)
    }
    
    private func configureFrontCamera(_ session: AVCaptureMultiCamSession) throws {
        session.beginConfiguration()
        defer {
            session.commitConfiguration()
        }
        
        // Find the front camera
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("Could not find the front camera")
            throw VideoRecorderError.unableToSetOutput
        }
        
        // Add the front camera input to the session
        let frontCameraDeviceInput = try AVCaptureDeviceInput(device: frontCamera)
        session.canAddInput(frontCameraDeviceInput)
        session.addInputWithNoConnections(frontCameraDeviceInput)
        
        // Find the front camera device input's video port
        guard let frontCameraVideoPort = frontCameraDeviceInput.ports(for: .video,
                                                                      sourceDeviceType: frontCamera.deviceType,
                                                                      sourceDevicePosition: frontCamera.position).first else {
            print("Could not find the front camera device input's video port")
            throw VideoRecorderError.unableToSetInput
        }
        
        // Add the front camera video data output
        let frontCameraVideoDataOutput = AVCaptureVideoDataOutput()
        guard session.canAddOutput(frontCameraVideoDataOutput) else {
            print("Could not add the front camera video data output")
            throw VideoRecorderError.unableToSetOutput
        }
        session.addOutputWithNoConnections(frontCameraVideoDataOutput)
        // Check if CVPixelFormat Lossy or Lossless Compression is supported
        
        if frontCameraVideoDataOutput.availableVideoPixelFormatTypes.contains(kCVPixelFormatType_Lossy_32BGRA) {
            // Set the Lossy format
            frontCameraVideoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_Lossy_32BGRA)]
        } else if frontCameraVideoDataOutput.availableVideoPixelFormatTypes.contains(kCVPixelFormatType_Lossless_32BGRA) {
            // Set the Lossless format
            frontCameraVideoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_Lossless_32BGRA)]
        } else {
            // Set to the fallback format
            frontCameraVideoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        }
        
        frontCameraVideoDataOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
        
        // Connect the front camera device input to the front camera video data output
        let frontCameraVideoDataOutputConnection = AVCaptureConnection(inputPorts: [frontCameraVideoPort], output: frontCameraVideoDataOutput)
        guard session.canAddConnection(frontCameraVideoDataOutputConnection) else {
            print("Could not add a connection to the front camera video data output")
            throw VideoRecorderError.unableToSetOutput
        }
        session.addConnection(frontCameraVideoDataOutputConnection)
        frontCameraVideoDataOutputConnection.videoOrientation = .portrait
        frontCameraVideoDataOutputConnection.automaticallyAdjustsVideoMirroring = false
        frontCameraVideoDataOutputConnection.isVideoMirrored = true
        
        // Connect the front camera device input to the front camera video preview layer
        
        // TODO:
//        guard let frontCameraVideoPreviewLayer = frontCameraVideoPreviewLayer else {
//            throw VideoRecorderError.unableToSetOutput
//        }
//        let frontCameraVideoPreviewLayerConnection = AVCaptureConnection(inputPort: frontCameraVideoPort, videoPreviewLayer: frontCameraVideoPreviewLayer)
//        guard session.canAddConnection(frontCameraVideoPreviewLayerConnection) else {
//            print("Could not add a connection to the front camera video preview layer")
//            throw VideoRecorderError.unableToSetOutput
//        }
//        session.addConnection(frontCameraVideoPreviewLayerConnection)
//        frontCameraVideoPreviewLayerConnection.automaticallyAdjustsVideoMirroring = false
//        frontCameraVideoPreviewLayerConnection.isVideoMirrored = true
    }
    
    private func configureMicrophone(_ session: AVCaptureMultiCamSession) throws {
        session.beginConfiguration()
        defer {
            session.commitConfiguration()
        }
        
        // Find the microphone
        guard let microphone = AVCaptureDevice.default(for: .audio) else {
            print("Could not find the microphone")
            throw VideoRecorderError.unableToSetInput
        }
        
        // Add the microphone input to the session
        let microphoneDeviceInput = try AVCaptureDeviceInput(device: microphone)
        
        guard session.canAddInput(microphoneDeviceInput) else {
            print("Could not add microphone device input")
            throw VideoRecorderError.unableToSetInput
        }
        session.addInputWithNoConnections(microphoneDeviceInput)
        
        
        // Find the audio device input's back audio port
        guard let backMicrophonePort = microphoneDeviceInput.ports(for: .audio,
                                                                   sourceDeviceType: microphone.deviceType,
                                                                   sourceDevicePosition: .back).first else {
            print("Could not find the back camera device input's audio port")
            throw VideoRecorderError.unableToSetInput
        }
        
        // Find the audio device input's front audio port
        guard let frontMicrophonePort = microphoneDeviceInput.ports(for: .audio,
                                                                    sourceDeviceType: microphone.deviceType,
                                                                    sourceDevicePosition: .front).first else {
            print("Could not find the front camera device input's audio port")
            throw VideoRecorderError.unableToSetInput
        }
        
        // Add the back microphone audio data output
        let backMicrophoneAudioDataOutput = AVCaptureAudioDataOutput()
        guard session.canAddOutput(backMicrophoneAudioDataOutput) else {
            print("Could not add the back microphone audio data output")
            throw VideoRecorderError.unableToSetInput
        }
        session.addOutputWithNoConnections(backMicrophoneAudioDataOutput)
        backMicrophoneAudioDataOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
        
        // Add the front microphone audio data output
        let frontMicrophoneAudioDataOutput = AVCaptureAudioDataOutput()
        guard session.canAddOutput(frontMicrophoneAudioDataOutput) else {
            print("Could not add the front microphone audio data output")
            throw VideoRecorderError.unableToSetInput
        }
        session.addOutputWithNoConnections(frontMicrophoneAudioDataOutput)
        frontMicrophoneAudioDataOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
        
        // Connect the back microphone to the back audio data output
        
        // TODO:
//        let backMicrophoneAudioDataOutputConnection = AVCaptureConnection(inputPorts: [backMicrophonePort], output: backMicrophoneAudioDataOutput)
//        guard session.canAddConnection(backMicrophoneAudioDataOutputConnection) else {
//            print("Could not add a connection to the back microphone audio data output")
//            throw VideoRecorderError.unableToSetInput
//        }
//        session.addConnection(backMicrophoneAudioDataOutputConnection)
//
//        // Connect the front microphone to the back audio data output
//        let frontMicrophoneAudioDataOutputConnection = AVCaptureConnection(inputPorts: [frontMicrophonePort], output: frontMicrophoneAudioDataOutput)
//        guard session.canAddConnection(frontMicrophoneAudioDataOutputConnection) else {
//            print("Could not add a connection to the front microphone audio data output")
//            throw VideoRecorderError.unableToSetInput
//        }
//        session.addConnection(frontMicrophoneAudioDataOutputConnection)
    }
    
}

extension MultiVideoSessionManager: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
    }
}

extension MultiVideoSessionManager: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    
}
