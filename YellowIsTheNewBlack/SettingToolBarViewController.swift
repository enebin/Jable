//
//  SettingToolBarViewController.swift
//  YellowIsTheNewBlack
//
//  Created by Young Bin on 2022/10/03.
//

import UIKit

import SnapKit
import Then
import RxCocoa
import RxSwift

class SettingToolBarViewController: UIViewController {
    private let bag = DisposeBag()
    private(set) var recorderConfiguration: VideoSessionConfiguration
    
    init(configuration: VideoSessionConfiguration) {
        self.recorderConfiguration = configuration
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View stack
    private var viewStack = [UIView]() {
        didSet {
            oldValue.last?.isHidden = true
            viewStack.last?.isHidden = false
        }
    }
    
    // MARK: - Usable buttons
    lazy var toolBarStack = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
    }
    
    lazy var settingButton = SystemImageButton().then {
        $0.setSystemImage(name: "gear")
    }
    
    lazy var screenShowButton = SystemImageButton().then {
        $0.setSystemImage(name: "eye")
    }
    
    lazy var screenHiddenButton = SystemImageButton().then {
        $0.setSystemImage(name: "eye.slash")
    }

    // MARK: Child VCs
    lazy var settingTypeVC = SettingTypeViewController().then { [weak self] in
        guard let self = self else { return }
        
        $0.onBackButtonTapped { self.popView() }
        $0.onElementButtonTapped { setting in self.pushView(by: setting) }
    }
    
    lazy var videoQualityVC = VideoQualityToolBarViewController(configuration: recorderConfiguration)
        .then { [weak self] in
            guard let self = self else { return }
            
            $0.onBackButtonTapped { self.popView() }
            $0.onElementButtonTapped { setting in self.pushView(by: setting) }
        }
    
    lazy var muteTypeVC = MuteToolBarViewController(configuration: recorderConfiguration)
        .then { [weak self] in
            guard let self = self else { return }
            
            $0.onBackButtonTapped { self.popView() }
            $0.onElementButtonTapped { setting in self.pushView(by: setting) }
        }
    
    lazy var positionVC = PositionToolbalViewController(configuration: recorderConfiguration)
        .then { [weak self] in
            guard let self = self else { return }
            
            $0.onBackButtonTapped { self.popView() }
            $0.onElementButtonTapped { setting in self.pushView(by: setting) }
        }
    
    // MARK: -
    private var childVCs = [UIViewController]()
    override func viewDidLoad() {
        super.viewDidLoad()
        childVCs = [settingTypeVC, videoQualityVC, muteTypeVC, positionVC]
        
        addSubViewControllers(childVCs)
        setLayout()
        bindButtons()
        
        pushView(toolBarStack)
    }
    
    func addSubViewControllers(_ viewControllers: [UIViewController]) {
        viewControllers.forEach {
            addChild($0)
            $0.didMove(toParent: self)
            $0.view.isHidden = true
        }
    }
    
    func setLayout() {
        view.addSubview(settingTypeVC.view)
        settingTypeVC.view.snp.makeConstraints { make in
            make.width.equalTo(view.snp.width)
            make.height.equalTo(50)
            make.center.equalToSuperview()
        }
        
        view.addSubview(videoQualityVC.view)
        videoQualityVC.view.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(50)
            make.center.equalToSuperview()
        }
        
        view.addSubview(muteTypeVC.view)
        muteTypeVC.view.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(50)
            make.center.equalToSuperview()
        }
        
        view.addSubview(positionVC.view)
        positionVC.view.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(50)
            make.center.equalToSuperview()
        }
        
        // MARK: - Setting button
        view.addSubview(toolBarStack)
        toolBarStack.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalToSuperview()
        }
        
        toolBarStack.addArrangedSubview(screenShowButton)
        screenShowButton.snp.makeConstraints { make in
            make.width.height.equalTo(35)
        }
        
        toolBarStack.addArrangedSubview(settingButton)
        settingButton.snp.makeConstraints { make in
            make.width.height.equalTo(35)
        }
        
        toolBarStack.addArrangedSubview(UIView.spacer)
    }
    
    func bindButtons() {
        settingButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                                
                self.pushView(self.settingTypeVC.view)
            }
            .disposed(by: bag)
        
        screenShowButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                                
                self.recorderConfiguration.stealthMode.accept(true)
            }
            .disposed(by: bag)
    }
    
    func pushView(by settingType: Setting) {
        switch settingType {
        case .quality:
            pushView(videoQualityVC.view)
        case .mute:
            pushView(muteTypeVC.view)
        case .position:
            pushView(positionVC.view)
        }
    }
    
    private func pushView(_ view: UIView) {
        viewStack.append(view)
    }
    
    private func popView() {
        if viewStack.count > 1 {
            viewStack = viewStack.dropLast(1)
        }
    }
}

protocol SettingStack: UIViewController {
    var backButton: UIButton { get set }
    func onBackButtonTapped(_ action: @escaping () -> Void)

    var elementButton: UIButton { get set }
    func onElementButtonTapped(_ action: @escaping (Setting) -> Void)
}

enum Setting {
    case quality
    case mute
    case position
}
