//
//  ShutterButton.swift
//  YellowIsTheNewBlack
//
//  Created by Young Bin on 2022/09/30.
//

import UIKit
import Then

class ShutterButton: UIButton {
    var isRecording = false {
        didSet {
            if isRecording {
                shapeView.currentState = .recording
            } else {
                shapeView.currentState = .ready
            }
        }
    }
    
    private lazy var shapeView = AnimatingShutterButtonShape()

    override func layoutSubviews() {
        super.layoutSubviews()
        setLayout()
    }
    
    func setLayout() {
        self.addSubview(shapeView)
        shapeView.bounds = self.bounds
        shapeView.isUserInteractionEnabled = false
        shapeView.snp.makeConstraints { make in
            make.width.height.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        layoutIfNeeded()
    }
}

enum RecordingState {
    case recording
    case ready
    
    var desiredLineWidth: CGFloat {
        return 1
    }
    
    func rect(center: CGFloat, size: CGFloat) -> CGRect {
        return CGRect(origin: CGPoint(x: center - size / 2, y: center - size / 2),
                      size: CGSize(width: size, height: size))
    }
        
    func path(center: CGFloat, size: CGFloat) -> CGPath {
        switch self {
        case .recording:
            return UIBezierPath(roundedRect: rect(center: center, size: size), cornerRadius: 5).cgPath
        case .ready:
            return UIBezierPath(roundedRect: rect(center: center, size: size), cornerRadius: size / 2).cgPath
        }
    }
}


fileprivate final class AnimatingShutterButtonShape: UIView {
    var halfSize: CGFloat {
        min(bounds.size.width/2, bounds.size.height/2)
    }

    var currentState: RecordingState = .ready {
        didSet {
            let pathAnimation = CASpringAnimation(keyPath: "path")
            pathAnimation.fromValue = innerPathLayer.presentation()?.path
            pathAnimation.duration = 0.15
            innerPathLayer.add(pathAnimation, forKey: "pathAnimation")
            innerPathLayer.path = currentState.path(center: halfSize, size: currentState == .ready ? (halfSize * 2 - 15) : 25)
        }
    }
    
    var outerPathLayer = CAShapeLayer()
    var innerPathLayer = CAShapeLayer()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        makeCirclePath()
    }
    
    private func makeCirclePath() {
        let outerPath = UIBezierPath(
                arcCenter: CGPoint(x: halfSize, y: halfSize),
                radius: CGFloat( halfSize - (1/2) ),
                startAngle: CGFloat(0),
                endAngle:CGFloat(Double.pi * 2),
                clockwise: true)
        
        
        outerPathLayer.path = outerPath.cgPath
        outerPathLayer.strokeColor = UIColor.white.cgColor
        outerPathLayer.fillColor = UIColor.clear.cgColor
        outerPathLayer.lineWidth = 4
        
        innerPathLayer.path = currentState.path(center: halfSize, size: currentState == .ready ? (halfSize * 2 - 15) : 25)
        innerPathLayer.fillColor = UIColor.red.cgColor
            
        layer.addSublayer(outerPathLayer)
        layer.addSublayer(innerPathLayer)
    }
}

