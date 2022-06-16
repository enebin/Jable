//
//  SettingViewModel.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/06/10.
//

import Foundation

class SettingViewModel {
    let settings: [Setting]
    
    init() {
        self.settings = [
            Setting(name: "화질", type: .toggle, action: {
                print("SS")
            })
        ]
    }
}



