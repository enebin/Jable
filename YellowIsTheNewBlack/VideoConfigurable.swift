//
//  VideoConfiguration.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/10/04.
//

import RxRelay
import AVFoundation

protocol VideoConfigurable {
    var videoQuality: BehaviorRelay<AVCaptureSession.Preset>  { get }
    var cameraPosition: BehaviorRelay<AVCaptureDevice.Position> { get }
    var silentMode: BehaviorRelay<Bool> { get }
}
