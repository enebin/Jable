//
//  HapticManager.swift
//  YellowIsTheNewBlack
//
//  Created by Young Bin on 2022/10/01.
//

import UIKit

struct HapticManager {
    enum HapticType {
        case start
        case end
        case normal
    }
    
    static let shared = HapticManager()
    private let generator: UIImpactFeedbackGenerator
    private let feedbackGenerator: UINotificationFeedbackGenerator
    
    func generate(type: HapticType) {
        switch type {
        case .normal:
            generator.impactOccurred()
        case .start:
            generator.impactOccurred()
        case .end:
            feedbackGenerator.notificationOccurred(.success)
        }
        generator.impactOccurred()
    }
    
    init() {
        self.generator = UIImpactFeedbackGenerator(style: .medium)
        self.feedbackGenerator = UINotificationFeedbackGenerator()
        generator.prepare()
    }
}
