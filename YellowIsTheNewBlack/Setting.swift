//
//  Setting.swift
//  YellowIsTheNewBlack
//
//  Created by 프라이빗 on 2022/06/16.
//

import Foundation

struct Setting {
    let name: String
    let type: SettingType
    let action: () -> ()
    
    enum SettingType  {
        case toggle
        case carousel
    }
}

