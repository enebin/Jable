//
//  SettingViewModel.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/06/10.
//

import UIKit

class SettingViewModel {
    // Dependencies
    private let commonConfig: VideoRecorderConfiguration
    
    let settings: [SettingType]
    
    init(_ config: VideoRecorderConfiguration = VideoRecorderConfiguration()) {
        self.commonConfig = config
        
        self.settings = [
            VideoQualitySetting(with: config)
        ]
    }
}



