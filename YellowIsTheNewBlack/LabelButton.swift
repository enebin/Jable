//
//  BackButton.swift
//  YellowIsTheNewBlack
//
//  Created by Young Bin on 2022/10/03.
//

import UIKit

class LabelButton: UIButton {
    func setTitleLabel(_ text: String) {
        self.setTitle(text, for: .normal)
        self.setTitleColor(.white, for: .normal)
        self.setTitleColor(.gray, for: .highlighted)
        self.titleLabel?.font = UIFont(name: "Jalnan", size: 18)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
