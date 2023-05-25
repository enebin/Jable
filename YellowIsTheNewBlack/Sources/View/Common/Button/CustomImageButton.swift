//
//  CustomImageButton.swift
//  YellowIsTheNewBlack
//
//  Created by Young Bin on 2022/10/09.
//

import UIKit
import Then
import SnapKit

class CustomImageButton: RotatingButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setLayout()
    }
    
    func setCustomImage(_ image: UIImage) {
        self.setImage(image, for: .normal)
        self.imageView?.contentMode = .scaleAspectFit
    }
    
    private func setLayout() {
        self.layer.cornerRadius = 10
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 0.5
        
        self.layer.masksToBounds = true
        
        self.snp.makeConstraints { make in
            make.width.height.equalTo(70)
        }
    }
}
