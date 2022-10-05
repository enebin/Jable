//
//  VideoConfiguration.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/06/10.
//

import Foundation
import AVFoundation
import RxSwift

/// 인스턴스 생성에 세팅이 필요한 클래스를 위한 것
///
/// 그리고 세팅의 변화를 지속적으로 감시하고 싶을 누군가를 위한 싱글-톤 클래스
class RecorderConfiguration: VideoConfiguration {
    static let shared = RecorderConfiguration()

    var videoQuality: AVCaptureSession.Preset = .high
    
    var cameraPosition: AVCaptureDevice.Position = .back
    
    var silentMode: Bool = false
}
