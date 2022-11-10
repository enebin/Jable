//
//  VideoConfiguration.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/06/10.
//

import Foundation
import AVFoundation
import RxRelay

/// 인스턴스 생성에 세팅이 필요한 클래스를 위한 것
///
/// 그리고 세팅의 변화를 지속적으로 감시하고 싶을 누군가를 위한 싱글-톤 클래스
struct VideoSessionConfiguration: VideoConfigurable {
    // Now on testing
    static let observable = BehaviorRelay<VideoSessionConfiguration>(value: VideoSessionConfiguration())
    static let shared = VideoSessionConfiguration()

    var videoQuality = BehaviorRelay<AVCaptureSession.Preset>(value: .high)
    var cameraPosition = BehaviorRelay<AVCaptureDevice.Position>(value: .back)
    var silentMode = BehaviorRelay<Bool>(value: true)
    var stealthMode = BehaviorRelay<Bool>(value: false)
    var backgroundMode = BehaviorRelay<Bool>(value: true)
}

/// 그리고 세팅의 변화를 지속적으로 감시하고 싶을 누군가를 위한 싱글-톤 클래스
struct StaticVideoSessionConfiguration {
    // Now on testing
    static let shared = VideoSessionConfiguration()

    var videoQuality: AVCaptureSession.Preset = .high
    var cameraPosition: AVCaptureDevice.Position = .back
    var silentMode: Bool = true
    var stealthMode: Bool = false
}
