//
//  HomeHeader.swift
//  4kWallpaper
//
//  Created by Dixit Rathod on 15/05/20.
//  Copyright © 2020 Dixit Rathod. All rights reserved.
//

import UIKit
protocol HomeHeaderDelegate:AnyObject {
    func openController(vc:UIViewController)
}


class HomeHeader: UICollectionReusableView {
    @IBOutlet weak var collectionBanner:UICollectionView!
    @IBOutlet weak var collectionMissed:UICollectionView!
    @IBOutlet weak var collectionLive:UICollectionView!
    @IBOutlet weak var collectionLike:UICollectionView!
    @IBOutlet weak var pageController:UIPageControl!
    
    weak var delegate:HomeHeaderDelegate?
    var timer = Timer()
    var arrBanners:[Wallpaper] = []{
        didSet{
            collectionBanner.reloadData()
            pageController.numberOfPages = arrBanners.count
            if timer.isValid{
                timer.invalidate()
            }
            timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { (timer) in
                let indexPath = self.collectionBanner.indexPathsForVisibleItems.first
                if indexPath?.item == self.arrBanners.count-1{
                    self.collectionBanner.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
                }
                else{
                    self.collectionBanner.scrollToItem(at: IndexPath(item: (indexPath?.item ?? 0) + 1, section: 0), at: .centeredHorizontally, animated: true)
                }
            })
        }
    }
    var arrMissed:[Post] = []{
        didSet{
            collectionMissed.reloadData()
        }
    }
    var arrLiveWallpaper:[Post] = []{
        didSet{
            collectionLive.reloadData()
        }
    }
    var arrLikes:[Post] = []{
        didSet{
            collectionLike.reloadData()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let banner = UINib(nibName: CellIdentifier.bannerCell, bundle: nil)
        collectionBanner.register(banner, forCellWithReuseIdentifier: CellIdentifier.bannerCell)
        
        let missed = UINib(nibName: CellIdentifier.categoryCell, bundle: nil)
        collectionMissed.register(missed, forCellWithReuseIdentifier: CellIdentifier.categoryCell)
        
        let live = UINib(nibName: CellIdentifier.categoryCell, bundle: nil)
        collectionLive.register(live, forCellWithReuseIdentifier: CellIdentifier.categoryCell)
        
        let like = UINib(nibName: CellIdentifier.categoryCell, bundle: nil)
        collectionLike.register(like, forCellWithReuseIdentifier: CellIdentifier.categoryCell)
        // Initialization code
        if arrBanners.count == 0, arrLiveWallpaper.count == 0{
            serviceForHomeData()
        }
    }
}

//MARK: - COLLECTION DELEGATES
extension HomeHeader:UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case collectionBanner:
            return arrBanners.count
        case collectionMissed:
            return arrMissed.count
        case collectionLive:
            return arrLiveWallpaper.count
        case collectionLike:
            return arrLikes.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case collectionBanner:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.bannerCell, for: indexPath) as! BannerCell
            let wallpaper = arrBanners[indexPath.item]
            cell.lblName.text = wallpaper.name
            if let str = wallpaper.link, let url = URL(string:str){
                cell.imgBanner.kf.setImage(with: url)
            }
            DispatchQueue.main.async {
                cell.layoutIfNeeded()
                cell.viewShadow.applyGradient(location: [0.0, 1.0], startPoint: CGPoint(x: 0.0, y: 0.0), endPoint: CGPoint(x: 0.0, y: 1.0), colors: [UIColor.clear.cgColor, UIColor.black.cgColor])
            }
            return cell
        case collectionMissed:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.categoryCell, for: indexPath) as! CatCell
            let wallpaper = arrMissed[indexPath.item]
            cell.lblName.text = ""
            if let str = wallpaper.smallWebp, let url = URL(string:str){
                cell.imgWallpaper.kf.setImage(with: url)
            }
            DispatchQueue.main.async {
                cell.layoutIfNeeded()
                cell.viewGradient.applyGradient(location: [0.0, 1.0], startPoint: CGPoint(x: 0.0, y: 0.0), endPoint: CGPoint(x: 0.0, y: 1.0), colors: [UIColor.clear.cgColor, UIColor.black.cgColor])
            }
            return cell
        case collectionLive:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.categoryCell, for: indexPath) as! CatCell
            let wallpaper = arrLiveWallpaper[indexPath.item]
            cell.lblName.text = ""
            if let str = wallpaper.liveWebP, let url = URL(string:str){
                cell.imgWallpaper.kf.setImage(with: url)
            }
            DispatchQueue.main.async {
                cell.layoutIfNeeded()
                cell.viewGradient.applyGradient(location: [0.0, 1.0], startPoint: CGPoint(x: 0.0, y: 0.0), endPoint: CGPoint(x: 0.0, y: 1.0), colors: [UIColor.clear.cgColor, UIColor.black.cgColor])
            }
            return cell
        case collectionLike:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.categoryCell, for: indexPath) as! CatCell
            let wallpaper = arrLikes[indexPath.item]
            cell.lblName.text = ""
            if let str = wallpaper.smallWebp, let url = URL(string:str){
                cell.imgWallpaper.kf.setImage(with: url)
            }
            DispatchQueue.main.async {
                cell.layoutIfNeeded()
                cell.viewBg.setRounded()
                cell.viewBg.setBorder(with: UIColor.white, width: 1.0)
                cell.viewGradient.applyGradient(location: [0.0, 1.0], startPoint: CGPoint(x: 0.0, y: 0.0), endPoint: CGPoint(x: 0.0, y: 1.0), colors: [UIColor.clear.cgColor, UIColor.black.cgColor])
            }
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.categoryCell, for: indexPath) as! CatCell
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case collectionBanner:
            return collectionView.bounds.size
        case collectionMissed:
            return CGSize(width: collectionView.bounds.size.height*0.9, height: collectionView.bounds.size.height)
        case collectionLive:
            return CGSize(width: collectionView.bounds.size.height*0.8, height: collectionView.bounds.size.height)
        case collectionLike:
            return CGSize(width: collectionView.bounds.size.height, height: collectionView.bounds.size.height)
        default:
            return CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case collectionBanner:
            let banner = arrBanners[indexPath.item]
            let vc = SimilarCatVC.controller()
            vc.category = banner.name ?? ""
            self.delegate?.openController(vc: vc)
        case collectionMissed:
            let missed = arrMissed[indexPath.item]
            let vc = PreviewVC.controller()
            vc.type = PostType.wallpaper.rawValue
            vc.post = missed
            self.delegate?.openController(vc: vc)
        case collectionLive:
            let live = arrLiveWallpaper[indexPath.item]
            let vc = PreviewVC.controller()
            vc.type = PostType.live.rawValue
            vc.post = live
            self.delegate?.openController(vc: vc)
        case collectionLike:
            let like = arrLikes[indexPath.item]
            let vc = PreviewVC.controller()
            vc.type = PostType.wallpaper.rawValue
            vc.post = like
            self.delegate?.openController(vc: vc)
        default:
            print("")
        }
    }
    
}

//MARK: - SCROLLVIEW DELEGATES
extension HomeHeader{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == collectionBanner{
            let indexPath = collectionBanner.indexPathsForVisibleItems.first
            pageController.currentPage = indexPath?.item ?? 0
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == collectionBanner {
            let offset = scrollView.contentOffset.x/scrollView.bounds.size.width
            pageController.currentPage = Int(offset)
        }
    }
}

//MARK: - WEBSERVICE
extension HomeHeader{
    fileprivate func serviceForHomeData(){
        
        Webservices().request(with: [:], method: .post, endPoint: EndPoints.home, type: Home.self, loader: true, success: {[weak self] (success) in
            
            guard let response = success as? Home else {return}
            self?.arrLikes = response.youMayLikeWallpaper ?? []
            self?.arrLiveWallpaper = response.livewallpaper ?? []
            self?.arrBanners = response.banner ?? []
            self?.arrMissed = response.youMayMisedWallpaper ?? []
            
        }) {(failer) in
            guard let window = AppUtilities.shared().getMainWindow(), let vc = window.rootViewController else {return}
            AppUtilities.shared().showAlert(with: failer, viewController: vc)
        }
    }
}

//MARK: - PAGECONTROLLER
extension HomeHeader{
    @IBAction func pageControllerChange(_ sender:UIPageControl){
        collectionBanner.scrollToItem(at: IndexPath(item: sender.currentPage, section: 0), at: .centeredHorizontally, animated: true)
    }
}
