//
//  BackButton.swift
//  YellowIsTheNewBlack
//
//  Created by Young Bin on 2022/10/03.
//

import UIKit

class BackButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        setLayout()
    }

    private func setLayout() {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .medium, scale: .large)
        let buttonImage = UIImage(systemName: "chevron.left", withConfiguration: imageConfig)!
            .withTintColor(.white, renderingMode: .alwaysOriginal)
        self.setImage(buttonImage, for: .normal)
        
        self.imageView?.contentMode = .scaleAspectFit
    }
}
