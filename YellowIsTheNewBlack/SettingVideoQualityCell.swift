//
//  SettingVideoQualityCell.swift
//  YellowIsTheNewBlack
//
//  Created by 프라이빗 on 2022/06/27.
//

import UIKit

class SettingVideoQualityCell: UITableViewCell {
    lazy var image = UIImageView().then {
        $0.tintColor = .yellow
        $0.sizeToFit()
    }
    
    lazy var text = UITextView().then {
        $0.textColor = .white
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addViews()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addViews() {
        self.addSubview(image)
        image.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        self.addSubview(text)
        text.snp.makeConstraints { make in
            make.right.equalTo(image).inset(15)
            make.bottom.equalTo(image).inset(15)
        }
    }
    
    func setUp(image: UIImage) {
        self.image.image = image
    }
}
