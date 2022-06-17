//
//  GalleryViewCell.swift
//  YellowIsTheNewBlack
//
//  Created by 프라이빗 on 2022/06/17.
//

import UIKit
import Then
import SnapKit

class GalleryViewCell: UICollectionViewCell {
    lazy var image = UIImageView().then {
        $0.image = UIImage(systemName: "person")
        $0.tintColor = .white
        $0.sizeToFit()
    }
    
    lazy var text = UITextView().then {
        $0.text = "Hi"
        $0.textColor = .white
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addViews() {
        self.addSubview(image)
        image.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalToSuperview()
        }
        
        self.addSubview(text)
        text.snp.makeConstraints { make in
            make.right.equalTo(image).inset(15)
            make.bottom.equalTo(image).inset(15)
        }
    }
}

