//
//  VideoConfiguration.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/06/10.
//

import Foundation
import AVFoundation
import RxRelay

struct LocalVideoSessionConfiguration: VideoConfigurable {
    let fileManager = FileManager.default
    
    // MARK: Needs to be saved locally
    var videoQuality: AVCaptureSession.Preset = .high
    var cameraPosition: AVCaptureDevice.Position = .back
    var silentMode = true
    var backgroundMode = true
    
    // MARK: Remain in memory
    var stealthMode = false
    var zoomFactor: CGFloat = 0
    
    init() {
        // Load from file manager
        

    }
}

/// 인스턴스 생성에 세팅이 필요한 클래스를 위한 것
///
/// 그리고 세팅의 변화를 지속적으로 감시하고 싶을 누군가를 위한 싱글-톤 클래스
struct VideoSessionConfiguration {
    // Local file management
    var configurationData: some VideoConfigurable = LocalVideoSessionConfiguration()

    // MARK: Needs to be saved locally
    var videoQuality = BehaviorRelay<AVCaptureSession.Preset>(value: .high)
    var cameraPosition = BehaviorRelay<AVCaptureDevice.Position>(value: .back)
    var silentMode = BehaviorRelay<Bool>(value: true)
    var backgroundMode = BehaviorRelay<Bool>(value: true)
    
    // MARK: Remain in memory
    var stealthMode = BehaviorRelay<Bool>(value: false)
    var zoomFactor = BehaviorRelay<CGFloat>(value: 0)
    
    func loader() {
        
    }
    
    func saver() {
        
    }
}
