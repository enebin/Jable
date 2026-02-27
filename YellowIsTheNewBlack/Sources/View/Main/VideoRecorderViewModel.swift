//
//  CameraViewController.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/06/07.
//

import AVFoundation
import UIKit
import Photos

import RxSwift
import RxRelay

import Combine

import Aespa

/// 카메라세션
class VideoRecoderViewModel {
    typealias StatusRelay = ReplayRelay<Error>
    typealias VideoFileResult = Result<VideoFile, Error>
    
    // Dependencies
    let videoConfiguration: VideoSessionConfiguration
    private let aespaSession: AespaSession
    
    private(set) var aespaThumbnailPublisher: AnyPublisher<UIImage, Never>
    private(set) var aespaVideoFilePublisher: AnyPublisher<VideoFileResult, Never> // TODO: Handle it
    private(set) var aespaPreviewPublisher: AnyPublisher<AVCaptureVideoPreviewLayer, Never>
    
    // MARK: Private propertieds
    private var bag = DisposeBag()
    private var subsriptions = Set<AnyCancellable>()
    private var isObservablesBound = false
    
    private let workQueue = SerialDispatchQueueScheduler(qos: .userInitiated)
        
    // MARK: Public properties(outputs)
    private let statusRelay = ReplayRelay<Error>.create(bufferSize: 1)
    private(set) var statusObservable: Observable<Error>
    
    private var previousZoomFactor: CGFloat = 1.0
    
    init(
        _ videoConfiguration: VideoSessionConfiguration = VideoSessionConfiguration()
    ) {
        self.videoConfiguration = videoConfiguration
        self.statusObservable = statusRelay.asObservable()
        
        let aespaOption = AespaOption(albumName: "Jable")
        aespaSession = Aespa.session(with: aespaOption)
        
//        aespaSession = AespaSession(option: aespaOption)
        
//        aespaVideoFilePublisher = aespaSession.videoFileIOStatusPublisher
//        aespaPreviewPublisher = aespaSession.previewLayerPublisher
//        aespaThumbnailPublisher = aespaSession.videoFileIOStatusPublisher.mapThumbnail()
        
        aespaVideoFilePublisher = aespaSession.videoFilePublisher
        aespaThumbnailPublisher = aespaSession.videoFilePublisher.mapThumbnail()
        aespaPreviewPublisher = aespaSession.previewLayerPublisher
        
        Task(priority: .background) {
//            if case .failure(let error) = await self.aespaSession.configure() {
//                self.statusRelay.accept(error)
//            }
            
            do {
                try await Aespa.configure()
            } catch let error {
                self.statusRelay.accept(error)
            }
            
            bindObservables()
        }
    }
    
    // MARK: - Public methods
    func startRecordingVideo() throws {
        try aespaSession.startRecording()
    }
    
    func stopRecordingVideo() throws {
        try aespaSession.stopRecording()
    }
    
    func pauseRecordingVideo() throws {
        // TODO: tbd
    }
    
    private func bindObservables() {
        if isObservablesBound {
            fatalError("Observables have already been bound!")
        }
        
        isObservablesBound = true
        aespaVideoFilePublisher
            .receive(on: DispatchQueue.global(qos: .utility))
            .sink { [weak self] status in
                guard let self else { return }
                
                if case .failure(let error) = status {
                    self.statusRelay.accept(error)
                    try? self.stopRecordingVideo()
                }
            }
            .store(in: &subsriptions)
        
        videoConfiguration.videoQuality
            .debounce(.milliseconds(150), scheduler: workQueue)
            .subscribe(on: workQueue)
            .observe(on: MainScheduler.instance)
            .bind { [weak self] quality in
                guard let self = self else { return }
                
                do {
                    try aespaSession.setQuality(to: quality)
                } catch let error {
                    self.statusRelay.accept(error)
                }
            }
            .disposed(by: bag)
        
        videoConfiguration.silentMode
            .debounce(.milliseconds(150), scheduler: workQueue)
            .subscribe(on: workQueue)
            .bind { [weak self] isEnabled in
                guard let self = self else { return }
                
                do {
                    if isEnabled {
                        try aespaSession.mute()
                    } else {
                        try aespaSession.unmute()
                    }
                } catch let error {
                    self.statusRelay.accept(error)
                }
            }
            .disposed(by: bag)
        
        videoConfiguration.cameraPosition
            .debounce(.milliseconds(150), scheduler: workQueue)
            .subscribe(on: workQueue)
            .bind { [weak self] position in
                guard let self = self else { return }
                
                do {
                    try aespaSession.setPosition(to: position)
                } catch let error {
                    self.statusRelay.accept(error)
                }
            }
            .disposed(by: bag)
    }
    
    @objc func setZoomFactorFromPinchGesture(_ sender: UIPinchGestureRecognizer) {
        let videoZoomFactor = sender.scale * previousZoomFactor
        let minZoomFactor = 1.0
        
        guard
            let maxZoomFactor = aespaSession.maxZoomFactor
        else {
            return
        }
        
        switch sender.state {
        case .ended:
            previousZoomFactor = videoZoomFactor >= 1 ? videoZoomFactor : 1
        case .changed:
            if (videoZoomFactor <= maxZoomFactor) {
                let newZoomFactor = max(minZoomFactor, min(videoZoomFactor, maxZoomFactor))
                aespaSession.zoom(factor: newZoomFactor)
            }
        default:
            break
        }
    }
}

fileprivate extension AnyPublisher where Output == Result<VideoFile, Error> {
    func mapThumbnail() -> AnyPublisher<UIImage, Failure> {
        self.compactMap { result in
            if case .success(let file) = result {
                return file.thumbnail
            } else {
                return nil
            }
        }.eraseToAnyPublisher()
    }
}
