//
//  Constants.swift
//  4kWallpaper
//
//  Created by Dixit Rathod on 03/05/20.
//  Copyright © 2020 Dixit Rathod. All rights reserved.
//

import Foundation

var fcmToken = ""
let modelNumber = UIDevice().type
let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
let osVersion = UIDevice.current.systemVersion
var userId = 0


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

struct CellIdentifier {
    static let dashWallpaperView = "DashboardCollectionView"
    static let dashCategory = "DashboardCategoryCell"
    static let wallpaper = "WallpaperCell"
    static let bannerCell = "BannerCell"
}


struct ControllerIds {
    static let wallPaperGrid = "WallPaperGridVC"
    static let previewVC = "PreviewVC"
    static let loadingView = "LoadingView"
}

struct StoryboardIds {
    static let main = "Main"
}

struct DefaultKeys {
    static let userId = "UserId"
}
