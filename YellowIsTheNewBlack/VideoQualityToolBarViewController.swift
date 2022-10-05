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

class VideoQualityToolBarViewController: UIViewController {
    typealias Action = () -> Void
    
    private var recorderConfiguration: VideoConfiguration? = nil
    private let bag = DisposeBag()
    
    var backButtonAction: Action?
    
    lazy var highButton = LabelButton().then {
        $0.setTitleLabel("고화질")
    }
    
    lazy var mediumButton = LabelButton().then {
        $0.setTitleLabel("중간화질")
    }

    lazy var lowButton = LabelButton().then {
        $0.setTitleLabel("낮은화질")
    }
    
    lazy var backButton = SystemImageButton().then {
        $0.setSystemImage(name: "chevron.left")
    }
    
    lazy var qualityTypeStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        
        $0.backgroundColor = .clear
        $0.alignment = .center
        
        $0.layoutMargins = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 60)
        $0.isLayoutMarginsRelativeArrangement = true
    }
    
    func setBackButtonAction(_ action: @escaping Action) {
        backButtonAction = action
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
        bindButtons()
    }
    
    private func setLayout() {
        let childButtons = [lowButton, mediumButton, highButton]
        
        view.addSubview(qualityTypeStackView)
        qualityTypeStackView.snp.makeConstraints { make in
            make.width.height.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        qualityTypeStackView.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.width.height.equalTo(35)
            make.left.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        
        childButtons.forEach({ addButton($0) })
    }
    
    private func addButton(_ button: UIButton) {
        qualityTypeStackView.addArrangedSubview(button)
        button.snp.makeConstraints { make in
            make.width.height.equalTo(35)
            make.centerY.equalToSuperview()
        }
    }
    
    private func bindButtons() {
        lowButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                
                self.recorderConfiguration?.videoQuality = .low
            }
            .disposed(by: bag)
        
        mediumButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                
                self.recorderConfiguration?.videoQuality = .medium
            }
            .disposed(by: bag)
        
        highButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                
                self.recorderConfiguration?.videoQuality = .high
            }
            .disposed(by: bag)
        
        backButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                
                self.view.isHidden = true
                self.parent?.view.isHidden = true
//                self.backButtonAction?()
            }
            .disposed(by: bag)
    }
}
