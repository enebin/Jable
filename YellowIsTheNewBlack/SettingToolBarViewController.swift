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
    
    let recorderConfig = RecorderConfiguration()
    
    // MARK: Child VCs
    lazy var settingTypeVC = SettingTypeViewController()
    lazy var videoQualityVC = VideoQualityToolBarViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubViewControllers()
        setLayout()
        bindButtons()
    }
    
    func addSubViewControllers() {
        addChild(settingTypeVC)
        settingTypeVC.didMove(toParent: self)
        
        addChild(videoQualityVC)
        videoQualityVC.didMove(toParent: self)
        
        children.forEach{ $0.view.isHidden = true }
    }
    
    func setLayout() {
        view.addSubview(settingTypeVC.view)
        settingTypeVC.view.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(50)
            make.center.equalToSuperview()
        }
        
        view.addSubview(videoQualityVC.view)
        videoQualityVC.view.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(50)
            make.center.equalToSuperview()
        }
        
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
                self.multiplexer(self.settingTypeVC)
            }
            .disposed(by: bag)
    }
    
    private func multiplexer(_ child: UIViewController?) {
        if let child = child {
            children.forEach { vc in
                if vc != child {
                    vc.view.isHidden = true
                }
            }
            
            child.view.isHidden = false
        } else {
            children.forEach { $0.view.isHidden = true }
            settingButton.isHidden = false
        }
    }
}

fileprivate enum Settings {
    case first
    case quality
    case mute
}
