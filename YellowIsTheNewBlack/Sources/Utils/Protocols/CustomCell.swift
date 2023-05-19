//
//  CustomCell.swift
//  YellowIsTheNewBlack
//
//  Created by Young Bin on 2022/10/10.
//

import UIKit
import Foundation

protocol CustomCell: AnyObject, UITableViewCell {
    associatedtype Item: CellItem

    func setLayout()
    func setLayout(with cellItem: Item)
}

extension CustomCell {
    func setLayout() {
        let cell = self

        if #available(iOS 14, *) {
            var content = cell.defaultContentConfiguration()
            content.textProperties.color = .white

            var background = UIBackgroundConfiguration.listPlainCell()
            background.backgroundColor = .gray.withAlphaComponent(0.2)

            cell.contentConfiguration = content
            cell.backgroundConfiguration = background
        } else {
            cell.textLabel?.textColor = .white
            cell.backgroundColor = .gray.withAlphaComponent(0.2)
        }
    }

    func setLayout(with cellItem: Item) {
        let cell = self
        let text = cellItem.title

        if #available(iOS 14, *) {
            var configuration = cell.contentConfiguration as! UIListContentConfiguration

            configuration.text = cellItem.title
            configuration.image = cellItem.image

            cell.contentConfiguration = configuration
        } else     {
            cell.textLabel?.text = text
        }
    }
}
