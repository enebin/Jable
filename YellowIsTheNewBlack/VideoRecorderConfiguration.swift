//
//  VideoConfiguration.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/06/10.
//

import Foundation
import AVFoundation

import RxRelay
import RxSwift

struct LocalVideoSessionConfiguration: VideoConfigurable {
    var videoQuality: AVCaptureSession.Preset {
        get {
            return UserDefaults.standard.object(forKey: "videoQuality") as? AVCaptureSession.Preset
            ?? AVCaptureSession.Preset.high
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "videoQuality")
        }
    }
    
    var cameraPosition: AVCaptureDevice.Position {
        get {
            return UserDefaults.standard.object(forKey: "cameraPosition") as? AVCaptureDevice.Position
            ?? AVCaptureDevice.Position.back
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "cameraPosition")
        }
    }
    
    var silentMode: Bool {
        get {
            return UserDefaults.standard.object(forKey: "silentMode") as? Bool ?? true
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "silentMode")
        }
    }
    
    var backgroundMode: Bool {
        get {
            return UserDefaults.standard.object(forKey: "backgroundMode") as? Bool ?? true
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "backgroundMode")
        }
    }
    
    var stealthMode: Bool = false
    
    var zoomFactor: CGFloat = 0
}

/// 인스턴스 생성에 세팅이 필요한 클래스를 위한 것
///
/// 그리고 세팅의 변화를 지속적으로 감시하고 싶을 누군가를 위한 싱글-톤 클래스
class VideoSessionConfiguration {
    var bag = DisposeBag()
    
    // Local file management
    private var configurationData: VideoConfigurable

    // MARK: Needs to be saved locally
    var videoQuality: BehaviorRelay<AVCaptureSession.Preset>
    var cameraPosition: BehaviorRelay<AVCaptureDevice.Position>
    var silentMode: BehaviorRelay<Bool>
    var backgroundMode: BehaviorRelay<Bool>
    
    // MARK: Remain in memory
    var stealthMode: BehaviorRelay<Bool>
    var zoomFactor: BehaviorRelay<CGFloat>
    
    func setSaver() {
        videoQuality.bind { [weak self] value in
            guard let self = self else { return }
            self.configurationData.videoQuality = value
        }
        .disposed(by: bag)
        
        cameraPosition.bind { [weak self] value in
            guard let self = self else { return }

            self.configurationData.cameraPosition = value
        }
        .disposed(by: bag)
        
        silentMode.bind { [weak self] value in
            guard let self = self else { return }

            self.configurationData.silentMode = value
        }
        .disposed(by: bag)

        backgroundMode.bind { [weak self] value in
            guard let self = self else { return }

            self.configurationData.backgroundMode = value
        }
        .disposed(by: bag)

    }
    
    init(_ configurationData: some VideoConfigurable = LocalVideoSessionConfiguration()) {
        self.configurationData = configurationData

        self.videoQuality = BehaviorRelay<AVCaptureSession.Preset>(value: configurationData.videoQuality)
        self.cameraPosition = BehaviorRelay<AVCaptureDevice.Position>(value: configurationData.cameraPosition)
        self.silentMode = BehaviorRelay<Bool>(value: configurationData.silentMode)
        self.backgroundMode = BehaviorRelay<Bool>(value: configurationData.backgroundMode)
        self.stealthMode = BehaviorRelay<Bool>(value: configurationData.stealthMode)
        self.zoomFactor = BehaviorRelay<CGFloat>(value: configurationData.zoomFactor)
    }
}
