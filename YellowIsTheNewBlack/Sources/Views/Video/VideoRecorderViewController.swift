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
    
    lazy var previewContainerView = UIView()
    lazy var previewOverlayContentView = UIView()
    
    lazy var shutterButton = ShutterButton()
    lazy var spacer = UIView.spacer
    lazy var settingVC = SettingToolBarViewController(configuration: viewModel.videoConfiguration)
    lazy var elapsedTimeVC = TimerViewController()

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
        bindNotificationCenter()
        
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

        self.view.addSubview(previewContainerView)
        previewContainerView.layer.addSublayer(preview!)
        previewContainerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(300)
        }
        
        preview!.bounds = self.previewLayerSize.sizeRect
        preview!.frame = self.previewLayerSize.sizeRect
        preview!.videoGravity = .resizeAspectFill
        preview!.cornerRadius = 20
        
        previewContainerView.isHidden = viewModel.videoConfiguration.stealthMode.value
        
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
        
        self.view.addSubview(previewOverlayContentView)
        previewOverlayContentView.snp.makeConstraints { make in
            make.top.equalTo(settingVC.view.snp.bottom)
            make.width.equalToSuperview()
            make.bottom.equalTo(shutterButton.snp.top)
        }
        
        // Position will be handled by elapsedTimePostionHandler
        previewOverlayContentView.addSubview(elapsedTimeVC.view)
        elapsedTimeVC.view.isHidden = true
    }
    
    private func bindButtons() {
        shutterButton.rx.tap
            .observe(on: MainScheduler.instance)
            .bind { [weak self] in
                guard let self = self else { return }

                do {
                    if self.isRecording {
                        try self.stopRecording()
                    } else {
                        try self.startRecording()
                    }
                } catch let error {
                    self.commonErrorHandler(error)
                }
            }
            .disposed(by: bag)
        
        thumbnailButton.rx.tap
            .observe(on: MainScheduler.instance)
            .bind { [weak self] in
                guard let self = self else { return }
                print("Tapped")
                HapticManager.shared.generate(type: .normal)
                
                let albumVC = GalleryViewController()
                self.present(albumVC, animated: true)
            }
            .disposed(by: bag)
    }

    private func bindObservables() {
        viewModel.previewLayerRelay.asObservable()
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
                self.previewContainerView.isHidden = newValue
                self.view.layoutIfNeeded()
            }
            .disposed(by: bag)
        
        viewModel.thumbnailObserver
            .observe(on: MainScheduler.instance)
            .compactMap{ $0 }
            .bind(to: thumbnailButton.rx.image(for: .normal))
            .disposed(by: bag)
        
        viewModel.statusObservable
            .observe(on: MainScheduler.instance)
            .bind { [weak self] error in
                guard let self = self else { return }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.commonErrorHandler(error)
                }
            }
            .disposed(by: bag)
    }
    
    private func bindNotificationCenter() {
        // Detect orientation change
        NotificationCenter.default.addObserver(
            self, selector: #selector(elapsedTimePostionHandler), name: UIDevice.orientationDidChangeNotification, object: nil
        )
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

// MARK: Tools
private extension VideoRecorderViewController {
    func startRecording() throws {
        HapticManager.shared.generate(type: .start)
        
        self.isRecording = true
        self.shutterButton.isRecording = true
        self.elapsedTimeVC.view.isHidden = false

        try self.viewModel.startRecordingVideo()
        
        self.view.layoutIfNeeded()
    }
    
    func stopRecording() throws {
        HapticManager.shared.generate(type: .end)
        
        self.isRecording = false
        self.shutterButton.isRecording = false
        self.elapsedTimeVC.view.isHidden = true

        try self.viewModel.stopRecordingVideo()
        
        self.view.layoutIfNeeded()
    }
    
    // TODO: Recording paused
    func pauseRecofding() throws {
         try self.viewModel.pauseRecordingVideo()
        
        // TODO: 다시 시작할 건지 물어보는 얼러트 추가
        
        self.view.layoutIfNeeded()
    }
}

// MARK: Handler
extension VideoRecorderViewController {
    private func commonErrorHandler(_ error: Error) {
        let alertController: UIAlertController
        // 세션 인터럽트(백그라운드 등) 시
        // Handle the specific AVFoundationErrorDomain Code=-11818 error
        if
            case let error = error as NSError,
            error.domain == AVFoundationErrorDomain,
            error.code == -11818
        {
            alertController = handleSessionSuspendedError()
        } else if
            let error = error as? VideoRecorderError,
            case .notConfigured = error
        {
            alertController = handleErrorWithCameraPermission(error)
        } else {
            alertController = UIAlertController(
                title: "오류",
                message: error.localizedDescription,
                preferredStyle: UIAlertController.Style.alert
            ).then {
                $0.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default,handler: nil))
            }
            
        }
        
        self.present(alertController, animated: true)
        try? self.stopRecording()
    }
    
    private func handleErrorWithCameraPermission(_ error: Error) -> UIAlertController {
        return UIAlertController(
            title: "녹화할 수 없습니다",
            message: error.localizedDescription,
            preferredStyle: UIAlertController.Style.alert
        ).then {
            $0.addAction(UIAlertAction(
                title: "Ok", style: .default, handler: nil)
            )
            
            $0.addAction(UIAlertAction(
                title: "Setting", style: .cancel, handler: { [weak self] _ in
                    self?.settingOpener()
                })
            )
        }
    }
    
    private func handleSessionSuspendedError() -> UIAlertController {
        //        print("AVFoundationErrorDomain Code=-11818 감지: 비디오 리코딩 세션 인터럽트를 의미함")
        return UIAlertController(
            title: "녹화가 중지되었습니다",
            message: "촬영한 비디오는 앨범에 저장되었습니다",
            preferredStyle: UIAlertController.Style.alert
        ).then {
            $0.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default,handler: nil))
        }
    }
    
    @objc private func elapsedTimePostionHandler() {
        guard !isRecording else { return }
        
        let orientation: UIDeviceOrientation = UIDevice.current.orientation
        var rotationAngle: CGFloat = 0
        
        // MARK: Super view = previewOverlayContentView
        elapsedTimeVC.view.snp.remakeConstraints { make in
            switch (orientation) {
            case .portrait: // top left
                rotationAngle = 0
                
                make.top.equalToSuperview()
                make.left.equalToSuperview()
            case .landscapeRight: // top right
                rotationAngle = -CGFloat.pi / 2
                
                make.centerY.equalToSuperview()
                make.left.equalToSuperview().offset(-elapsedTimeVC.view.frame.width / 3)
            case .landscapeLeft: // bottom left
                rotationAngle = CGFloat.pi / 2
                
                make.centerY.equalToSuperview()
                make.right.equalToSuperview().offset(elapsedTimeVC.view.frame.width / 3)
            case .portraitUpsideDown: // bottom right
                rotationAngle = CGFloat.pi
                
                make.bottom.equalToSuperview()
                make.right.equalToSuperview()
            default:
                rotationAngle = 0
            }
        }
        
        elapsedTimeVC.view.transform = CGAffineTransform(rotationAngle: rotationAngle)
        view.layoutIfNeeded()
    }
    
    private func settingOpener() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
        }
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
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return true
    }
}
