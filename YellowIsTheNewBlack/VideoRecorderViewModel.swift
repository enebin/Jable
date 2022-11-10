//
//  CameraViewController.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/06/07.
//

import AVFoundation
import UIKit

import RxSwift
import RxRelay

/// 카메라세션
class VideoRecoderViewModel: NSObject {
    // Dependencies
    private let sessionManager: SingleVideoSessionManager
    let videoConfiguration: VideoSessionConfiguration
    private let videoAlbumFethcher: VideoAlbumFetcher
    
    // vars and lets
    private var bag = DisposeBag()
    private var isObservablesBound = false
    
    private let workQueue = SerialDispatchQueueScheduler(qos: .userInitiated)
    
    // MARK: - Public methods and vars
    let previewLayer = PublishRelay<AVCaptureVideoPreviewLayer?>()
    var thumbnailObserver: Observable<UIImage?>
    
    func startRecordingVideo() throws {
        try sessionManager.startRecordingVideo(nil)
    }
    
    func stopRecordingVideo() throws {
        try sessionManager.stopRecordingVideo(nil)
    }
    
    private func updatePreview(with session: AVCaptureSession) {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        DispatchQueue.main.async {
            self.previewLayer.accept(previewLayer)
        }
    }
    
    private func bindObservables() {
        if isObservablesBound {
            fatalError("Observables have already been bound!")
        }

        self.isObservablesBound = true
        videoConfiguration.videoQuality
            .debounce(.milliseconds(150), scheduler: workQueue)
            .subscribe(on: workQueue)
            .observe(on: MainScheduler.instance)
            .bind { [weak self] quality in
                guard let self = self else {
                    return
                }
                
                self.sessionManager.setVideoQuality(quality) { session in
                    self.updatePreview(with: session)
                }
                    
            }
            .disposed(by: bag)
        
        videoConfiguration.silentMode
            .debounce(.milliseconds(150), scheduler: workQueue)
            .subscribe(on: workQueue)
            .bind { [weak self] isEnabled in
                guard let self = self else { return }
                
                self.sessionManager.setSlientMode(isEnabled,
                                                  currentCamPosition: self.videoConfiguration.cameraPosition.value) { session in
                    self.updatePreview(with: session)
                }
            }
            .disposed(by: bag)

        videoConfiguration.cameraPosition
            .debounce(.milliseconds(150), scheduler: workQueue)
            .subscribe(on: workQueue)
            .bind { [weak self] position in
                guard let self = self else { return }
                
                self.sessionManager.setCameraPosition(position) { session in
                    self.updatePreview(with: session)
                }
            }
            .disposed(by: bag)
        
        if #available(iOS 16, *), self.sessionManager.session.isMultitaskingCameraAccessSupported {
            videoConfiguration.backgroundMode
                .debounce(.milliseconds(150), scheduler: workQueue)
                .subscribe(on: workQueue)
                .bind { [weak self] enabled in
                    guard let self = self else { return }
                    
                    self.sessionManager.setBackgroundMode(enabled) { session in
                        self.updatePreview(with: session)
                    }
                }
                .disposed(by: bag)
        }
    }
    
    init(_ sessionManager: SingleVideoSessionManager = SingleVideoSessionManager.shared,
         _ videoConfiguration: VideoSessionConfiguration = VideoSessionConfiguration.shared,
         _ videoAlbumFetcher: VideoAlbumFetcher = VideoAlbumFetcher.shared) {
        self.sessionManager = sessionManager
        self.videoConfiguration = videoConfiguration

        self.videoAlbumFethcher = videoAlbumFetcher
        self.thumbnailObserver = videoAlbumFetcher.getObserver()
            .map { thumbnails in
                thumbnails.last?.thumbnail
            }
        
        super.init()
        
        self.bindObservables()
        Task {
            try await self.sessionManager.setupSession()
        }
    }
}
