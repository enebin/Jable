//
//  GalleryViewController.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2022/05/29.
//

import UIKit
import SnapKit
import Then
import RxDataSources
import RxSwift


class GalleryViewController: UIViewController {
    var viewModel: GalleryViewModel! = nil
    var dataSource: RxCollectionViewSectionedAnimatedDataSource<GallerySection>! = nil
    let disposeBag = DisposeBag()
    
    
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
        
//        $0.delegate = self
//        $0.dataSource = self
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
    
    func setDatasource() {
        let sections = [GallerySection(header: "First section", items: viewModel.videoInformations)]
        self.dataSource = RxCollectionViewSectionedAnimatedDataSource<GallerySection>(
            configureCell: { [weak self] (dataSource, collectionView, indexPath, item) in
                guard let self = self else { return UICollectionViewCell() }
                
                let cell: GalleryViewCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryViewCell", for: indexPath) as! GalleryViewCell
                cell.setUp(image: (self.viewModel.videoInformations[indexPath.row].thumbnail) ?? UIImage(systemName: "xmark")!)
                
                return cell
            }
        )
        
        // TODO: Make it reactive
        Observable.just(sections)
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
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
//
//extension GalleryViewController: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return viewModel.videoInformations.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell: GalleryViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryViewCell", for: indexPath) as! GalleryViewCell
//        cell.setUp(image: (viewModel.videoInformations[indexPath.row].thumbnail) ?? UIImage(systemName: "xmark")!)
//
//        return cell
//    }
//}
