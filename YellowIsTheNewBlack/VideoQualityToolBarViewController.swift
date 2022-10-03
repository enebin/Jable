//
//  VideoQualityToolBarViewController.swift
//  YellowIsTheNewBlack
//
//  Created by Young Bin on 2022/10/03.
//

import UIKit

import Then
import SnapKit

class VideoQualityToolBarViewController: UIViewController {
    lazy var highButton = LabelButton().then {
        $0.setTitleLabel("고화질")
    }
    
    lazy var mediumButton = LabelButton().then {
        $0.setTitleLabel("중간화질")
    }

    lazy var lowButton = LabelButton().then {
        $0.setTitleLabel("낮은화질")
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
        
        view.addSubview(qualityTypeStackView)
        qualityTypeStackView.snp.makeConstraints { make in
            make.width.height.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        addButtons(lowButton)
        addButtons(mediumButton)
        addButtons(highButton)
    }
    
    private func addButtons(_ button: UIButton) {
        qualityTypeStackView.addArrangedSubview(button)
        button.snp.makeConstraints { make in
            make.width.height.equalTo(35)
            make.centerY.equalToSuperview()
        }
    }
}
