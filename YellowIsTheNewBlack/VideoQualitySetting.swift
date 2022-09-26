//
//  VideoOptions.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/09/26.
//

import UIKit

struct VideoQualitySetting: SettingType {
    let title = "비디오 화질"
    let icon = UIImage(systemName: "person")!
    
    let options: [SettingOption] = [
        SettingOption(title: "고화질", action: {  }),
        SettingOption(title: "중간화질", action: { }),
        SettingOption(title: "저화질", action: { })
    ]
}
