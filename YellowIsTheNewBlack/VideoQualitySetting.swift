//
//  VideoOptions.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/09/26.
//

import UIKit

struct VideoQualitySetting: SettingType {
    // Dependencies
    private let videoConfiguration: VideoRecorderConfiguration
    
    // vars and lets
    let title = "비디오 화질"
    let icon = UIImage(systemName: "person")!
    let options: [SettingOption]
    
    init(with videoConfiguration: VideoRecorderConfiguration) {
        self.videoConfiguration = videoConfiguration
        self.options = [
           SettingOption(title: "고화질", action: { videoConfiguration.changeVideoQuality(to: .high) }),
           SettingOption(title: "중간화질", action: { videoConfiguration.changeVideoQuality(to: .medium) }),
           SettingOption(title: "저화질", action: { videoConfiguration.changeVideoQuality(to: .low) })
       ]
    }
}
