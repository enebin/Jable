//
//  SessionManager+Extension.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/10/12.
//

import AVFoundation

enum DeviceType {
    case frontCamera
    case backCamera
    case microphone
    
    var captureDeviceType: AVCaptureDevice.DeviceType {
        switch self {
        case .frontCamera, .backCamera:
            return .builtInWideAngleCamera
        case .microphone:
            return .builtInMicrophone
        }
    }
    
    var captureMediaType: AVMediaType {
        switch self {
        case .frontCamera, .backCamera:
            return .video
        case .microphone:
            return .audio
        }
    }
    
    var capturePosition: AVCaptureDevice.Position {
        switch self {
        case .frontCamera:
            return .front
        case .backCamera:
            return .back
        case .microphone:
            return .unspecified
        }
    }
}

extension VideoSessionManager {
    func captureDeviceInput(type: DeviceType) throws -> AVCaptureDeviceInput {
        let captureDevices = AVCaptureDevice.DiscoverySession(
            deviceTypes: [type.captureDeviceType],
            mediaType: type.captureMediaType,
            position: type.capturePosition
        )
        
        guard let captureDevice = captureDevices.devices.first else {
            throw VideoRecorderError.invalidDevice
        }
        
        return try AVCaptureDeviceInput(device: captureDevice)
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
    
    /// Finds the best camera among the several cameras
    ///
    /// Only back postion is supported now
    func findBestCamera(in position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: position) {
            return device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) {
            return device
        } else {
            return nil
        }
    }
}
