//
//  CameraViewController.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/06/07.
//

import AVFoundation
import RxSwift
import UIKit

/// 카메라세션
class VideoRecoderViewModel: NSObject {
    // Dependencies
    private let sessionManager: VideoSessionManager
    let videoConfiguration: VideoRecorderConfiguration
    
    // vars and lets
    private var videoSession: AVCaptureSession?
    private var bag = DisposeBag()
    private let workQueue = DispatchQueue(label: "videoWorkQueue", qos: .userInitiated)
    
    
    // MARK: - Public methods and vars
    var previewLayer: AVCaptureVideoPreviewLayer?
    let previewLayerObservable: PublishSubject<AVCaptureVideoPreviewLayer?>
    
    func setupSession(_ quality: AVCaptureSession.Preset = .medium,
                      _ position: AVCaptureDevice.Position) async throws {
        let session = try await sessionManager.setupSession(quality: quality, position: position)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayerObservable.onNext(previewLayer)
        videoSession = session
    }
    
    func startRunningCamera() {
        sessionManager.startRunningCamera()
    }
    
    func startRecordingVideo() throws {
        try sessionManager.startRecordingVideo()
    }
    
    func stopRecordingVideo() throws {
        try sessionManager.stopRecordingVideo()
    }
    
    func changeSetting(_ setting: VideoRecorderConfiguration.SettingProperties) {
        Task {
            do {
                try await self.setupSession(setting.quality, setting.position)
            } catch let error {
                print(error)
            }
        }
    }
    
    func bindObservables() {
        videoConfiguration.observable.asObservable()
            .observe(on: SerialDispatchQueueScheduler(queue: workQueue, internalSerialQueueName: "videoWorkQueue"))
            .subscribe(
                onNext: { [weak self] setting in
                    guard let self = self else { return }
                    self.workQueue.async {
                        self.changeSetting(setting)
                    }
//                    try await self.setupSession(setting.quality, setting.position)
                },
                onError: { error in
                    // TODO: Handle error
                })
            .disposed(by: bag)
    }
    
    init(_ sessionManager: VideoSessionManager = VideoSessionManager.shared,
         _ videoConfiguration: VideoRecorderConfiguration = VideoRecorderConfiguration.shared) {
        self.sessionManager = sessionManager
        self.videoConfiguration = videoConfiguration
        self.previewLayerObservable = PublishSubject<AVCaptureVideoPreviewLayer?>()
    }
}
