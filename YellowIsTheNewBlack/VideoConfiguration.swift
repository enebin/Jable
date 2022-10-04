//
//  VideoConfiguration.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/10/04.
//

import Foundation
import AVFoundation

protocol VideoConfiguration {
    var videoQuality: AVCaptureSession.Preset  { get set }
    var cameraPosition: AVCaptureDevice.Position { get set }
    var silentMode: Bool { get set }
}

class RecorderConfiguration: VideoConfiguration {
    var videoQuality: AVCaptureSession.Preset = .high
    
    var cameraPosition: AVCaptureDevice.Position = .back
    
    var silentMode: Bool = true
}
