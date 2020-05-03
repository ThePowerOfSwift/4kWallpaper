//
//  DashboardCollectionView.swift
//  4kWallpaper
//
//  Created by Dixit Rathod on 03/05/20.
//  Copyright © 2020 Dixit Rathod. All rights reserved.
//

import UIKit

protocol DashboardCollectionDelegate:AnyObject {
    func collectionDidSelectWithIndex(index:Int)
}

class DashboardCollectionView: UIView {
    @IBOutlet weak var collectionWallPapers:UICollectionView!
    
    var index = 0
    weak var delegate:DashboardCollectionDelegate?
    
    override func awakeFromNib() {
        let nib = UINib(nibName: CellIdentifier.wallpaper, bundle: nil)
        collectionWallPapers.register(nib, forCellWithReuseIdentifier: CellIdentifier.wallpaper)
    }
}

//MARK: - COLLECTION DELEGATES
extension DashboardCollectionView:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.wallpaper, for: indexPath) as! WallpaperCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.size.width/3
        return CGSize(width: width, height: width + 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.collectionDidSelectWithIndex(index: index)
    }
    
}


