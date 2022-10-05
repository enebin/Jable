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
    
    // MARK: Usable buttons
    lazy var settingButton = SystemImageButton().then {
        $0.setSystemImage(name: "gear")
    }
    
    lazy var backButton = SystemImageButton().then {
        $0.setSystemImage(name: "chevron.left")
    }
    
    lazy var qualityButton = LabelButton().then {
        $0.setTitleLabel("화질")
    }
    
    lazy var muteButton = LabelButton().then {
        $0.setTitleLabel("음소거")
    }
    
    // MARK: Child VCs
    let recorderConfig = RecorderConfiguration()
    lazy var videoQualityVC = VideoQualityToolBarViewController().then {
        $0.setViewCompletion {
            self.settingTypeStackView.isHidden = false
            print("@@@")
        }
        $0.view.isHidden = true
    }
    
    // MARK: Stack views
    lazy var settingTypeStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.backgroundColor = .clear
        $0.alignment = .center
        $0.distribution = .fillEqually
        
        $0.layoutMargins = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 60)
        $0.isLayoutMarginsRelativeArrangement = true

        $0.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
        bindButtons()
    }
    
    func addSubViewControllers() {
        addChild(videoQualityVC)
        videoQualityVC.didMove(toParent: self)
    }
    
    func setLayout() {
        // MARK: Setting type stack view
        view.addSubview(settingTypeStackView)
        settingTypeStackView.snp.makeConstraints { make in
            make.width.height.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        settingTypeStackView.addArrangedSubview(qualityButton)
        qualityButton.snp.makeConstraints { make in
            make.width.height.equalTo(35)
            make.centerY.equalToSuperview()
        }
        
        settingTypeStackView.addArrangedSubview(muteButton)
        muteButton.snp.makeConstraints { make in
            make.width.height.equalTo(35)
            make.centerY.equalToSuperview()
        }
        
        settingTypeStackView.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.width.height.equalTo(35)
            make.left.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        
        // MARK: Video quality stack view
        view.addSubview(videoQualityVC.view)
        videoQualityVC.view.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(settingTypeStackView)
            make.center.equalTo(settingTypeStackView)
        }
        
        // MARK: Mute stack view
        
        
        // MARK: Setting button
        view.addSubview(settingButton)
        settingButton.snp.makeConstraints { make in
            make.width.height.equalTo(35)
            make.center.equalToSuperview()
        }
    }
    
    func bindButtons() {
        settingButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                self.settingButton.isHidden = true
                self.settingTypeStackView.isHidden = false
            }
            .disposed(by: bag)
        
        backButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }

                self.settingButton.isHidden = false
                self.settingTypeStackView.isHidden = true
            }
            .disposed(by: bag)
        
        qualityButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                
                self.settingButton.isHidden = true
                self.settingTypeStackView.isHidden = true
                self.videoQualityVC.view.isHidden = false
            }
            .disposed(by: bag)
    }
    
    private func selectSetting(_ type: Settings) {
        
    }
}

fileprivate enum Settings {
    case first
    case quality(UIViewController)
    case mute(UIViewController)
    
    
}
