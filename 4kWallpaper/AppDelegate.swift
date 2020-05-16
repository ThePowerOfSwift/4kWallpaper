//
//  AppDelegate.swift
//  4kWallpaper
//
//  Created by Dixit Rathod on 03/05/20.
//  Copyright © 2020 Dixit Rathod. All rights reserved.
//

import UIKit
import Kingfisher
import KingfisherWebP
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    class var shared:AppDelegate{
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    //For Interstitial
    var interstitial: GADInterstitial!
    
    //For Native Ads
    var adLoader: GADAdLoader!
    var nativeAdView: GADUnifiedNativeAdView!
    var adsArr:[GADUnifiedNativeAdView] = []
    var totalData = 0{
        didSet{
            loadAds()
        }
    }
    
    let inAppManager = InAppManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        manageNavigationBar()
        
        
        KingfisherManager.shared.defaultOptions += [
            .processor(WebPProcessor.default),
            .cacheSerializer(WebPSerializer.default)
        ]
        
        //For Webp images
        let modifier = AnyModifier { request in
            var req = request
            req.addValue("image/webp */*", forHTTPHeaderField: "Accept")
            return req
        }
        
        KingfisherManager.shared.defaultOptions += [
            .requestModifier(modifier),
            // ... other options
        ]
        
        //Innitial Webservices
        if let id = UserDefaults.standard.value(forKey: DefaultKeys.userId) as? Int{
            userId = id
        }
        else{
            Webservices().serviceForAddUser()
        }
        Webservices().serviceForAppConfig()
        
        //Interstitial Ads Integration
        interstitial = createAndLoadInterstitial()
        
        //In App Purchase
        inAppManager.fetchProducts()
        return true
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        let addUnitId = interstitialAddUnitId
        let interstitial = GADInterstitial(adUnitID: addUnitId)
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func showInterstitial(){
        if isSubscribed{
            return
        }
        if self.interstitial.isReady {
            guard let window = AppUtilities.shared().getMainWindow(), let controller = window.rootViewController else {return}
            self.interstitial.present(fromRootViewController: controller)
        } else {
            print("Ad wasn't ready")
        }
    }
    
    func loadAds()
    {
        if isSubscribed{
            return
        }
        let adsToLoad = totalData/kAdsDifference
        let remaining = adsToLoad - adsArr.count
        if remaining > 0{
            guard let window = AppUtilities.shared().getMainWindow(), let controller = window.rootViewController else {return}
            let multipleAdsOptions = GADMultipleAdsAdLoaderOptions()
            multipleAdsOptions.numberOfAds = remaining + 1

            adLoader = GADAdLoader(adUnitID: nativeAdUnitId, rootViewController: controller,
                adTypes: [GADAdLoaderAdType.unifiedNative],
                options: [multipleAdsOptions])
            
            adLoader.delegate = self
            adLoader.load(GADRequest())
        }
    }
    
    //Custom Methods
    func manageNavigationBar(){
        if #available(iOS 13.0, *){
            
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.backgroundColor = .black
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            UINavigationBar.appearance(whenContainedInInstancesOf: [UINavigationController.self]).standardAppearance = navBarAppearance
            UINavigationBar.appearance(whenContainedInInstancesOf: [UINavigationController.self]).scrollEdgeAppearance = navBarAppearance
        }
    }
    
    
    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}


//MARK: - GOOGLE ADMOB DELEGATES
extension AppDelegate:GADInterstitialDelegate
{
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
      interstitial = createAndLoadInterstitial()
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
      print("interstitialDidReceiveAd")
    }

    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
      print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
      print("interstitialWillPresentScreen")
    }

    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
      print("interstitialWillDismissScreen")
    }

    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
      print("interstitialWillLeaveApplication")
    }
}

//MARK: - GOOGLE ADS DELEGATES
extension AppDelegate:GADUnifiedNativeAdLoaderDelegate
{
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        print(error)
    }
    
    func adLoader(_ adLoader: GADAdLoader,
                  didReceive nativeAd: GADUnifiedNativeAd) {
        print("Received unified native ad: \(nativeAd)")
//        refreshAdButton.isEnabled = true
        // Create and place ad in view hierarchy.
        let nibView = Bundle.main.loadNibNamed("UnifiedNativeAdView", owner: nil, options: nil)?.first
        guard let nativeAdView = nibView as? GADUnifiedNativeAdView else {
          return
        }
        // Associate the native ad view with the native ad object. This is
        // required to make the ad clickable.
        nativeAdView.nativeAd = nativeAd

        // Set the mediaContent on the GADMediaView to populate it with available
        // video/image asset.
        nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
        nativeAdView.mediaView?.contentMode = .scaleAspectFill
        adsArr.append(nativeAdView)
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKeys.updatedAds), object: nil)
    }

    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        // The adLoader has finished loading ads, and a new request can be sent.
    }
}

// MARK: - GADUnifiedNativeAdDelegate implementation
extension AppDelegate : GADUnifiedNativeAdDelegate {

  func nativeAdDidRecordClick(_ nativeAd: GADUnifiedNativeAd) {
    print("\(#function) called")
  }

  func nativeAdDidRecordImpression(_ nativeAd: GADUnifiedNativeAd) {
    print("\(#function) called")
  }

  func nativeAdWillPresentScreen(_ nativeAd: GADUnifiedNativeAd) {
    print("\(#function) called")
  }

  func nativeAdWillDismissScreen(_ nativeAd: GADUnifiedNativeAd) {
    print("\(#function) called")
  }

  func nativeAdDidDismissScreen(_ nativeAd: GADUnifiedNativeAd) {
    print("\(#function) called")
  }

  func nativeAdWillLeaveApplication(_ nativeAd: GADUnifiedNativeAd) {
    print("\(#function) called")
  }
}
