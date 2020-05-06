//
//  TrendingVC.swift
//  4kWallpaper
//
//  Created by Dixit Rathod on 06/05/20.
//  Copyright © 2020 Dixit Rathod. All rights reserved.
//

import UIKit
import KingfisherWebP

class TrendingVC: UIViewController {
    @IBOutlet weak var collectionWallPapers:UICollectionView!
    
    var arrTrendings:[Post] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: CellIdentifier.wallpaper, bundle: nil)
        collectionWallPapers.register(nib, forCellWithReuseIdentifier: CellIdentifier.wallpaper)
        serviceForTrendingList()
        // Do any additional setup after loading the view.
    }
    
    

}

//MARK: - CUSTOM METHODS
extension TrendingVC{
    fileprivate func getBaseFromType(type:String) -> String{
        if type == "wallpaper"{
            return ImageBase.wpsmallWebP
        }
        else if type == "live_wallpaper"{
            return ImageBase.liveWebp
        }
        return ImageBase.categoryWebp
    }
}

//MARK: - COLLECTION DELEGATES
extension TrendingVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrTrendings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.wallpaper, for: indexPath) as! WallpaperCell
        let obj = arrTrendings[indexPath.row]
        
        let base = getBaseFromType(type: obj.type ?? "")
        if let strUrl = obj.webp, let url = URL(string: base + strUrl){
            cell.imgWallPaper.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "placeholder"))
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.size.width/3
        return CGSize(width: width, height: width*1.8)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}

//MARK: - WEBSERVICES
extension TrendingVC{
    fileprivate func serviceForTrendingList(){
        let params:[String:Any] = [:]
        Webservices().request(with: params, method: .post, endPoint: EndPoints.trending, type: Trending.self, success: {[weak self] (success) in
            guard let response = success as? Trending else {return}
            if let trendings = response.post{
                self?.arrTrendings = trendings
                self?.collectionWallPapers.reloadData()
            }
            
        }) {[weak self] (failer) in
            guard let vc = self else {return}
            AppUtilities.shared().showAlert(with: failer, viewController: vc)
        }
    }
}
