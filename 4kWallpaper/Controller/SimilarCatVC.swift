//
//  SimilarCatVC.swift
//  4kWallpaper
//
//  Created by Dixit Rathod on 10/05/20.
//  Copyright © 2020 Dixit Rathod. All rights reserved.
//

import UIKit
import GoogleMobileAds

class SimilarCatVC: UIViewController {
    @IBOutlet weak var collectionWallPapers:UICollectionView!
    @IBOutlet weak var viewIndicator:UIView!
    @IBOutlet weak var indicator:UIActivityIndicatorView!
    @IBOutlet weak var bannerView:GADBannerView!
    
    var arrTrendings:[Post] = []
    var currentPage = 1
    var loadMore = true
    var refreshController = UIRefreshControl()
    var postType:PostType = .wallpaper
    var category = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        // Do any additional setup after loading the view.
    }
    
    class func controller() -> SimilarCatVC{
        let story = UIStoryboard(name: StoryboardIds.main, bundle: nil)
        return story.instantiateViewController(withIdentifier: ControllerIds.similarCategory) as! SimilarCatVC
    }

    
    override func viewWillAppear(_ animated: Bool) {
        if isSubscribed{
            bannerView.isHidden = true
        }
        else{
            AppUtilities.shared().loadBannerAd(in: self.bannerView, view: self.view)
        }
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to:size, with:coordinator)
        coordinator.animate(alongsideTransition: { _ in
            AppUtilities.shared().loadBannerAd(in: self.bannerView, view: self.view)
        })
    }
}

//MARK: - CUSTOM METHODS
extension SimilarCatVC{
    fileprivate func setupData(){
        self.title = category
        //Collection Methods
        self.collectionWallPapers.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        let adNib = UINib(nibName: "adUIView", bundle: nil)
        collectionWallPapers.register(adNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "adUIView")
        let nib = UINib(nibName: CellIdentifier.wallpaper, bundle: nil)
        collectionWallPapers.register(nib, forCellWithReuseIdentifier: CellIdentifier.wallpaper)
        
        //API call
        serviceForTrendingList()
        
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
        serviceForTrendingList()
    }
}

//MARK: - COLLECTION DELEGATES
extension SimilarCatVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return arrTrendings.count%kAdsDifference == 0 ? arrTrendings.count/kAdsDifference : (arrTrendings.count/kAdsDifference + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let total = arrTrendings.count - kAdsDifference*section
        return total > kAdsDifference ? kAdsDifference : total
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.wallpaper, for: indexPath) as! WallpaperCell
        let index = indexPath.section*kAdsDifference
        let obj = arrTrendings[index + indexPath.row]
        
        if let strUrl = postType == .live ? obj.liveWebP : obj.smallWebp, let url = URL(string: strUrl){
            cell.imgWallPaper.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "placeholder"))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = ((collectionView.bounds.size.width-1)-40)/3
        let height = (width*ratioHeight)/ratioWidth
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        kActivity += 1
        let index = indexPath.section*kAdsDifference
        let obj = arrTrendings[index + indexPath.row]
        if showInAppOnLive, !isSubscribed, obj.type == PostType.live.rawValue{
            self.navigationController?.pushViewController(SubscriptionVC.controller(), animated: true)
            return
        }
        let vc = PreviewVC.controller()
        vc.post = obj
        vc.type = postType.rawValue
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
        if let adsCellProvider = AppDelegate.shared.adsCellProvider, adsCellProvider.isAdCell(at: IndexPath(item: section, section: section), forStride: 1){
            let ad = adsCellProvider.collectionView(collectionView, nativeAdForRowAt: IndexPath(item: section, section: section))
            let actual = ad.aspectRatio
            
            let height = (collectionView.bounds.size.width-20)/actual
            //            print("Height of ad is \(height)")
            return CGSize(width: collectionView.bounds.size.width, height: height + 135)
        }
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
            return header
            
        case UICollectionView.elementKindSectionFooter:
           let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "adUIView", for: indexPath) as! adUIView
            if isSubscribed{
                return footerView
            }
            if let adsCellProvider = AppDelegate.shared.adsCellProvider, adsCellProvider.isAdCell(at: IndexPath(item: indexPath.section, section: indexPath.section), forStride: 1){
                let nativeAd = /*adsManager.nextNativeAd else {return footerView}*/adsCellProvider.collectionView(collectionView, nativeAdForRowAt: IndexPath(item: indexPath.section, section: indexPath.section))
                nativeAd.unregisterView()
                
                // Wire up UIView with the native ad; only call to action button and media view will be clickable.
                nativeAd.registerView(forInteraction: footerView, mediaView: footerView.adCoverMediaView, iconView: footerView.adIconImageView, viewController: self,clickableViews: [footerView.adCallToActionButton, footerView.adCoverMediaView])
                //                footerView.adCoverMediaView.delegate = self
                // Render native ads onto UIView
                footerView.adTitleLabel.text = nativeAd.advertiserName
                footerView.adBodyLabel.text = nativeAd.bodyText
                footerView.adSocialContext.text = nativeAd.socialContext
                footerView.sponsoredLabel.text = nativeAd.sponsoredTranslation
                footerView.adCallToActionButton.setTitle(
                    nativeAd.callToAction,
                    for: .normal)
                footerView.adOptionsView.nativeAd = nativeAd
            }
            return footerView
            
        default:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
            
            return footerView
        }
    }
    
    
}

//MARK: - WEBSERVICES
extension SimilarCatVC{
    fileprivate func serviceForTrendingList(){
        let params:[String:Any] = [
            Parameters.user_id:userId,
            Parameters.page:currentPage,
            Parameters.used_ids:self.arrTrendings.compactMap({$0.postId}).joined(separator: ","),
            Parameters.category:category
        ]
        loadMore = false
        if currentPage != 1{
            UIView.animate(withDuration: 0.2) { [unowned self] in
                self.viewIndicator.isHidden = false
                self.indicator.startAnimating()
            }
        }
        Webservices().request(with: params, method: .post, endPoint: postType == .live ? EndPoints.live : EndPoints.postList, type: Trending.self, loader: currentPage == 1 ? true : false, success: {[weak self] (success) in
            AppUtilities.shared().removeNoDataLabelFrom(view: self?.view ?? UIView())
            
            self?.refreshController.endRefreshing()
//            self?.refreshController.attributedTitle = NSAttributedString(string: "Pull To Refresh.", attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
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
                if self?.arrTrendings.count == 0{
                    AppUtilities.shared().showNoDataLabelwith(message: "No data available for \(self?.category ?? "") category", in: self?.view ?? UIView())
                }
                AppDelegate.shared.totalData = self?.arrTrendings.count ?? 0
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
extension SimilarCatVC{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionWallPapers{
            if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height, loadMore{
                currentPage += 1
                serviceForTrendingList()
            }
        }
    }
}
