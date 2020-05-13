//
//  CategoryHeader.swift
//  4kWallpaper
//
//  Created by Dixit Rathod on 11/05/20.
//  Copyright © 2020 Dixit Rathod. All rights reserved.
//

import UIKit

protocol CategoryHeaderDelegate:AnyObject {
    func openCategory(category:String)
    func viewAllLiveWallpaper()
    func viewAllWallpaper()
}

class CategoryHeader: UICollectionReusableView {
    @IBOutlet weak var btnLiveViewAll:UIButton!
//    @IBOutlet weak var btnWallViewAll:UIButton!
    @IBOutlet weak var collectionBanner:UICollectionView!
    
    var timer = Timer()
    
    var arrBanners:[Wallpaper] = []{
        didSet{
            self.collectionBanner.reloadData()
            if timer.isValid{
                timer.invalidate()
            }
            timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { (timer) in
                let indexPath = self.collectionBanner.indexPathsForVisibleItems.first
                if indexPath?.item == self.arrBanners.count - 1{
                    self.collectionBanner.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
                }
                else if self.arrBanners.count > 1{
                    self.collectionBanner.scrollToItem(at: IndexPath(item: (indexPath?.item ?? 0) + 1, section: 0), at: .centeredHorizontally, animated: true)
                }
            })
        }
    }
    weak var delegate:CategoryHeaderDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutIfNeeded()
        
        
        collectionBanner.register(UINib(nibName: CellIdentifier.categoryCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.categoryCell)
        // Initialization code
    }
    
}

//MARK: - COLLECTION DELEGATES
extension CategoryHeader:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrBanners.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.categoryCell, for: indexPath) as! CatCell
        let wallpaper = arrBanners[indexPath.item]
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
        let height = collectionView.bounds.size.height
        return CGSize(width: height/1.2, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let wallpaper = arrBanners[indexPath.item]
        self.delegate?.openCategory(category: wallpaper.name ?? "")
    }
}

//MARK: - BANNER DELEGATE
extension CategoryHeader:BannerCellDelegate{
    func openCategory(category: String) {
        self.delegate?.openCategory(category: category)
    }
}
