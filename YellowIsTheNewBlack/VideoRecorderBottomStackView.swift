//
//  VideoRecorderBottomStackView.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/09/29.
//

import UIKit
import Then
import SnapKit
import RxCocoa

class VideoRecorderBottomStackView: UIStackView {
    lazy var settingButton = UIButton().then {
        let btnImage = UIImage(systemName: "gear")?
            .withTintColor(.yellow, renderingMode: .alwaysOriginal)
        
        $0.setImage(btnImage, for: .normal)
        $0.contentVerticalAlignment = .fill
        $0.contentHorizontalAlignment = .fill
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setLayout()
        setSubViewsLayout()
        bindUIComponents()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLayout() {
        self.axis = .horizontal
        self.alignment = .center
        self.distribution = .equalSpacing
        self.backgroundColor = .white.withAlphaComponent(0.3)
        self.spacing = 8
    }
    
    private func setSubViewsLayout() {
        self.addSubview(settingButton)
        settingButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(35)
        }
    }
    
    private func bindUIComponents() {
        settingButton.rx.tap
            .bind { [weak self] in
                
            }
    }
}
