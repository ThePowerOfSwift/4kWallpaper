//
//  Constants.swift
//  4kWallpaper
//
//  Created by Dixit Rathod on 03/05/20.
//  Copyright © 2020 Dixit Rathod. All rights reserved.
//

import Foundation

var fcmToken = ""

/**Interstitial Ads Id**/
enum InterstitalIds:String{
    case live = "ca-app-pub-1625565704226796/8146281541"
    case test = "ca-app-pub-3940256099942544/4411468910"
}

/**Interstitial Ads Id**/
enum NativeAdsId:String {
    case live = "ca-app-pub-1625565704226796/9098123339"
    case test = "ca-app-pub-3940256099942544/3986624511"
}

/**Rewarded Ads Id**/
enum RewardedIds:String{
    case live = "ca-app-pub-1625565704226796/7694849234"
    case test = "ca-app-pub-3940256099942544/1712485313"
}

let googleAdmobAppId = "ca-app-pub-1625565704226796~7216343259"
let interstitialAddUnitId = InterstitalIds.test.rawValue
let nativeAdUnitId = NativeAdsId.test.rawValue
let rewardedAdUnitId = RewardedIds.test.rawValue

let modelNumber = UIDevice().type.rawValue
let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
let osVersion = UIDevice.current.systemVersion
var forcefullyUpdate = false
var userId = 0
var kAddFrequency = 1
var isSubscribed = false
var frequencyTime = 0
var totalAdsCount = 0
var showInterstitial = true
var interstitialCount = 0
var adsSlot = 0
var showInAppOnLive = false
var kActivity = 0{
    didSet{
        if !showInterstitial{
            kActivity = 0
        }
        if kActivity >= kAddFrequency, !isSubscribed{//Show ads after given activity
            print("Show interstitial")
            kActivity = 0
            interstitialCount += 1 //Increase ads interstitial count for frequency time calculate
            
            AppDelegate.shared.showInterstitial()
//            if interstitialCount >= kAddFrequency{// if interestitial count match then calculate freq time
//                interstitialCount = 0
//                adsSlot += 1 //don't show interestitial after given slots
//                showInterstitial = false
//            }
            if interstitialCount <= totalAdsCount{ //wait for frequency time for next ads slot
                print("start timer")
                AppUtilities.shared().calculateAdFrequencyTime()
            }
            else{
                showInterstitial = false
            }
        }
    }
}
var kAdsDifference = 12
var appStoreId = "1512637571"
let appStoreLink = "https://apps.apple.com/in/app/id\(appStoreId)"

let kReportMailId = "4kwallpaper18@gmail.com"
let kTermsUrl = "https://4kwallpaper.online/terms.html"
let kPrivacyUrl = "https://4kwallpaper.online/privacy_policy.html"

struct ImageBase {
    static let wpSmall =        "https://cdn.4kwallpaper.online/small/"
    static let wpThumb =        "https://cdn.4kwallpaper.online/thumb/"
    static let wpHD =           "https://cdn.4kwallpaper.online/hd/"
    static let wpUHD =          "https://cdn.4kwallpaper.online/uhd/"
    static let wpsmallWebP =    "https://cdn.4kwallpaper.online/small_webp/"
    static let wpThumbWebP =    "https://cdn.4kwallpaper.online/thumb_webp/"
    static let livePng =        "https://cdn.4kwallpaper.online/liveimg/"
    static let liveJpg =        "https://cdn.4kwallpaper.online/live/"
    static let liveWebp =        "https://cdn.4kwallpaper.online/liveimg_webp/"
    static let categoryPng =    "https://cdn.4kwallpaper.online/category/"
    static let categoryWebp =   "https://cdn.4kwallpaper.online/category_webp/"
}

enum PostType:String {
    case live = "live_wallpaper"
    case wallpaper = "wallpaper"
}

struct CellIdentifier {
    static let dashWallpaperView = "DashboardCollectionView"
    static let dashCategory = "DashboardCategoryCell"
    static let wallpaper = "WallpaperCell"
    static let bannerCell = "BannerCell"
    static let categoryHeader = "CategoryHeader"
    static let categoryCell = "CatCell"
    static let allCategory = "AllCategoryVC"
    static let settingsCell = "SettingsCell"
    static let homeHeader = "HomeHeader"
}

struct NotificationKeys {
    static let updatedAds = "UpdatedAds"
    static let purchaseSuccess = "PurchaseSuccess"
    static let userIdUpdated = "UserIdUpdated"
}

struct ControllerIds {
    static let wallPaperGrid = "WallPaperGridVC"
    static let previewVC = "PreviewVC"
    static let loadingView = "LoadingView"
    static let similarCategory = "SimilarCatVC"
    static let report = "ReportVC"
    static let trending = "TrendingVC"
    static let subscription = "SubscriptionVC"
    static let webvVC = "WebVC"
    static let about = "AboutUsVC"
}

struct StoryboardIds {
    static let main = "Main"
}

struct DefaultKeys {
    static let userId = "UserId"
}
