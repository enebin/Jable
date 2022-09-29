//
//  VideoRecorderViewController.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/06/07.
//

import UIKit
import AVFoundation

import Then
import SnapKit
import RxCocoa
import RxSwift
import RxRelay

class VideoRecorderViewController: UIViewController {
    var DEBUG_runCamera = true
    
    // Dependencies
    let viewModel: VideoRecoderViewModel
    
    // Internal vars and const
    var errorMessage = "알 수 없는 오류"
    var isRecording = false
    let bag = DisposeBag()
    
    var previewLayerSize: PreviewLayerSize = .large
    var previewLayer: AVCaptureVideoPreviewLayer?


    // View components
    lazy var alert = UIAlertController(title: "오류", message: self.errorMessage,
                                       preferredStyle: UIAlertController.Style.alert).then {
        $0.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
    }
    
    lazy var recordButton = UIButton().then {
        $0.backgroundColor = .white
        $0.sizeToFit()
    }
    
    lazy var screenSizeButton = UIButton().then {
        $0.backgroundColor = .white
        $0.sizeToFit()
    }
    
    let stackView = VideoRecorderBottomStackView()
    
    // Life cycle related methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLayout()
        self.bindUIComponents()
        self.viewModel.bindObservables()
        
        Task {
            do {
                try await viewModel.setupSession(.medium, .back)
                self.previewLayer = viewModel.previewLayer
                self.previewLayer!.videoGravity = .resizeAspect
                
                setLayout()
            }
            catch VideoRecorderError.notConfigured {
                fatalError("비디오 세션이 제대로 초기화되지 않았음")
            }
            catch let error {
                self.errorMessage = error.localizedDescription
                self.present(self.alert, animated: true, completion: nil)
            }
            
            if DEBUG_runCamera {
                viewModel.startRunningCamera()
            }
        }
    }

    private func setLayout() {
        if let previewLayer = self.previewLayer {
            self.view.layer.addSublayer(previewLayer)
            previewLayer.bounds = self.previewLayerSize.bounds
            previewLayer.position = self.previewLayerSize.position
        }

        self.view.addSubview(recordButton)
        self.recordButton.snp.makeConstraints { make in
            make.height.width.equalTo(50)
            make.center.equalToSuperview()
        }
        
        self.view.addSubview(screenSizeButton)
        self.screenSizeButton.snp.makeConstraints { make in
            make.width.height.equalTo(100)
            make.left.top.equalToSuperview().inset(30)
        }
        
        self.view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(85)
            make.bottom.equalToSuperview()
        }
    }
    
    private func bindUIComponents() {
        self.recordButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                do {
                    if self.isRecording {
                        self.isRecording = false
                        try self.viewModel.stopRecordingVideo()
                    } else {
                        self.isRecording = true
                        try self.viewModel.startRecordingVideo()
                    }
                } catch let error {
                    self.errorMessage = error.localizedDescription
                    self.present(self.alert, animated: true)
                }
            }
            .disposed(by: bag)
        
        self.screenSizeButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                print("tapped")
                
                self.previewLayerSize = self.previewLayerSize.next()
                self.previewLayer?.bounds = self.previewLayerSize.bounds
                self.previewLayer?.position = self.previewLayerSize.position
                
                DispatchQueue.main.async {
                    self.hideViews()
                }
                

                self.view.layoutIfNeeded()
            }
            .disposed(by: bag)
        
//        self.viewModel.previewLayerObservable
//            .observe(on: MainScheduler.asyncInstance)
//            .subscribe(
//                onNext: { [weak self] newPreviewLayer in
//                    guard let self = self else { return }
//                    self.previewLayer = newPreviewLayer
//                })
//            .disposed(by: bag)
    }
    
    private func hideViews() {
        let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) {
            if self.stackView.isHidden {
                self.stackView.isHidden = false
                self.stackView.alpha = 1
            } else {
                self.stackView.alpha = 0
            }
        }

        if !self.stackView.isHidden {
            animator.addCompletion { _ in
                self.stackView.isHidden = true
            }
        }
        animator.startAnimation()
    }
    
    // Initializers
    init(viewModel: VideoRecoderViewModel = VideoRecoderViewModel()) {
        // Get common setting
        // Update dependencies
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension VideoRecorderViewController {
    enum PreviewLayerSize: Double, CaseIterable {
        // Define screen ratio
        case large = 1
        case medium = 0.5
        case small = 0.3
        
        var position: CGPoint {
            let screenSize = (UIScreen.main.bounds.width, UIScreen.main.bounds.height)
            
            switch self {
                // -30 is offset constant
            case .large:
                return CGPoint(x: screenSize.0/2, y: screenSize.1/2 - 30)   // Center point
            case .medium:
                return CGPoint(x: screenSize.0/4 * 3, y: screenSize.1/4 * 3 - 30)   // 3rd quarter of the screen
            case .small:
                return CGPoint(x: screenSize.0/8 * 7, y: screenSize.1/8 * 7 - 30)   // 7th over 8 of the screen
            }
        }
        
        var bounds: CGRect {
            let screenSize = (UIScreen.main.bounds.width, UIScreen.main.bounds.height)
            
            let layerSize = CGSize(width: screenSize.0 * self.rawValue, height: screenSize.1 * self.rawValue)
            return CGRect(origin: CGPoint(x: 0, y: 0), size: layerSize)
        }
        
        func next() -> PreviewLayerSize {
            let all = type(of: self).allCases
            if self == all.last! {
                return all.first!
            } else {
                let index = all.firstIndex(of: self)!
                return all[index + 1]
            }
        }
    }
}
