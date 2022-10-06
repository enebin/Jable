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
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
