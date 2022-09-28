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
class VideoRecorderConfiguration {
    // MARK: - vars and lets
    private var setting: SettingProperties
    
    /// Subscribe it to catch up with the newest setting
    let observable: BehaviorSubject<SettingProperties>
    
    
    // MARK: - Initializer
    init(_ setting: SettingProperties = SettingProperties()) {
        self.setting = setting
        self.observable = BehaviorSubject<SettingProperties>(value: setting)
    }
    
    func changeVideoQuality(to quality: AVCaptureSession.Preset) {
        var newSetting = self.setting
        newSetting.quality = quality
        
        self.handleSettingChanged(with: newSetting)
    }
    
    func changeCameraPosition(to position: AVCaptureDevice.Position) {
        var newSetting = self.setting
        newSetting.position = position
        
        self.handleSettingChanged(with: newSetting)
    }
    
    
    // MARK: - Private methods
    private func handleSettingChanged(with newSetting: SettingProperties) {
        self.observable.onNext(newSetting)
        self.setting = newSetting
    }
}

extension VideoRecorderConfiguration {
    struct SettingProperties {
        var quality: AVCaptureSession.Preset = .medium
        var position: AVCaptureDevice.Position = .back
    }
}
