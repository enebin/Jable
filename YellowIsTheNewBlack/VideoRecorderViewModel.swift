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
    private let sessionManager: VideoSessionManager
    let videoConfiguration: RecorderConfiguration
    
    // vars and lets
    private var videoSession: AVCaptureSession?
    private var bag = DisposeBag()
    private var isObservablesBound = false
    
    // MARK: - Public methods and vars
    let previewLayer = PublishRelay<AVCaptureVideoPreviewLayer?>()
    
    @discardableResult
    func updateSession(_ quality: AVCaptureSession.Preset = .medium,
                       _ position: AVCaptureDevice.Position) async throws -> AVCaptureSession {
        let session = try await sessionManager.setupSession(quality: quality, position: position)
        videoSession = session
        
        return session
    }
    
    private func setupPreviewLayer(session: AVCaptureSession) -> AVCaptureVideoPreviewLayer {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        return previewLayer
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
    
    private func bindObservables() {
        if isObservablesBound {
            fatalError("Observables have already been bound!")
        }
        
        videoConfiguration.videoQuality
            .bind { [weak self] quality in
                guard let self = self else { return }
                self.isObservablesBound = true
                
                Task {
                    let position = self.videoConfiguration.cameraPosition.value
                    let session = try await self.updateSession(quality, position)
                    let previewLayer = self.setupPreviewLayer(session: session)
                    
                    self.previewLayer.accept(previewLayer)
                    self.startRunningCamera()
                }
            }
            .disposed(by: bag)
    }
    
    init(_ sessionManager: VideoSessionManager = VideoSessionManager.shared,
         _ videoConfiguration: RecorderConfiguration = RecorderConfiguration.shared) {
        self.sessionManager = sessionManager
        self.videoConfiguration = videoConfiguration
        
        super.init()
        
        self.bindObservables()
        
//        Task(priority: .userInitiated) {
//            print("Session go")
//
//            do {
//                let session = try await setupSession(.medium, .back)
//                print("Session done, \(session)")
//            }
//            catch VideoRecorderError.notConfigured {
//                fatalError("비디오 세션이 제대로 초기화되지 않았음")
//            }
//            catch let error {
//                print(error)
////                self.errorMessage = error.localizedDescription
////                self.present(self.alert, animated: true, completion: nil)
//            }
//
//            var DEBUG_runCamera = true
//            if DEBUG_runCamera {
//                startRunningCamera()
//            }
//        }
    }
}
