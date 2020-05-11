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
        btnLiveViewAll.setRounded()
//        btnWallViewAll.setRounded()
        btnLiveViewAll.setBorder(with: .white, width: 1.0)
//        btnWallViewAll.setBorder(with: .white, width: 1.0)
        
        collectionBanner.register(UINib(nibName: CellIdentifier.bannerCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.bannerCell)
        // Initialization code
    }
    
}


//MARK: - ACTION METHODS
extension CategoryHeader{
    @IBAction func btnLiveViewAll(_ sender:UIButton){
        self.delegate?.viewAllLiveWallpaper()
    }
    
    @IBAction func btnWallViewAll(_ sender:UIButton){
        self.delegate?.viewAllWallpaper()
    }
}

//MARK: - COLLECTION DELEGATES
extension CategoryHeader:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrBanners.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.bannerCell, for: indexPath) as! BannerCell
        let wallPaper = arrBanners[indexPath.item]
        cell.category = wallPaper.name ?? ""
        cell.delegate = self
        cell.lblName.text = wallPaper.name
        if let str = wallPaper.webp, let url = URL(string:str){
            cell.imgBanner.kf.setImage(with: url)
        }
        
        DispatchQueue.main.async {
            cell.layoutIfNeeded()
            cell.viewShadow.applyGradient(location: [0.0, 1.0], startPoint: CGPoint(x: 0.0, y: 0.0), endPoint: CGPoint(x: 1.0, y: 0.0), colors: [UIColor.clear.cgColor, UIColor.black.cgColor])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}

//MARK: - BANNER DELEGATE
extension CategoryHeader:BannerCellDelegate{
    func openCategory(category: String) {
        self.delegate?.openCategory(category: category)
    }
}
