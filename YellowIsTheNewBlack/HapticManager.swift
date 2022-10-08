//
//  HapticManager.swift
//  YellowIsTheNewBlack
//
//  Created by Young Bin on 2022/10/01.
//

import UIKit

struct HapticManager {
    static let shared = HapticManager()
    private let generator: UIImpactFeedbackGenerator
    
    func generate() {
        generator.impactOccurred()
    }
    
    init() {
        self.generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
    }
}
