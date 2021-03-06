//
//  CategoryVC.swift
//  4kWallpaper
//
//  Created by Dixit Rathod on 06/05/20.
//  Copyright © 2020 Dixit Rathod. All rights reserved.
//

import UIKit
import GoogleMobileAds

class CategoryVC: UIViewController {
    @IBOutlet weak var collectionCategory:UICollectionView!
    @IBOutlet weak var searchBar:UISearchBar!
    @IBOutlet weak var viewIndicator:UIView!
    @IBOutlet weak var indicator:UIActivityIndicatorView!
    @IBOutlet weak var bannerView:GADBannerView!
    
    var arrWallPapers:[Wallpaper] = []
    var arrBanners:[Wallpaper] = []
    var arrSearch:[Post] = []
    var refreshController = UIRefreshControl()
    var isSearching = false
    var currentPage = 1
    var loadMore = true
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
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
extension CategoryVC{
    fileprivate func setupView(){
        //register nib
        collectionCategory.register(UINib(nibName: CellIdentifier.categoryHeader, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CellIdentifier.categoryHeader)
        let adNib = UINib(nibName: "adUIView", bundle: nil)
        collectionCategory.register(adNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "adUIView")
        collectionCategory.register(UINib(nibName: CellIdentifier.categoryCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.categoryCell)
        let nib = UINib(nibName: CellIdentifier.wallpaper, bundle: nil)
        collectionCategory.register(nib, forCellWithReuseIdentifier: CellIdentifier.wallpaper)
        
        //Refresh Controlls
//        refreshController.attributedTitle = NSAttributedString(string: "Pull To Refresh.", attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
        refreshController.addTarget(self, action: #selector(didRefreshCollection(_:)), for: .valueChanged)
        refreshController.tintColor = .white
        self.collectionCategory.refreshControl = refreshController
        
        //Observers
        NotificationCenter.default.addObserver(self, selector: #selector(updatedAds), name: Notification.Name(rawValue: NotificationKeys.updatedAds), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatedAds), name: NSNotification.Name(rawValue: NotificationKeys.purchaseSuccess), object: nil)
        
        serviceForCategory()
        
        bannerView.adUnitID = bannerAdUnitId
        bannerView.rootViewController = self
    }
    
    @objc fileprivate func updatedAds(){
        self.collectionCategory.reloadData()
    }
    
    @objc fileprivate func didRefreshCollection(_ sender:UIRefreshControl){
        
//        refreshController.attributedTitle = NSAttributedString(string: "Refreshing...", attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
        serviceForCategory()
    }
}

//MARK: - COLLECTION DELEGATES
extension CategoryVC:UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if isSearching{
            return arrSearch.count%kAdsDifference == 0 ? arrSearch.count/kAdsDifference : (arrSearch.count/kAdsDifference + 1)
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSearching{
            let total = arrSearch.count - kAdsDifference*section
            return total > kAdsDifference ? kAdsDifference : total
        }
        return arrWallPapers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isSearching{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.wallpaper, for: indexPath) as! WallpaperCell
            let index = indexPath.section*kAdsDifference
            let obj = arrSearch[index + indexPath.row]
            
            if let strUrl = obj.type == PostType.live.rawValue ? obj.liveWebP : obj.smallWebp, let url = URL(string: strUrl){
                cell.imgWallPaper.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "placeholder"))
            }
            cell.imgLive.isHidden = obj.type != PostType.live.rawValue
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.categoryCell, for: indexPath) as! CatCell
        let wallpaper = arrWallPapers[indexPath.item]
        cell.lblName.text = wallpaper.name
        if let str = wallpaper.webp, let url = URL(string:str){
            cell.imgWallpaper.kf.setImage(with: url)
        }
        cell.lblName.font = UIFont.boldSystemFont(ofSize: 22)
        DispatchQueue.main.async {
            cell.layoutIfNeeded()
            cell.viewGradient.applyGradient(location: [0.0, 1.0], startPoint: CGPoint(x: 0.0, y: 0.4), endPoint: CGPoint(x: 0.0, y: 1.0), colors: [UIColor.clear.cgColor, UIColor.black.cgColor])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isSearching{
            let width = (collectionView.bounds.size.width-30)/3
            let height = (width*ratioHeight)/ratioWidth
            return CGSize(width: width, height: height)
        }
        let width = (collectionView.bounds.size.width-30)/2
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        kActivity += 1
        if isSearching{
            let index = indexPath.section*kAdsDifference
            let obj = arrSearch[index + indexPath.row]
            if showInAppOnLive, !isSubscribed, obj.type == PostType.live.rawValue{
                self.navigationController?.pushViewController(SubscriptionVC.controller(), animated: true)
                return
            }
            let vc = PreviewVC.controller()
            vc.post = obj
            let cell = collectionView.cellForItem(at: indexPath) as! WallpaperCell
            vc.previewImage = cell.imgWallPaper.image
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        let obj = arrWallPapers[indexPath.item]
        let vc = SimilarCatVC.controller()
        vc.category = obj.name ?? ""
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if isSearching{
            return CGSize.zero
        }
        return CGSize(width: collectionView.bounds.size.width, height: 270)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if isSearching{
            if isSubscribed || section == numberOfSections(in: collectionView)-1{
                return CGSize.zero
            }
            if let adsCellProvider = AppDelegate.shared.adsCellProvider, adsCellProvider.isAdCell(at: IndexPath(item: section, section: section), forStride: 1){
                let ad = adsCellProvider.collectionView(collectionView, nativeAdForRowAt: IndexPath(item: section, section: section))
                let actual = ad.aspectRatio
                
                let height = (collectionView.bounds.size.width-20)/actual
                return CGSize(width: collectionView.bounds.size.width, height: height + 135)
            }
            return CGSize.zero
        }
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
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "adUIView", for: indexPath) as! adUIView
            if isSubscribed || !isSearching{
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
extension CategoryVC{
    fileprivate func serviceForCategory(){
        
        Webservices().request(with: [:], method: .post, endPoint: EndPoints.categoryList, type: Category.self, loader: true, success: {[weak self] (success) in
            self?.refreshController.endRefreshing()
//            self?.refreshController.attributedTitle = NSAttributedString(string: "Pull To Refresh.", attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
            
            guard let response = success as? Category else {return}
            if let data = response.data{
                
                self?.arrWallPapers = data.wallpaper ?? []
                self?.arrBanners = data.liveWallpaper ?? []
                self?.collectionCategory.reloadData()
                
            }
            
        }) {[weak self] (failer) in
            self?.refreshController.endRefreshing()
            guard let vc = self else {return}
            AppUtilities.shared().showAlert(with: kNoInternet, viewController: vc, hideButtons: true)
        }
    }
    
    fileprivate func serviceForSearchList(){
        let params:[String:Any] = [
            Parameters.user_id:userId,
            Parameters.page:currentPage,
            Parameters.search:searchBar.text!
        ]
        loadMore = false
        if currentPage != 1{
            UIView.animate(withDuration: 0.2) { [unowned self] in
                self.viewIndicator.isHidden = false
                self.indicator.startAnimating()
            }
        }
        Webservices().request(with: params, method: .post, endPoint: EndPoints.search, type: Trending.self, loader: currentPage == 1 ? true : false, success: {[weak self] (success) in
            AppUtilities.shared().removeNoDataLabelFrom(view: self?.view ?? UIView())
            self?.refreshController.endRefreshing()
//            self?.refreshController.attributedTitle = NSAttributedString(string: "Pull To Refresh.", attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
            UIView.animate(withDuration: 0.2) {
                self?.viewIndicator.isHidden = true
                self?.indicator.stopAnimating()
            }
            guard let response = success as? Trending else {return}
            if let search = response.post{
                if self?.currentPage == 1{
                    self?.arrSearch = []
                }
                if search.count != 0{
                    self?.loadMore = true
                }
                self?.arrSearch.append(contentsOf: search)
                AppDelegate.shared.totalData = self?.arrSearch.count ?? 0
                if self?.arrSearch.count == 0{
                    AppUtilities.shared().showNoDataLabelwith(message: "No search result found with\n\((self?.searchBar.text)!).", in: self?.view ?? UIView())
                }
                if self?.currentPage == 1{
                    self?.collectionCategory.reloadData()
                    return
                }
                let lastSection = self?.collectionCategory.numberOfSections ?? 0
                let itemsInLastSection = self?.collectionCategory.numberOfItems(inSection: lastSection-1) ?? 0
                
                var section = lastSection
                var index = itemsInLastSection
                var indexPaths:[IndexPath] = []
                var store = true
                var sections:[Int] = []
                for _ in 0..<search.count{
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
                self?.collectionCategory.performBatchUpdates({
                    self?.collectionCategory.insertItems(at: indexPaths)
                    self?.collectionCategory.insertSections(indexSet)
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

//MARK: - BANNER DELEGATES
extension CategoryVC:CategoryHeaderDelegate{
    func viewAllLiveWallpaper() {
        let vc = AllCategoryVC.controller()
        vc.arrWallPapers = self.arrBanners
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func viewAllWallpaper() {
        self.tabBarController?.selectedIndex = 1
    }
    
    func openCategory(category: String) {
        let vc = SimilarCatVC.controller()
        vc.category = category
        vc.postType = .live
        navigationController?.pushViewController(vc, animated: true)
    }
}


//MARK: - SEEARCHBAR DELEGATES
extension CategoryVC:UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.trim() == ""{
            AppUtilities.shared().removeNoDataLabelFrom(view: self.view)
            isSearching = false
            self.collectionCategory.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        AppUtilities.shared().removeNoDataLabelFrom(view: self.view)
        if searchBar.text?.trim() != ""{
            isSearching = true
            serviceForSearchList()
        }
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        AppUtilities.shared().removeNoDataLabelFrom(view: self.view)
        isSearching = false
        self.collectionCategory.reloadData()
        searchBar.resignFirstResponder()
    }
}
