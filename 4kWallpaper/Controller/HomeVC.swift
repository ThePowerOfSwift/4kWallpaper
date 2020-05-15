//
//  HomeVC.swift
//  4kWallpaper
//
//  Created by Dixit Rathod on 11/05/20.
//  Copyright © 2020 Dixit Rathod. All rights reserved.
//

import UIKit
import StoreKit

class HomeVC: UIViewController {
    @IBOutlet weak var collectionWallPapers:UICollectionView!
    var arrTrendings:[Post] = []
    var arrBanners:[Wallpaper] = []
    var arrMissed:[Post] = []
    var arrLiveWallpaper:[Post] = []
    var arrLikes:[Post] = []
    
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
        
        //Observers
        NotificationCenter.default.addObserver(self, selector: #selector(updatedAds), name: Notification.Name(rawValue: NotificationKeys.updatedAds), object: nil)
        
        serviceForHomeData()
    }
    
    @objc fileprivate func updatedAds(){
        self.collectionWallPapers.reloadData()
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
        return CGSize(width: collectionView.frame.size.width, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CellIdentifier.homeHeader, for: indexPath) as! HomeHeader
            header.delegate = self
            header.arrBanners = self.arrBanners
            header.arrMissed = self.arrMissed
            header.arrLiveWallpaper = self.arrLiveWallpaper
            header.arrLikes = self.arrLikes
            return header
            
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
            
            footerView.clipsToBounds = true
            if AppDelegate.shared.adsArr.count > indexPath.section
            {
                let add = AppDelegate.shared.adsArr[indexPath.section]
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
    fileprivate func serviceForHomeData(){
        
        Webservices().request(with: [:], method: .post, endPoint: EndPoints.home, type: Home.self, loader: true, success: {[weak self] (success) in
            
            guard let response = success as? Home else {return}
            self?.arrTrendings = response.youMayLikeWallpaper ?? []
            self?.arrLikes = response.youMayLikeWallpaper ?? []
            self?.arrLiveWallpaper = response.livewallpaper ?? []
            self?.arrBanners = response.banner ?? []
            self?.arrMissed = response.youMayMisedWallpaper ?? []
            self?.collectionWallPapers.reloadData()
            AppDelegate.shared.totalData = self?.arrTrendings.count ?? 0
            
        }) {[weak self] (failer) in
            guard let vc = self else {return}
            AppUtilities.shared().showAlert(with: failer, viewController: vc)
        }
    }
}

//MARK: - HEADER DELEGATE
extension HomeVC:HomeHeaderDelegate{
    func openController(vc: UIViewController) {
        self.navigationController?.pushViewController(vc, animated: true)
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
                let _ = self.readReciept()
                let transactionID = transaction.transactionIdentifier ?? ""
                
                print("Transaction purchased \(transactionID)")
            case .restored:
                AppUtilities.shared().hideLoader(from: window)
                queue.finishTransaction(transaction)
                let _ = self.readReciept()
                let transactionID = transaction.transactionIdentifier ?? ""
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
