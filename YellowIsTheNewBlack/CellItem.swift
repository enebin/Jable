//
//  CellItem.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/09/21.
//

import UIKit

protocol CellItem {
    associatedtype Action
    
    var title: String? { get }
    var image: UIImage? { get }
    
    var actionType: ActionType? { get }
    var action: Action? { get }
}
