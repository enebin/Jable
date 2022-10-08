//
//  ShutterButton.swift
//  YellowIsTheNewBlack
//
//  Created by Young Bin on 2022/09/30.
//

import UIKit
import Then

class ShutterButton: UIButton {
    private let circleShape = ShutterButtonShape()

    override func layoutSubviews() {
        super.layoutSubviews()
        setLayout()
    }
    
    private func setLayout() {
        self.addSubview(circleShape)
        circleShape.bounds = self.bounds
        circleShape.isUserInteractionEnabled = false
        circleShape.snp.makeConstraints { make in
            make.width.height.equalToSuperview()
            make.center.equalToSuperview()
        }
    }
}


fileprivate final class ShutterButtonShape: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        makeCirclePath()
    }
    
    private func makeCirclePath() {
        let halfSize: CGFloat = min(bounds.size.width/2, bounds.size.height/2)
        let desiredLineWidth:CGFloat = 1
        
        let outerPath = UIBezierPath(
                arcCenter: CGPoint(x: halfSize, y: halfSize),
                radius: CGFloat( halfSize - (desiredLineWidth/2) ),
                startAngle: CGFloat(0),
                endAngle:CGFloat(Double.pi * 2),
                clockwise: true)
        
        let innerPath = UIBezierPath(
                arcCenter: CGPoint(x: halfSize, y: halfSize),
                radius: CGFloat( halfSize - (desiredLineWidth/2) - 5 ),
                startAngle: CGFloat(0),
                endAngle:CGFloat(Double.pi * 2),
                clockwise: true)
        
        let outerLayer = CAShapeLayer()
        outerLayer.path = outerPath.cgPath
        outerLayer.strokeColor = UIColor.white.cgColor
        outerLayer.fillColor = UIColor.clear.cgColor
        outerLayer.lineWidth = 4
        
        let innerLayer = CAShapeLayer()
        innerLayer.path = innerPath.cgPath
        innerLayer.fillColor = UIColor.white.cgColor
            
        layer.addSublayer(outerLayer)
        layer.addSublayer(innerLayer)
    }
}
