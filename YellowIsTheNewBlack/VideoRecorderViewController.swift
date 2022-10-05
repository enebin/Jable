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

@MainActor
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
    
    lazy var shutterButton = ShutterButton()
    lazy var settingButton = SettingButton()
    lazy var spacer = Spacer()
    lazy var settingVC = SettingToolBarViewController()

    lazy var screenSizeButton = UIButton().then {
        $0.backgroundColor = .white
        $0.sizeToFit()
    }
    
    // Life cycle related methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.setChildViewControllers()
        self.setLayout()
        self.bindUIComponents()
        
        Task(priority: .userInitiated) {
            do {
                try await viewModel.setupSession(.medium, .back)
                
                DispatchQueue.main.async {
                    self.setCameraPreviewLayer(self.viewModel.previewLayer)
                }
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
    
    private func setCameraPreviewLayer(_ layer: AVCaptureVideoPreviewLayer?) {
        guard let _layer = layer else {
            return
        }
        
        previewLayer = _layer
        
        self.view.layer.addSublayer(previewLayer!)
        previewLayer!.videoGravity = .resizeAspect
        previewLayer!.bounds = self.previewLayerSize.bounds
        previewLayer!.position = self.previewLayerSize.position
        
        setLayout()
    }
    
    private func setChildViewControllers() {
        self.addChild(settingVC)
        settingVC.didMove(toParent: self)
    }

    private func setLayout() {
        self.view.addSubview(shutterButton)
        shutterButton.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.bottom.equalToSuperview().inset(50)
            make.centerX.equalToSuperview()
        }
        
        self.view.addSubview(settingVC.view)
        settingVC.view.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func bindUIComponents() {
        shutterButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                HapticManager.shared.generate()
                
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
        
        screenSizeButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                self.previewLayerSize = self.previewLayerSize.next()
                self.setCameraPreviewLayer(self.previewLayer)
                
                self.view.layoutIfNeeded()
            }
            .disposed(by: bag)
        
        settingButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                
                let videoConfiguration = self.viewModel.videoConfiguration
                let settingViewController = SettingViewController(videoConfig: videoConfiguration)
                
                self.present(settingViewController, animated: true)
            }
            .disposed(by: bag)
    }
    
    // Initializers
    init(viewModel: VideoRecoderViewModel = VideoRecoderViewModel()) {
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
                return CGPoint(x: screenSize.0/2, y: screenSize.1/2)   // Center point
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
