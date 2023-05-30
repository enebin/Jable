//
//  VideoQualityToolBarViewController.swift
//  YellowIsTheNewBlack
//
//  Created by Young Bin on 2022/10/03.
//

import UIKit

import Then
import SnapKit
import RxSwift
import RxCocoa

class VideoQualityToolBarViewController: UIViewController, ToolbarItem {
    typealias Action = () -> Void
    typealias SettingAction = (Setting) -> Void
    
    private let bag = DisposeBag()
    private(set) var recorderConfiguration: VideoSessionConfiguration
    
    init(configuration: VideoSessionConfiguration) {
        self.recorderConfiguration = configuration
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var childButtons = [UIButton]()
    
    lazy var highButton = LabelButton().then {
        $0.setTitleLabel("HIGH".localized)
    }
    
    lazy var mediumButton = LabelButton().then {
        $0.setTitleLabel("MID".localized)
    }

    lazy var lowButton = LabelButton().then {
        $0.setTitleLabel("LOW".localized)
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
    
    
    lazy var qualityTypeStackView = UIStackView().then {
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
        bindObservables()
    }
    
    
    private func setLayout() {
        self.childButtons = [lowButton, mediumButton, highButton]
        
        view.addSubview(qualityTypeStackView)
        qualityTypeStackView.snp.makeConstraints { make in
            make.height.width.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        qualityTypeStackView.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.height.equalTo(35)
            make.left.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        
        childButtons.forEach({ addButton($0) })
    }
    
    private func addButton(_ button: UIButton) {
        qualityTypeStackView.addArrangedSubview(button)
        button.snp.makeConstraints { make in
            make.height.equalTo(35)
            make.centerY.equalToSuperview()
        }
    }
    
    private func bindButtons() {
        lowButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                
                self.recorderConfiguration.videoQuality.accept(.low)
                self.view.layoutIfNeeded()
            }
            .disposed(by: bag)
        
        mediumButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                
                self.recorderConfiguration.videoQuality.accept(.medium)
                self.view.layoutIfNeeded()
            }
            .disposed(by: bag)
        
        highButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                
                self.recorderConfiguration.videoQuality.accept(.high)
                self.view.layoutIfNeeded()
            }
            .disposed(by: bag)
        
        backButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                
                self.backButtonAction?()
            }
            .disposed(by: bag)
    }
    
    private func bindObservables() {
        recorderConfiguration.videoQuality
            .bind { [weak self] quality in
                guard let self = self else { return }
                
                self.childButtons.forEach {
                    $0.alpha = 0.3
                }
                
                switch quality {
                case .low:
                    self.lowButton.alpha = 1
                case .medium:
                    self.mediumButton.alpha = 1
                case .high:
                    self.highButton.alpha = 1
                default:
                    break
                }
                
                self.view.setNeedsLayout()
            }
            .disposed(by: bag)
    }
}
