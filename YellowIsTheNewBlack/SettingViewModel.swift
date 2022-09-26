//
//  SettingViewModel.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/06/10.
//

import UIKit

class SettingViewModel {
    let settings: [SettingType]
    
    init() {
        self.settings = [
            VideoQualitySetting()
        ]
    }
}



