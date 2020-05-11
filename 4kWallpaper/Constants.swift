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

let googleAdmobAppId = "ca-app-pub-1625565704226796~7216343259"
let interstitialAddUnitId = InterstitalIds.test.rawValue
let nativeAdUnitId = NativeAdsId.test.rawValue

let modelNumber = UIDevice().type
let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
let osVersion = UIDevice.current.systemVersion
var userId = 0
var kAddFrequency = 1
var kActivity = 0{
    didSet{
        if kActivity >= kAddFrequency{
            kActivity = 0
            AppDelegate.shared.showInterstitial()
        }
    }
}
var kAdsDifference = 12
var appStoreId = "284882215"
let appStoreLink = "https://apps.apple.com/in/app/facebook/id\(appStoreId)"

let kReportMailId = "4kwallpaper18@gmail.com"

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
    
}

struct NotificationKeys {
    static let updatedAds = "UpdatedAds"
}

struct ControllerIds {
    static let wallPaperGrid = "WallPaperGridVC"
    static let previewVC = "PreviewVC"
    static let loadingView = "LoadingView"
    static let similarCategory = "SimilarCatVC"
    static let report = "ReportVC"
}

struct StoryboardIds {
    static let main = "Main"
}

struct DefaultKeys {
    static let userId = "UserId"
}
