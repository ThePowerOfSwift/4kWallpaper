//
//  HomeVC.swift
//  4kWallpaper
//
//  Created by Dixit Rathod on 11/05/20.
//  Copyright © 2020 Dixit Rathod. All rights reserved.
//

import UIKit
import StoreKit
import Kingfisher

class HomeVC: UIViewController {
    @IBOutlet weak var collectionWallPapers:UICollectionView!
    @IBOutlet weak var viewIndicator:UIView!
    @IBOutlet weak var indicator:UIActivityIndicatorView!
    var arrTrendings:[Post] = []
    var currentPage = 1
    var loadMore = true
    var refreshController = UIRefreshControl()
    
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
    
    override func didReceiveMemoryWarning() {
        KingfisherManager.shared.cache.clearDiskCache()
        KingfisherManager.shared.cache.clearMemoryCache()
    }
}

//MARK: - CUSTOM METHODS
extension HomeVC{
    private func setupView(){
        //In app purchase
        SKPaymentQueue.default().add(self)
        
        //Collection Methods
        let header = UINib(nibName: CellIdentifier.homeHeader, bundle: nil)
        self.collectionWallPapers.register(header, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CellIdentifier.homeHeader)
        self.collectionWallPapers.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer")
        let nib = UINib(nibName: CellIdentifier.wallpaper, bundle: nil)
        collectionWallPapers.register(nib, forCellWithReuseIdentifier: CellIdentifier.wallpaper)
        
        //Refresh Controlls
        refreshController.attributedTitle = NSAttributedString(string: "Pull To Refresh.", attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
        refreshController.addTarget(self, action: #selector(didRefreshCollection(_:)), for: .valueChanged)
        refreshController.tintColor = .white
        self.collectionWallPapers.refreshControl = refreshController
        
        //Observers
        NotificationCenter.default.addObserver(self, selector: #selector(updatedAds), name: Notification.Name(rawValue: NotificationKeys.updatedAds), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatedAds), name: NSNotification.Name(rawValue: NotificationKeys.purchaseSuccess), object: nil)
        
        serviceForPostList()
        serviceForInAppStatus()
    }
    
    @objc fileprivate func updatedAds(){
        self.collectionWallPapers.reloadData()
    }
    
    @objc fileprivate func didRefreshCollection(_ sender:UIRefreshControl){
        currentPage = 1
        refreshController.attributedTitle = NSAttributedString(string: "Refreshing...", attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
        serviceForPostList()
    }
}

//MARK: - COLLECTION DELEGATES
extension HomeVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
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
        
        if let strUrl = obj.smallWebp, let url = URL(string: strUrl){
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
        if showInAppOnLive, !isSubscribed, obj.type == PostType.live.rawValue{
            self.navigationController?.pushViewController(SubscriptionVC.controller(), animated: true)
            return
        }
        let vc = PreviewVC.controller()
        vc.post = obj
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0{
            return CGSize(width: collectionView.frame.size.width, height: 950)
        }
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
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CellIdentifier.homeHeader, for: indexPath) as! HomeHeader
            header.delegate = self
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
extension HomeVC{
    fileprivate func serviceForPostList(){
        let params:[String:Any] = [
            Parameters.user_id:userId,
            Parameters.page:currentPage,
            Parameters.used_ids:arrTrendings.compactMap({$0.postId}).joined(separator: ",")
        ]
        loadMore = false
        UIView.animate(withDuration: 0.2) { [unowned self] in
            self.viewIndicator.isHidden = false
            self.indicator.startAnimating()
        }
        Webservices().request(with: params, method: .post, endPoint:EndPoints.postList, type: Trending.self, loader: false, success: {[weak self] (success) in
            AppUtilities.shared().removeNoDataLabelFrom(view: self?.view ?? UIView())
            self?.refreshController.endRefreshing()
            self?.refreshController.attributedTitle = NSAttributedString(string: "Pull To Refresh.", attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
            UIView.animate(withDuration: 0.2) {
                self?.viewIndicator.isHidden = true
                self?.indicator.stopAnimating()
            }
            guard let response = success as? Trending else {return}
            if let trendings =  response.post{
                if self?.currentPage == 1{
                    self?.arrTrendings = []
                }
                if trendings.count != 0{
                    self?.loadMore = true
                }
                self?.arrTrendings.append(contentsOf: trendings)
                AppDelegate.shared.totalData = self?.arrTrendings.count ?? 0
                if self?.arrTrendings.count == 0{
                    AppUtilities.shared().showNoDataLabelwith(message: "No Data available.", in: self?.view ?? UIView())
                }
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
    
    private func serviceForUpdatePurchase(params:[String:Any]){
        Webservices().request(with: params, method: .post, endPoint: EndPoints.addInApp, type: AddUser.self, success: { (success) in
            guard let response = success as? AddUser else {return}
            if let status = response.status, status == 1{
//                guard let window = AppUtilities.shared().getMainWindow(), let vc = window.rootViewController else {return}
                self.serviceForInAppStatus()
            }
        }) { (failer) in
            AppUtilities.shared().showAlert(with: failer, viewController: self)
        }
    }
    
    private func serviceForInAppStatus(){
        let params:[String:Any] = [
            Parameters.user_id:userId
        ]
        Webservices().request(with: params, method: .post, endPoint: EndPoints.inAppPurchaseStatus, type: InAppPurchase.self, success: { (success) in
            guard let response = success as? InAppPurchase else {return}
            if let status = response.status, status == 1, let purchase = response.inAppPurchase{
                let time = Double(purchase.inAppPurchaseTime ?? "")
                let date = Date().addingTimeInterval(time ?? 0.0)
                print(date.toDate(format: "dd-MM-yyyy"))
                if purchase.inAppPurchase == "1"{
                    isSubscribed = true
                    NotificationCenter.default.post(name: Notification.Name(NotificationKeys.purchaseSuccess), object: nil)
                }
            }
        }) { (failer) in
            AppUtilities.shared().showAlert(with: failer, viewController: self)
        }
    }
}

//MARK: - HEADER DELEGATE
extension HomeVC:HomeHeaderDelegate{
    func openController(vc: UIViewController) {
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - SCROLLVIEW DELEGATE
extension HomeVC{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionWallPapers{
            if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height, loadMore{
                currentPage += 1
                serviceForPostList()
            }
        }
    }
}

//MARK: - Storekit Delegates
extension HomeVC: SKPaymentTransactionObserver
{
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        guard let window = AppUtilities.shared().getMainWindow() else {return}
        for transaction in transactions {
            switch transaction.transactionState {
            case .failed:
                AppUtilities.shared().hideLoader(from: window)
                queue.finishTransaction(transaction)
                print("Transaction Failed")
            case .purchased:
                AppUtilities.shared().hideLoader(from: window)
                queue.finishTransaction(transaction)
                
                let reciept = self.readReciept()
                let transactionID = transaction.transactionIdentifier ?? ""
                
                //API call
                let params:[String:Any] = [
                    Parameters.in_app_purchase_id:reciept,
                    Parameters.purchaseToken:transactionID,
                    Parameters.user_id:userId
                ]
                serviceForUpdatePurchase(params: params)
                print("Transaction purchased \(transactionID)")
            case .restored:
                AppUtilities.shared().hideLoader(from: window)
                queue.finishTransaction(transaction)
                
                //API call
                let reciept = self.readReciept()
                let transactionID = transaction.transactionIdentifier ?? ""
                
                let params:[String:Any] = [
                    Parameters.in_app_purchase_id:reciept,
                    Parameters.purchaseToken:transactionID,
                    Parameters.user_id:userId
                ]
                serviceForUpdatePurchase(params: params)
                print("Transaction restored: \(transactionID)")
            case .deferred, .purchasing:
                AppUtilities.shared().showLoader(in: window)
                print("Transaction in progress: \(transaction)")
            @unknown default:
                print("Default")
            }
        }
    }
    
    private func readReciept() -> String
    {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            
            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
//                print(receiptData)
                
                let receiptString = receiptData.base64EncodedString(options: [])
                print("Receipt string is : \(receiptString)")
                return receiptString
                // Read ReceiptData
            }
            catch { print("Couldn't read receipt data with error: " + error.localizedDescription) }
        }
        return ""
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        /*for transaction in queue.transactions {
         switch transaction.transactionState {
         case .failed:
         hideLoader()
         queue.finishTransaction(transaction)
         print("Transaction Failed \(transaction)")
         showAlertWith("Free Table", message: transaction.error?.localizedDescription ?? "Transaction Failed, Please try again.", isConfirmation: false, yesTitle: "Ok", noTitle: "", delegate: self.window!.rootViewController!, yesTag: 0, noTag: 0)
         case .purchased, .restored:
         hideLoader()
         queue.finishTransaction(transaction)
         readReciept()
         needSubscription = 0
         print("Transaction purchased or restored: \(transaction)")
         case .deferred, .purchasing:
         showLoader()
         print("Transaction in progress: \(transaction)")
         }
         }*/
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        AppUtilities.shared().showAlert(with: error.localizedDescription, viewController: self)
    }
}
