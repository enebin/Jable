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

class SettingTypeViewController: UIViewController {
    typealias Action = () -> Void
    typealias SettingAction = (Setting) -> Void
    
    private let bag = DisposeBag()
    
    lazy var backButton = SystemImageButton().then {
        $0.setSystemImage(name: "chevron.left")
    }
    
    lazy var qualityButton = LabelButton().then {
        $0.setTitleLabel("화질")
    }
    
    lazy var muteButton = LabelButton().then {
        $0.setTitleLabel("소리 녹음")
    }
        
    // MARK: Stack views
    lazy var settingTypeStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.backgroundColor = .clear
        $0.alignment = .center
        $0.distribution = .fillEqually
        
        $0.layoutMargins = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 60)
        $0.isLayoutMarginsRelativeArrangement = true
    }
    
    var backButtonAction: Action?
    func onBackButtonTapped(_ action: @escaping Action) {
        backButtonAction = action
    }
    
    var elementButtonAction: SettingAction?
    func onElementButtonTapped(_ action: @escaping SettingAction) {
        elementButtonAction = action
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
        bindButtons()
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
    }
    
    func bindButtons() {
        backButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                
                self.backButtonAction?()
            }
            .disposed(by: bag)
        
        qualityButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                
                self.elementButtonAction?(.quality)
            }
            .disposed(by: bag)
        
        muteButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                
                print("녹음 기능 끄기")
            }
            .disposed(by: bag)
    }
}
