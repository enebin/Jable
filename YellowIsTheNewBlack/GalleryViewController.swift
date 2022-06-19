//
//  GalleryViewController.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/05/29.
//

import UIKit
import SnapKit
import Then

class GalleryViewController: UIViewController {
    private var viewModel: GalleryViewModel! = nil
    
    lazy var layout = UICollectionViewFlowLayout().then {
        $0.minimumLineSpacing = 1
        $0.minimumInteritemSpacing = 0
        $0.scrollDirection = .vertical
        
        let width = UIScreen.main.bounds.width / 3
        $0.itemSize = CGSize(width: width, height: width)
        $0.invalidateLayout()
    }
     
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).then {
        $0.register(GalleryViewCell.self, forCellWithReuseIdentifier: "GalleryViewCell")
        $0.backgroundColor = .black
        $0.showsVerticalScrollIndicator = true
        
        $0.delegate = self
        $0.dataSource = self
    }
    
    
    // Initializers
    init(viewModel: GalleryViewModel = GalleryViewModel()) {
        super.init(nibName: nil, bundle: nil)
        
        // Update dependencies
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(collectionView)
        
        setLayout()
    }
    
    func setLayout() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.height.equalToSuperview()
        }
    }
}

extension GalleryViewController: UICollectionViewDelegate {
    
}

extension GalleryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.thumbnails.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GalleryViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryViewCell", for: indexPath) as! GalleryViewCell
        
        cell.setUp(image: viewModel.thumbnails[indexPath.row])
        
        return cell
    }
}
