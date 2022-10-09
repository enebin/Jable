//
//  MuteToolBarViewController.swift
//  YellowIsTheNewBlack
//
//  Created by Young Bin on 2022/10/08.
//

import UIKit

import Then
import SnapKit
import RxSwift
import RxCocoa

class MuteToolBarViewController: UIViewController {
    typealias Action = () -> Void
    typealias SettingAction = (Setting) -> Void
    
    private let bag = DisposeBag()
    private(set) var recorderConfiguration: VideoConfiguration
    
    init(configuration: some VideoConfiguration) {
        self.recorderConfiguration = configuration
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var muteButton = LabelButton().then {
        $0.setTitleLabel("음소거")
    }
    
    lazy var unmuteButton = LabelButton().then {
        $0.setTitleLabel("음소거 해제")
    }
    
    lazy var backButton = SystemImageButton().then {
        $0.setSystemImage(name: "chevron.left")
    }
    
    var backButtonAction: Action?
    func onBackButtonTapped(_ action: @escaping Action) {
        backButtonAction = action
    }
    
    var elementButtonAction: SettingAction?
    func onElementButtonTapped(_ action: @escaping SettingAction) {
        elementButtonAction = action
    }
    
    
    lazy var muteTypeStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        
        $0.backgroundColor = .clear
        $0.alignment = .center
        
        $0.layoutMargins = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 60)
        $0.isLayoutMarginsRelativeArrangement = true
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
        bindButtons()
    }
    
    
    private func setLayout() {
        let childButtons = [muteButton, unmuteButton]
        
        view.addSubview(muteTypeStackView)
        muteTypeStackView.snp.makeConstraints { make in
            make.height.width.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        muteTypeStackView.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.height.equalTo(35)
            make.left.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        
        childButtons.forEach({ addButton($0) })
    }
    
    private func addButton(_ button: UIButton) {
        muteTypeStackView.addArrangedSubview(button)
        button.snp.makeConstraints { make in
            make.height.equalTo(35)
            make.centerY.equalToSuperview()
        }
    }
    
    private func bindButtons() {
        muteButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                
                self.recorderConfiguration.silentMode = true
            }
            .disposed(by: bag)
        
        unmuteButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                
                self.recorderConfiguration.silentMode = false
            }
            .disposed(by: bag)
        
        backButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                
                self.backButtonAction?()
            }
            .disposed(by: bag)
    }
}
