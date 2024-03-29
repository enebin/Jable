//
//  BackButton.swift
//  YellowIsTheNewBlack
//
//  Created by Young Bin on 2022/10/03.
//

import UIKit

class SystemImageButton: RotatingButton {
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
        NotificationCenter.default.addObserver(
            self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil
        )
    }

    private func setLayout() {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large)
        let buttonImage = UIImage(systemName: self.systemName, withConfiguration: imageConfig)!
            .withTintColor(.white, renderingMode: .alwaysOriginal)
        self.setImage(buttonImage, for: .normal)
    
        self.imageView?.contentMode = .scaleAspectFit
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 5
        self.showsTouchWhenHighlighted = true
    }
}
