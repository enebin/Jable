//
//  ShutterButton.swift
//  YellowIsTheNewBlack
//
//  Created by Young Bin on 2022/09/30.
//

import UIKit
import Then

fileprivate struct Shape {
    var recording = RecordingShutterButtonShape()
    var ready = ShutterButtonShape()
}

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
    
    private let shapes = Shape()
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
            let pathAnimation = CABasicAnimation(keyPath: "path")
            pathAnimation.fromValue = innerPathLayer.presentation()?.path
            pathAnimation.duration = 0.15
            innerPathLayer.add(pathAnimation, forKey: "pathAnimation")
            innerPathLayer.path = currentState.path(center: halfSize, size: halfSize)
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
        
        let innerPath = currentState.path(center: halfSize, size: halfSize)
        
        outerPathLayer.path = outerPath.cgPath
        outerPathLayer.strokeColor = UIColor.white.cgColor
        outerPathLayer.fillColor = UIColor.clear.cgColor
        outerPathLayer.lineWidth = 4
        
        innerPathLayer.path = innerPath
        innerPathLayer.fillColor = UIColor.red.cgColor
            
        layer.addSublayer(outerPathLayer)
        layer.addSublayer(innerPathLayer)
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
        innerLayer.fillColor = UIColor.red.cgColor
            
        layer.addSublayer(outerLayer)
        layer.addSublayer(innerLayer)
    }
}


fileprivate final class RecordingShutterButtonShape: UIView {
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
        
        let innerPath = UIBezierPath(roundedRect: CGRect(x: halfSize - (25 / 2), y: halfSize - (25 / 2), width: 25, height: 25), cornerRadius: 5)
        
        let outerLayer = CAShapeLayer()
        outerLayer.path = outerPath.cgPath
        outerLayer.strokeColor = UIColor.white.cgColor
        outerLayer.fillColor = UIColor.clear.cgColor
        outerLayer.lineWidth = 4
        
        let innerLayer = CAShapeLayer()
        innerLayer.path = innerPath.cgPath
        innerLayer.fillColor = UIColor.red.cgColor
            
        layer.addSublayer(outerLayer)
        layer.addSublayer(innerLayer)
    }
}

