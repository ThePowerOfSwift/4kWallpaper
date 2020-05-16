//
//  CategoryVC.swift
//  4kWallpaper
//
//  Created by Dixit Rathod on 06/05/20.
//  Copyright © 2020 Dixit Rathod. All rights reserved.
//

import UIKit

class CategoryVC: UIViewController {
    @IBOutlet weak var collectionCategory:UICollectionView!
    @IBOutlet weak var searchBar:UISearchBar!
    @IBOutlet weak var viewIndicator:UIView!
    @IBOutlet weak var indicator:UIActivityIndicatorView!
    
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

//MARK: - CUSTOM METHODS
extension CategoryVC{
    fileprivate func setupView(){
        //register nib
        collectionCategory.register(UINib(nibName: CellIdentifier.categoryHeader, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CellIdentifier.categoryHeader)
        collectionCategory.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer")
        collectionCategory.register(UINib(nibName: CellIdentifier.categoryCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.categoryCell)
        let nib = UINib(nibName: CellIdentifier.wallpaper, bundle: nil)
        collectionCategory.register(nib, forCellWithReuseIdentifier: CellIdentifier.wallpaper)
        
        //Refresh Controlls
        refreshController.attributedTitle = NSAttributedString(string: "Pull To Refresh.", attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
        refreshController.addTarget(self, action: #selector(didRefreshCollection(_:)), for: .valueChanged)
        refreshController.tintColor = .white
        self.collectionCategory.refreshControl = refreshController
        
        //Observers
        NotificationCenter.default.addObserver(self, selector: #selector(updatedAds), name: Notification.Name(rawValue: NotificationKeys.updatedAds), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatedAds), name: NSNotification.Name(rawValue: NotificationKeys.purchaseSuccess), object: nil)
        
        serviceForCategory()
    }
    
    @objc fileprivate func updatedAds(){
        self.collectionCategory.reloadData()
    }
    
    @objc fileprivate func didRefreshCollection(_ sender:UIRefreshControl){
        
        refreshController.attributedTitle = NSAttributedString(string: "Refreshing...", attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
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
            let width = collectionView.bounds.size.width/3
            return CGSize(width: width, height: width*1.8)
        }
        let width = collectionView.bounds.size.width/2
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        kActivity += 1
        if isSearching{
            let index = indexPath.section*kAdsDifference
            let obj = arrSearch[index + indexPath.row]
            let vc = PreviewVC.controller()
            vc.post = obj
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
            if isSubscribed{
                return CGSize.zero
            }
            return CGSize(width: collectionView.frame.size.width, height: 200)
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
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
            if isSubscribed{
                return footerView
            }
            if isSearching{
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
            self?.refreshController.attributedTitle = NSAttributedString(string: "Pull To Refresh.", attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
            
            guard let response = success as? Category else {return}
            if let data = response.data{
                
                self?.arrWallPapers = data.wallpaper ?? []
                self?.arrBanners = data.liveWallpaper ?? []
                self?.collectionCategory.reloadData()
                
            }
            
        }) {[weak self] (failer) in
            guard let vc = self else {return}
            AppUtilities.shared().showAlert(with: failer, viewController: vc)
        }
    }
    
    fileprivate func serviceForSearchList(){
        let params:[String:Any] = [
            Parameters.user_id:userId,
            Parameters.page:currentPage,
            Parameters.search:searchBar.text!
        ]
        loadMore = false
        UIView.animate(withDuration: 0.2) { [unowned self] in
            self.viewIndicator.isHidden = false
            self.indicator.startAnimating()
        }
        Webservices().request(with: params, method: .post, endPoint: EndPoints.search, type: Trending.self, loader: false, success: {[weak self] (success) in
            AppUtilities.shared().removeNoDataLabelFrom(view: self?.view ?? UIView())
            self?.refreshController.endRefreshing()
            self?.refreshController.attributedTitle = NSAttributedString(string: "Pull To Refresh.", attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
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
                self?.collectionCategory.reloadData()
                
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
