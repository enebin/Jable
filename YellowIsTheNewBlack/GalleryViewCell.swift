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
    typealias Item = GalleryCellItem
    
    private var thumbnail: UIImage? {
        didSet {
            if let thumbnail = thumbnail {
                setThumbnailImage(thumbnail)
            } else {
                setThumbnailImage(nil)
            }
        }
    }

    lazy var imageView = UIImageView().then {
        $0.image = UIImage(systemName: "person")
        $0.tintColor = .white
        $0.sizeToFit()
    }
    
    // MARK: Overriden
    override func prepareForReuse() {
        thumbnail = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setLayout()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLayout() {
        self.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalToSuperview()
        }
    }
    
    func setThumbnailImage(_ image: UIImage?) {
        self.imageView.image = image
    }
}

