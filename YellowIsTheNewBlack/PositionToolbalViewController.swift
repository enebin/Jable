//
//  PositionToolbalViewController.swift
//  YellowIsTheNewBlack
//
//  Created by Young Bin on 2022/10/08.
//

import UIKit

import Then
import SnapKit
import RxSwift
import RxCocoa

class PositionToolbalViewController: UIViewController, ToolbarItem {
    // MARK: - ToolbarItem
    typealias Action = () -> Void
    typealias SettingAction = (Setting) -> Void
    
    var backButtonAction: Action?
    func onBackButtonTapped(_ action: @escaping Action) {
        backButtonAction = action
    }
    
    var elementButtonAction: SettingAction?
    func onElementButtonTapped(_ action: @escaping SettingAction) {
        elementButtonAction = action
    }
    
    // MARK: - Lets and vars
    private let bag = DisposeBag()
    private(set) var recorderConfiguration: VideoSessionConfiguration
    
    init(configuration: VideoSessionConfiguration) {
        self.recorderConfiguration = configuration
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View components
    lazy var rearButton = LabelButton().then {
        $0.setTitleLabel("Rear")
    }
    
    lazy var frontButton = LabelButton().then {
        $0.setTitleLabel("Front")
    }
    
//    lazy var simultaneousButton = LabelButton().then {
//        $0.setTitleLabel("동시!(iOS 15~)")
//    }
    
    lazy var backButton = SystemImageButton().then {
        $0.setSystemImage(name: "chevron.left")
    }
    
    lazy var cameraPositionStackView = UIStackView().then {
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
        view.addSubview(cameraPositionStackView)
        cameraPositionStackView.snp.makeConstraints { make in
            make.height.width.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        cameraPositionStackView.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.height.equalTo(35)
            make.left.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        
        let childButtons = [rearButton, frontButton]
        childButtons.forEach({ addButton($0) })
    }
    
    private func addButton(_ button: UIButton) {
        cameraPositionStackView.addArrangedSubview(button)
        button.snp.makeConstraints { make in
            make.height.equalTo(35)
            make.centerY.equalToSuperview()
        }
    }
    
    private func bindButtons() {
        rearButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                
                self.recorderConfiguration.cameraPosition.accept(.back)
            }
            .disposed(by: bag)
        
        frontButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                self.recorderConfiguration.cameraPosition.accept(.front)
            }
            .disposed(by: bag)
        
        // 전후면 동시, 추후지원
//        simultaneousButton.rx.tap
//            .bind { [weak self] in
//                guard let self = self else { return }
//
//                return
//            }
//            .disposed(by: bag)
        
        
        backButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                
                self.backButtonAction?()
            }
            .disposed(by: bag)
    }
}
