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

import AVFoundation
import AVKit


class GalleryViewController: UIViewController {
    var viewModel: GalleryViewModel! = nil
    var dataSource: RxCollectionViewSectionedAnimatedDataSource<GallerySection>! = nil
    let bag = DisposeBag()
    
    // View components
    lazy var closeButton = SystemImageButton().then {
        $0.setSystemImage(name: "xmark")
    }
    
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
        $0.alwaysBounceVertical = true
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
        self.view.backgroundColor = .black
        self.view.addSubview(collectionView)
        
        setDatasource()
        setLayout()
        bindButtons()
    }
    
    private func setDatasource() {
        self.dataSource = RxCollectionViewSectionedAnimatedDataSource<GallerySection>(
            configureCell: { [weak self] (dataSource, collectionView, indexPath, item) in
                guard let self = self else { return UICollectionViewCell() }
                let cell: GalleryViewCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryViewCell", for: indexPath) as! GalleryViewCell
                
                cell.setThumbnailImage(((item.thumbnail) ?? UIImage(systemName: "xmark")!))
                
                return cell
            }
        )
        
        viewModel.videoInformationsRelay
            .asObservable()
            .map { [GallerySection(header: "", items: $0)] }
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: bag)

        collectionView.rx.setDelegate(self)
            .disposed(by: bag)
    }
    
    private func setLayout() {
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.right.equalToSuperview().inset(10)
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(closeButton.snp.bottom).offset(10)
            make.width.height.equalToSuperview()
        }
    }
    
    private func bindObservables() {
        viewModel.errorStatus
            .bind { [weak self] error in
                guard let self = self  else { return }
                
                let alert = UIAlertController(title: "오류", message: error.localizedDescription,
                                              preferredStyle: UIAlertController.Style.alert).then {
                    $0.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                }
                
                self.present(alert, animated: true)
            }
            .disposed(by: bag)
    }
    
    private func bindButtons() {
        closeButton.rx.tap
            .bind { [weak self] in
                guard let self = self  else { return }
                
                self.dismiss(animated: true)
            }
            .disposed(by: bag)
    }
}

extension GalleryViewController: UICollectionViewDelegate {
    private func playVideo(at path: URL) {
        let player = AVPlayer(url: URL(fileURLWithPath: path.path))
        let playerController = AVPlayerViewController()
        
        playerController.player = player
        present(playerController, animated: true) {
            player.play()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cellIndex = indexPath.last else { return }
        let item = viewModel.videoInformations[cellIndex]
        
        self.playVideo(at: item.path)
    }
}

