//
//  VideoConfiguration.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/10/04.
//

import RxRelay
import AVFoundation

protocol VideoConfigurable {
    // MARK: Needs to be saved locally
    var videoQuality: AVCaptureSession.Preset { get set }
    var cameraPosition: AVCaptureDevice.Position { get set }
    var silentMode: Bool { get set }
    var backgroundMode: Bool { get set }
    
    // MARK: Remain in memory
    var stealthMode: Bool { get set }
    var zoomFactor: CGFloat { get set }
}
