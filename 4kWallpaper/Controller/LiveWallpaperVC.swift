//
//  LiveWallpaperVC.swift
//  4kWallpaper
//
//  Created by Dixit Rathod on 06/05/20.
//  Copyright © 2020 Dixit Rathod. All rights reserved.
//

import UIKit
import KingfisherWebP
import GoogleMobileAds

class LiveWallpaperVC: UIViewController {
    @IBOutlet weak var collectionWallPapers:UICollectionView!
    @IBOutlet weak var viewIndicator:UIView!
    @IBOutlet weak var indicator:UIActivityIndicatorView!
    @IBOutlet weak var bannerView:GADBannerView!
    
    var arrWallPapers:[Post] = []
    var currentPage = 1
    var loadMore = true
    var refreshController = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isSubscribed{
            bannerView.isHidden = true
        }
        else{
            AppUtilities.shared().loadBannerAd(in: self.bannerView, view: self.view)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to:size, with:coordinator)
        coordinator.animate(alongsideTransition: { _ in
            AppUtilities.shared().loadBannerAd(in: self.bannerView, view: self.view)
        })
    }

}

//MARK: - CUSTOM METHODS
extension LiveWallpaperVC{
    fileprivate func setupData(){
        //Collection Methods
        self.collectionWallPapers.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        self.collectionWallPapers.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer")
        let nib = UINib(nibName: CellIdentifier.wallpaper, bundle: nil)
        collectionWallPapers.register(nib, forCellWithReuseIdentifier: CellIdentifier.wallpaper)
        
        //API call
        serviceForLiveList()
        
        //Refresh Controlls
//        refreshController.attributedTitle = NSAttributedString(string: "Pull To Refresh.", attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
        refreshController.addTarget(self, action: #selector(didRefreshCollection(_:)), for: .valueChanged)
        refreshController.tintColor = .white
        self.collectionWallPapers.refreshControl = refreshController
        
        //Observers
        NotificationCenter.default.addObserver(self, selector: #selector(updatedAds), name: Notification.Name(rawValue: NotificationKeys.updatedAds), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatedAds), name: NSNotification.Name(rawValue: NotificationKeys.purchaseSuccess), object: nil)
        
        bannerView.adUnitID = bannerAdUnitId
        bannerView.rootViewController = self
    }
    
    
    @objc fileprivate func updatedAds(){
        self.collectionWallPapers.reloadData()
    }
    
    @objc fileprivate func didRefreshCollection(_ sender:UIRefreshControl){
        currentPage = 1
//        refreshController.attributedTitle = NSAttributedString(string: "Refreshing...", attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
        serviceForLiveList()
    }
    
    fileprivate func getBaseFromType(type:String) -> String{
        if type == PostType.wallpaper.rawValue{
            return ImageBase.wpsmallWebP
        }
        else if type == PostType.live.rawValue{
            return ImageBase.liveWebp
        }
        return ImageBase.categoryWebp
    }
}

//MARK: - COLLECTION DELEGATES
extension LiveWallpaperVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return arrWallPapers.count%kAdsDifference == 0 ? arrWallPapers.count/kAdsDifference : (arrWallPapers.count/kAdsDifference + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let total = arrWallPapers.count - kAdsDifference*section
        return total > kAdsDifference ? kAdsDifference : total
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.wallpaper, for: indexPath) as! WallpaperCell
        let index = indexPath.section*kAdsDifference
        let obj = arrWallPapers[index + indexPath.row]
        
        if let strUrl = obj.liveWebP, let url = URL(string: strUrl){
            cell.imgWallPaper.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "placeholder"))
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.size.width-45)/3
        let height = (width*ratioHeight)/ratioWidth
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if showInAppOnLive, !isSubscribed{
            self.navigationController?.pushViewController(SubscriptionVC.controller(), animated: true)
            return
        }
        
        kActivity += 1
        let index = indexPath.section*kAdsDifference
        let obj = arrWallPapers[index + indexPath.row]
        let vc = PreviewVC.controller()
        vc.type = PostType.live.rawValue
        vc.post = obj
        let cell = collectionView.cellForItem(at: indexPath) as! WallpaperCell
        vc.previewImage = cell.imgWallPaper.image
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if isSubscribed || section == numberOfSections(in: collectionView)-1{
            return CGSize.zero
        }
        return CGSize(width: collectionView.frame.size.width, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
            return header
            
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
            if isSubscribed{
                return footerView
            }
//            footerView.clipsToBounds = true
//            if AppDelegate.shared.adsArr.count > indexPath.section
//            {
//                footerView.viewWithTag(25)?.removeFromSuperview()
//                let add = AppDelegate.shared.adsArr[indexPath.section]
//                add.tag = 25
//                footerView.addSubview(add)
//                add.clipsToBounds = true
//                add.translatesAutoresizingMaskIntoConstraints = false
//                NSLayoutConstraint.activate([
//                    add.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 0),
//                    add.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: 0),
//                    add.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 10),
//                    add.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -10)
//                ])
//            }
            return footerView
            
        default:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
            return footerView
        }
    }
}

//MARK: - WEBSERVICES
extension LiveWallpaperVC{
    fileprivate func serviceForLiveList(){
        let params:[String:Any] = [
            Parameters.user_id:userId,
            Parameters.page:currentPage,
            Parameters.used_ids:arrWallPapers.compactMap({$0.postId}).joined(separator: ",")
        ]
        loadMore = false
        if currentPage != 1{
            UIView.animate(withDuration: 0.2) { [unowned self] in
                self.viewIndicator.isHidden = false
                self.indicator.startAnimating()
            }
        }
        Webservices().request(with: params, method: .post, endPoint: EndPoints.live, type: Trending.self, loader: currentPage == 1 ? true : false, success: {[weak self] (success) in
            self?.refreshController.endRefreshing()
//            self?.refreshController.attributedTitle = NSAttributedString(string: "Pull To Refresh.", attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
            UIView.animate(withDuration: 0.2) {
                self?.viewIndicator.isHidden = true
                self?.indicator.stopAnimating()
            }
            guard let response = success as? Trending else {return}
            if let trendings = response.post{
                if self?.currentPage == 1{
                    self?.arrWallPapers = []
                }
                if trendings.count != 0{
                    self?.loadMore = true
                }
                self?.arrWallPapers.append(contentsOf: trendings)
                AppDelegate.shared.totalData = self?.arrWallPapers.count ?? 0
                if self?.currentPage == 1{
                    self?.collectionWallPapers.reloadData()
                    return
                }
                let lastSection = self?.collectionWallPapers.numberOfSections ?? 0
                let itemsInLastSection = self?.collectionWallPapers.numberOfItems(inSection: lastSection-1) ?? 0
                
                var section = lastSection
                var index = itemsInLastSection
                var indexPaths:[IndexPath] = []
                var store = true
                var sections:[Int] = []
                for _ in 0..<trendings.count{
                    if index >= kAdsDifference{
                        sections.append(section)//add sections for insert new
                        section += 1
                        index = 0
                        store = false
                    }
                    if store == true {//store indexpath for last section remaining indexes
                        indexPaths.append(IndexPath(item: index, section: section-1))
                    }
                    index += 1
                }
                
                let indexSet = IndexSet(sections)
                self?.collectionWallPapers.performBatchUpdates({
                    self?.collectionWallPapers.insertItems(at: indexPaths)
                    self?.collectionWallPapers.insertSections(indexSet)
                }, completion: nil)
                
            }
            
        }) {[weak self] (failer) in
            self?.refreshController.endRefreshing()
            UIView.animate(withDuration: 0.2) {
                self?.viewIndicator.isHidden = true
                self?.indicator.stopAnimating()
            }
            guard let vc = self else {return}
            AppUtilities.shared().showAlert(with: kNoInternet, viewController: vc, hideButtons: true)
        }
    }
}


//MARK: - SCROLLVIEW DELEGATES
extension LiveWallpaperVC{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionWallPapers{
            if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height, loadMore{
                currentPage += 1
                serviceForLiveList()
            }
        }
    }
}
