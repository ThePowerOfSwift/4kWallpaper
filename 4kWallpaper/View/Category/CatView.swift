//
//  BannerCatView.swift
//  4kWallpaper
//
//  Created by Dixit Rathod on 04/05/20.
//  Copyright © 2020 Dixit Rathod. All rights reserved.
//

import UIKit

class CatView: UIView {
    @IBOutlet weak var collectionCategory:UICollectionView!

}

//MARK: - COLLECTION DELEGATES
extension CatView:UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.bannerCell, for: indexPath) as! BannerCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.height/1.8, height: collectionView.bounds.size.height)
    }
}
