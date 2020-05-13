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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
    }

}

//MARK: - CUSTOM METHODS
extension HomeVC{
    private func setupView(){
        SKPaymentQueue.default().add(self)
    }
}

//MARK: - Storekit Delegates
extension HomeVC: SKPaymentTransactionObserver
{
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .failed:
                AppUtilities.shared().hideLoader(from: self.view)
                queue.finishTransaction(transaction)
                print("Transaction Failed")
            case .purchased:
                AppUtilities.shared().hideLoader(from: self.view)
                queue.finishTransaction(transaction)
                let _ = self.readReciept()
                let transactionID = transaction.transactionIdentifier ?? ""
                
                print("Transaction purchased \(transactionID)")
            case .restored:
                AppUtilities.shared().hideLoader(from: self.view)
                queue.finishTransaction(transaction)
                let _ = self.readReciept()
                let transactionID = transaction.transactionIdentifier ?? ""
                print("Transaction restored: \(transactionID)")
            case .deferred, .purchasing:
                AppUtilities.shared().showLoader(in: self.view)
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
