//
//  SettingOfVideoQualityViewModel.swift
//  YellowIsTheNewBlack
//
//  Created by 프라이빗 on 2022/06/26.
//

import UIKit

class SettingOfVideoQualityViewModel {
    var currentQuality: Quality = .middle
    var options: [String] {
        return Quality.allCases.map { $0.rawValue }
    }
    
    func choose(_ qualityIndex: Int) {
        currentQuality = Quality.allCases[qualityIndex]
    }
}

extension SettingOfVideoQualityViewModel {
    enum Quality: String, CaseIterable {
        case high = "고화질"
        case middle = "중간화질"
        case low = "저화질"
    }
}
