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
    // Dependencies
    let viewModel: VideoRecoderViewModel

    // MARK: Internal vars and const
    var errorMessage = "알 수 없는 오류"
    var isRecording = false
    let bag = DisposeBag()
    
    var previewLayerSize: PreviewLayerSize = .large
    var preview: AVCaptureVideoPreviewLayer?
    
    // MARK: View components
    lazy var recordButton = UIButton().then {
        $0.backgroundColor = .white
        $0.sizeToFit()
    }
    
    lazy var thumbnailButton = CustomImageButton().then {
        let image = UIImage()
        $0.setCustomImage(image)
        $0.imageView?.contentMode = .scaleAspectFill
    }
    
    lazy var previewUIView = UIView()
    
    @objc func printt() {
        print("SS")
    }
    
    lazy var shutterButton = ShutterButton()
    lazy var spacer = UIView.spacer
    lazy var settingVC = SettingToolBarViewController(configuration: viewModel.videoConfiguration)

    lazy var screenSizeButton = UIButton().then {
        $0.backgroundColor = .white
        $0.sizeToFit()
    }
    
    // MARK: Life cycle related methods
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setChildViewControllers()
        setLayout()
        bindButtons()
        bindObservables()
        
        let pinchRecognizer = UIPinchGestureRecognizer(target: viewModel,
                                                       action: #selector(viewModel.setZoomFactorFromPinchGesture(_:)))
        view.addGestureRecognizer(pinchRecognizer)
    }
    
    private func setCameraPreviewLayer(_ layer: AVCaptureVideoPreviewLayer?) {
        guard let _layer = layer else {
            return
        }

        if preview != nil {
            preview?.removeFromSuperlayer()
        }
        preview = _layer

        self.view.addSubview(previewUIView)
        previewUIView.layer.addSublayer(preview!)
        previewUIView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(300)
        }
        
        preview!.bounds = self.previewLayerSize.sizeRect
        preview!.frame = self.previewLayerSize.sizeRect
        preview!.videoGravity = .resizeAspectFill
        preview!.cornerRadius = 20
        
        setLayout()
    }
    
    private func setChildViewControllers() {
        self.addChild(settingVC)
        settingVC.didMove(toParent: self)
    }

    private func setLayout() {
        self.view.addSubview(shutterButton)
        shutterButton.snp.makeConstraints { make in
            make.width.height.equalTo(65)
            make.bottom.equalToSuperview().inset(50)
            make.centerX.equalToSuperview()
        }
        
        self.view.addSubview(thumbnailButton)
        thumbnailButton.snp.makeConstraints { make in
            make.centerY.equalTo(shutterButton.snp.centerY)
            make.left.equalToSuperview().inset(10)
        }
        
        self.view.addSubview(settingVC.view)
        settingVC.view.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func bindButtons() {
        shutterButton.rx.tap
            .observe(on: MainScheduler.instance)
            .bind { [weak self] in
                guard let self = self else { return }

                do {
                    if self.isRecording {
                        HapticManager.shared.generate(type: .end)

                        self.isRecording = false
                        self.shutterButton.isRecording = false
                        try self.viewModel.stopRecordingVideo()
                        
                        self.view.layoutIfNeeded()
                    } else {
                        HapticManager.shared.generate(type: .start)
                        
                        self.isRecording = true
                        self.shutterButton.isRecording = true
                        try self.viewModel.startRecordingVideo()
                        
                        self.view.layoutIfNeeded()
                    }
                } catch let error {
                    self.errorHandler(error)
                }
            }
            .disposed(by: bag)
        
        thumbnailButton.rx.tap
            .observe(on: MainScheduler.instance)
            .bind { [weak self] in
                guard let self = self else { return }
                HapticManager.shared.generate(type: .normal)
                
                let albumVC = GalleryViewController()
                self.present(albumVC, animated: true)
            }
            .disposed(by: bag)
        
//        screenSizeButton.rx.tap
//            .observe(on: MainScheduler.instance)
//            .bind { [weak self] in
//                guard let self = self else { return }
//                self.previewLayerSize = self.previewLayerSize.next()
//                self.setCameraPreviewLayer(self.preview)
//
//                self.view.layoutIfNeeded()
//            }
//            .disposed(by: bag)
    }

    private func bindObservables() {
        viewModel.previewLayer.asObservable()
            .observe(on: MainScheduler.instance)
            .bind { [weak self] newLayer in
                guard let self = self else { return }
                
                self.setCameraPreviewLayer(newLayer)
                self.view.layoutIfNeeded()
            }
            .disposed(by: bag)
        
        viewModel.videoConfiguration.stealthMode
            .observe(on: MainScheduler.instance)
            .bind { [weak self] newValue in
                guard let self = self else { return }
                self.preview?.isHidden = newValue
                self.view.layoutIfNeeded()
            }
            .disposed(by: bag)
        
        viewModel.thumbnailObserver
            .observe(on: MainScheduler.instance)
            .bind(to: thumbnailButton.rx.image(for: .normal))
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
    private func errorHandler(_ error: Error) {
        let alert = UIAlertController(title: "오류", message: error.localizedDescription,
                                           preferredStyle: UIAlertController.Style.alert).then {
            $0.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        }
        
        self.present(alert, animated: true)
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
        
        var sizeRect: CGRect {
            let screenSize = (UIScreen.main.bounds.width, UIScreen.main.bounds.height * 0.75)
            
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

extension VideoRecorderViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
