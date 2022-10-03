//
//  BackButton.swift
//  YellowIsTheNewBlack
//
//  Created by Young Bin on 2022/10/03.
//

import UIKit

class SystemImageButton: UIButton {
    private var systemName: String = "xmark"
    
    func setSystemImage(name: String) {
        systemName = name
        
        guard let image = UIImage(systemName: name) else {
            return
        }
        
        self.imageView?.image = image
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setLayout()
    }

    private func setLayout() {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .medium, scale: .large)
        let buttonImage = UIImage(systemName: self.systemName, withConfiguration: imageConfig)!
            .withTintColor(.white, renderingMode: .alwaysOriginal)
        self.setImage(buttonImage, for: .normal)
        
        self.imageView?.contentMode = .scaleAspectFit
    }
}
