//
//  TrendingVC.swift
//  4kWallpaper
//
//  Created by Dixit Rathod on 06/05/20.
//  Copyright © 2020 Dixit Rathod. All rights reserved.
//

import UIKit
import KingfisherWebP
import FBAudienceNetwork

class TrendingVC: UIViewController {
    @IBOutlet weak var collectionWallPapers:UICollectionView!
    @IBOutlet weak var viewIndicator:UIView!
    @IBOutlet weak var indicator:UIActivityIndicatorView!
    
    var arrTrendings:[Post] = []
    var currentPage = 1
    var loadMore = true
    var refreshController = UIRefreshControl()
    var interstitialAd = FBInterstitialAd()

    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: CellIdentifier.wallpaper, bundle: nil)
        collectionWallPapers.register(nib, forCellWithReuseIdentifier: CellIdentifier.wallpaper)
        serviceForTrendingList()
        refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
        refreshController.addTarget(self, action: #selector(didRefreshCollection(_:)), for: .valueChanged)
        refreshController.tintColor = .white
        
        self.collectionWallPapers.refreshControl = refreshController
        
//        interstitialAd = FBInterstitialAd(placementID: "840781913082757_840787429748872")
//        interstitialAd.delegate = self
//        interstitialAd.load()
        // Do any additional setup after loading the view.
    }
    
    

}

//MARK: - CUSTOM METHODS
extension TrendingVC{
    @objc fileprivate func didRefreshCollection(_ sender:UIRefreshControl){
        currentPage = 1
        serviceForTrendingList()
    }
    
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
        
        if let strUrl = obj.type == "live_wallpaper" ? obj.liveWebP : obj.smallWebp, let url = URL(string: strUrl){
            cell.imgWallPaper.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "placeholder"))
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.size.width/3
        return CGSize(width: width, height: width*1.8)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = PreviewVC.controller()
        vc.post = arrTrendings[indexPath.item]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

//MARK: - WEBSERVICES
extension TrendingVC{
    fileprivate func serviceForTrendingList(){
        let params:[String:Any] = [
            Parameters.user_id:userId,
            Parameters.page:currentPage
        ]
        loadMore = false
        UIView.animate(withDuration: 0.2) { [unowned self] in
            self.viewIndicator.isHidden = false
            self.indicator.startAnimating()
        }
        Webservices().request(with: params, method: .post, endPoint: EndPoints.trending, type: Trending.self, loader: false, success: {[weak self] (success) in
            self?.refreshController.endRefreshing()
            UIView.animate(withDuration: 0.2) {
                self?.viewIndicator.isHidden = true
                self?.indicator.stopAnimating()
            }
            guard let response = success as? Trending else {return}
            if let trendings = response.post{
                if self?.currentPage == 1{
                    self?.arrTrendings = []
                }
                if trendings.count != 0{
                    self?.loadMore = true
                }
                
                self?.arrTrendings.append(contentsOf: trendings)
                self?.collectionWallPapers.reloadData()
            }
            
        }) {[weak self] (failer) in
            UIView.animate(withDuration: 0.2) {
                self?.viewIndicator.isHidden = true
                self?.indicator.stopAnimating()
            }
            guard let vc = self else {return}
            AppUtilities.shared().showAlert(with: failer, viewController: vc)
        }
    }
}


//MARK: - SCROLLVIEW DELEGATES
extension TrendingVC{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionWallPapers{
            if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height, loadMore{
                currentPage += 1
                serviceForTrendingList()
            }
        }
    }
}

////MARK: - INTERSTITAL DELEGATES
//extension TrendingVC:FBInterstitialAdDelegate{
//    func interstitialAdDidLoad(_ interstitialAd: FBInterstitialAd) {
//        if interstitialAd.isAdValid{
//            interstitialAd.show(fromRootViewController: self)
//        }
//    }
//
//    func interstitialAdWillLogImpression(_ interstitialAd: FBInterstitialAd) {
//        print("interstitialAdWillLogImpression")
//    }
//
//    func interstitialAd(_ interstitialAd: FBInterstitialAd, didFailWithError error: Error) {
//        print("didFailWithError : \(error)")
//    }
//
//    func interstitialAdDidClick(_ interstitialAd: FBInterstitialAd) {
//        print("interstitialAdWillLogImpression")
//    }
//
//    func interstitialAdDidClose(_ interstitialAd: FBInterstitialAd) {
//        print("interstitialAdDidClose")
//        interstitialAd.load()
//    }
//
//    func interstitialAdWillClose(_ interstitialAd: FBInterstitialAd) {
//        print("interstitialAdWillClose")
//    }
//}
