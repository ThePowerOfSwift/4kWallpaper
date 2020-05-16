//
//  SimilarCatVC.swift
//  4kWallpaper
//
//  Created by Dixit Rathod on 10/05/20.
//  Copyright © 2020 Dixit Rathod. All rights reserved.
//

import UIKit

class SimilarCatVC: UIViewController {
    @IBOutlet weak var collectionWallPapers:UICollectionView!
    @IBOutlet weak var viewIndicator:UIView!
    @IBOutlet weak var indicator:UIActivityIndicatorView!
    
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

}

//MARK: - CUSTOM METHODS
extension SimilarCatVC{
    fileprivate func setupData(){
        self.title = category
        //Collection Methods
        self.collectionWallPapers.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        self.collectionWallPapers.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer")
        let nib = UINib(nibName: CellIdentifier.wallpaper, bundle: nil)
        collectionWallPapers.register(nib, forCellWithReuseIdentifier: CellIdentifier.wallpaper)
        
        //API call
        serviceForTrendingList()
        
        //Refresh Controlls
        refreshController.attributedTitle = NSAttributedString(string: "Pull To Refresh.", attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
        refreshController.addTarget(self, action: #selector(didRefreshCollection(_:)), for: .valueChanged)
        refreshController.tintColor = .white
        self.collectionWallPapers.refreshControl = refreshController
        
        //Observers
        NotificationCenter.default.addObserver(self, selector: #selector(updatedAds), name: Notification.Name(rawValue: NotificationKeys.updatedAds), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatedAds), name: NSNotification.Name(rawValue: NotificationKeys.purchaseSuccess), object: nil)
    }
    
    
    @objc fileprivate func updatedAds(){
        self.collectionWallPapers.reloadData()
    }
    
    @objc fileprivate func didRefreshCollection(_ sender:UIRefreshControl){
        currentPage = 1
        refreshController.attributedTitle = NSAttributedString(string: "Refreshing...", attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
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
        let width = collectionView.bounds.size.width/3
        return CGSize(width: width, height: width*1.8)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        kActivity += 1
        let index = indexPath.section*kAdsDifference
        let obj = arrTrendings[index + indexPath.row]
        let vc = PreviewVC.controller()
        vc.post = obj
        vc.type = postType.rawValue
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if isSubscribed{
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
            footerView.clipsToBounds = true
            if AppDelegate.shared.adsArr.count > indexPath.section
            {
                footerView.viewWithTag(25)?.removeFromSuperview()
                let add = AppDelegate.shared.adsArr[indexPath.section]
                add.tag = 25
                footerView.addSubview(add)
                add.clipsToBounds = true
                add.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    add.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 0),
                    add.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: 0),
                    add.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 10),
                    add.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -10)
                ])
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
        UIView.animate(withDuration: 0.2) { [unowned self] in
            self.viewIndicator.isHidden = false
            self.indicator.startAnimating()
        }
        Webservices().request(with: params, method: .post, endPoint: postType == .live ? EndPoints.live : EndPoints.postList, type: Trending.self, loader: false, success: {[weak self] (success) in
            AppUtilities.shared().removeNoDataLabelFrom(view: self?.view ?? UIView())
            
            self?.refreshController.endRefreshing()
            self?.refreshController.attributedTitle = NSAttributedString(string: "Pull To Refresh.", attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
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
