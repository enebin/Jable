//
//  SettingVideoQualityCell.swift
//  YellowIsTheNewBlack
//
//  Created by 프라이빗 on 2022/06/27.
//

import UIKit

class SettingVideoQualityCell: UITableViewCell {
    lazy var cellImageView = UIImageView().then {
        $0.tintColor = .yellow
        $0.sizeToFit()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addViews()
        setLayout(description: "")
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addViews() {
        self.addSubview(cellImageView)
        cellImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
    }
    
    func setLayout(description text: String) {
        let cell = self
        
        if #available(iOS 14, *) {
            var content = cell.defaultContentConfiguration()
            content.textProperties.color = .white
            content.text = text

            var background = UIBackgroundConfiguration.listPlainCell()
            background.backgroundColor = .gray.withAlphaComponent(0.2)
            
            cell.contentConfiguration = content
            cell.backgroundConfiguration = background
        } else {
            cell.textLabel?.text = text
            cell.textLabel?.textColor = .white
            cell.backgroundColor = .gray.withAlphaComponent(0.2)
        }
    }
    
    func setImage(_ image: UIImage?) {
        self.cellImageView.image = image
    }
}
