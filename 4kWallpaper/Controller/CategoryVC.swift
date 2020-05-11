//
//  CategoryVC.swift
//  4kWallpaper
//
//  Created by Dixit Rathod on 06/05/20.
//  Copyright © 2020 Dixit Rathod. All rights reserved.
//

import UIKit

class CategoryVC: UIViewController {
    @IBOutlet weak var collectionCategory:UICollectionView!
    
    var arrWallPapers:[Wallpaper] = []
    var arrBanners:[Wallpaper] = []
    var refreshController = UIRefreshControl()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
    }
}

//MARK: - CUSTOM METHODS
extension CategoryVC{
    fileprivate func setupView(){
        //register nib
        collectionCategory.register(UINib(nibName: CellIdentifier.categoryHeader, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CellIdentifier.categoryHeader)
        collectionCategory.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer")
        collectionCategory.register(UINib(nibName: CellIdentifier.categoryCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.categoryCell)
        
        //Refresh Controlls
        refreshController.attributedTitle = NSAttributedString(string: "Pull To Refresh.", attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
        refreshController.addTarget(self, action: #selector(didRefreshCollection(_:)), for: .valueChanged)
        refreshController.tintColor = .white
        self.collectionCategory.refreshControl = refreshController
        
        serviceForCategory()
    }
    
    @objc fileprivate func didRefreshCollection(_ sender:UIRefreshControl){
        
        refreshController.attributedTitle = NSAttributedString(string: "Refreshing...", attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
        serviceForCategory()
    }
}

//MARK: - COLLECTION DELEGATES
extension CategoryVC:UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrWallPapers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.categoryCell, for: indexPath) as! CatCell
        let wallpaper = arrWallPapers[indexPath.item]
        cell.lblName.text = wallpaper.name
        if let str = wallpaper.webp, let url = URL(string:str){
            cell.imgWallpaper.kf.setImage(with: url)
        }
        DispatchQueue.main.async {
            cell.layoutIfNeeded()
            cell.viewGradient.applyGradient(location: [0.0, 1.0], startPoint: CGPoint(x: 0.0, y: 0.4), endPoint: CGPoint(x: 0.0, y: 1.0), colors: [UIColor.clear.cgColor, UIColor.black.cgColor])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.size.width/2
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        kActivity += 1
        
        let obj = arrWallPapers[indexPath.item]
        let vc = SimilarCatVC.controller()
        vc.category = obj.name ?? ""
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 300)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CellIdentifier.categoryHeader, for: indexPath) as! CategoryHeader
            header.delegate = self
            header.arrBanners = self.arrBanners
            
            return header
            
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
            return footerView
            
        default:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
            return footerView
        }
    }
}

//MARK: - WEBSERVICES
extension CategoryVC{
    fileprivate func serviceForCategory(){
        
        Webservices().request(with: [:], method: .post, endPoint: EndPoints.categoryList, type: Category.self, loader: true, success: {[weak self] (success) in
            self?.refreshController.endRefreshing()
            self?.refreshController.attributedTitle = NSAttributedString(string: "Pull To Refresh.", attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
            
            guard let response = success as? Category else {return}
            if let data = response.data{
                
                self?.arrWallPapers = data.wallpaper ?? []
                self?.arrBanners = data.liveWallpaper ?? []
                self?.collectionCategory.reloadData()
                
            }
            
        }) {[weak self] (failer) in
            guard let vc = self else {return}
            AppUtilities.shared().showAlert(with: failer, viewController: vc)
        }
    }
}

//MARK: - BANNER DELEGATES
extension CategoryVC:CategoryHeaderDelegate{
    func viewAllLiveWallpaper() {
        self.tabBarController?.selectedIndex = 2
    }
    
    func viewAllWallpaper() {
        self.tabBarController?.selectedIndex = 1
    }
    
    func openCategory(category: String) {
        let vc = SimilarCatVC.controller()
        vc.category = category
        navigationController?.pushViewController(vc, animated: true)
    }
}
