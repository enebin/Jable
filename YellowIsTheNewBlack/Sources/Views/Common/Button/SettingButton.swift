//
//  SettingButton.swift
//  YellowIsTheNewBlack
//
//  Created by Young Bin on 2022/10/03.
//

import UIKit
import SnapKit
import Then

class SettingButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()

        setLayout()
    }

    private func setLayout() {
        let buttonImage = UIImage(systemName: "gear")!
            .withTintColor(.white, renderingMode: .alwaysOriginal)

        self.setImage(buttonImage, for: .normal)
        self.contentVerticalAlignment = .fill
        self.contentHorizontalAlignment = .fill
    }
}
