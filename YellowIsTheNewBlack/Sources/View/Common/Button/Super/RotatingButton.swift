//
//  RotatingButton.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2023/05/22.
//

import UIKit

class RotatingButton: UIButton {
    var rotateWhenOrientationChanged = true
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil
        )
    }
    
    @objc func orientationChanged() {
        guard rotateWhenOrientationChanged else {
            return
        }
        
        let orientation: UIDeviceOrientation = UIDevice.current.orientation
        var rotationAngle: CGFloat = 0

        switch orientation {
            case .portrait:
                rotationAngle = 0
            case .landscapeRight:
                rotationAngle = -CGFloat.pi / 2
            case .landscapeLeft:
                rotationAngle = CGFloat.pi / 2
            case .portraitUpsideDown:
                rotationAngle = CGFloat.pi
            default:
                rotationAngle = 0
        }

        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform(rotationAngle: rotationAngle)
        }
    }
}
