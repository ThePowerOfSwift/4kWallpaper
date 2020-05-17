//
//  Webservices.swift
//  Banaji
//
//  Created by Dixit Rathod on 30/03/20.
//  Copyright © 2020 Sassy Infotech. All rights reserved.
//

import Foundation
import Alamofire

var authorization = ""
let baseURL = "https://4kwallpaper.online/ios/"

struct Parameters {
    static let device_id = "device_id"
    static let fcm_id = "fcm_id"
    static let model_number = "model_number"
    static let app_version = "app_version"
    static let user_id = "user_id"
    static let page = "page"
    static let used_ids = "used_ids"
    static let category = "category"
    static let download = "download"
    static let like = "like"
    static let unlike = "unlike"
    static let live_w_download = "live_w_download"
    static let live_w_like = "live_w_like"
    static let live_w_unlike = "live_w_unlike"
    static let search = "search"
    static let in_app_purchase_id = "in_app_purchase_id"
    static let purchaseToken = "purchaseToken"
}

struct EndPoints {
    static let addInApp = "add_in_app_purchase.php"
    static let addUser = "add_user.php"
    static let favourite = "fav.php"
    static let addAll = "add_all.php"
    static let postList = "post_list.php"
    static let live = "live_wallpaper.php"
    static let trending = "trending.php"
    static let search = "search.php"
    static let categoryList = "category_list.php"
    static let inAppPurchaseStatus = "in_app_purchase_status.php"
    static let appList = "app_list.php"
    static let home = "home_like.php"
}

class Webservices {
    var base = ""
    
    init() {
        base = baseURL
    }
    
    func request<T:Decodable>(with params:[String:Any], method:HTTPMethod, endPoint:String, type:T.Type, loader:Bool = true, success:@escaping(Any) -> Void, failer:@escaping(String) -> Void) {
        
        var headers:HTTPHeaders = [:]
        if(authorization != ""){
            headers = [.authorization(bearerToken: authorization)]
        }
        base = base + endPoint
        let view = AppUtilities.shared().getMainWindow()
        
        if loader, view != nil{
            AppUtilities.shared().showLoader(in: view!)
        }
        debugPrint("URL : \(base)")
        debugPrint("Headers : \(headers)")
        debugPrint("Parameters : \(params)")
        
        AF.request(base, method:method, parameters: params, encoding: URLEncoding.default, headers: headers, interceptor: nil, requestModifier: nil).responseDecodable(of: type.self) { response in
            if loader, view != nil{
                AppUtilities.shared().hideLoader(from: view!)
            }
            if response.response?.statusCode == 400, let data = response.data{
                if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any], let data = json["data"] as? [String:Any]{
                    debugPrint(json)
                    for (_,value) in data{
                        if let val = value as? [String], let str = val.first{
                            failer(str)
                            break
                        }
                    }
                }
                return
            }
            if let error = response.error{
                debugPrint(error.localizedDescription)
                failer(error.localizedDescription)
            }
            
            if let data = response.data{
                do{
                    let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    debugPrint(json ?? "")
                    let decoder = JSONDecoder()
                    let resp = try decoder.decode(type, from: data)
                    success(resp)
                }
                catch{
                    debugPrint(error.localizedDescription)
                    failer(error.localizedDescription)
                }
            }
        }
    }
    
    func upload<T:Decodable>(with params:[String:Any], method:HTTPMethod, endPoint:String, type:T.Type, loader:Bool = true, success:@escaping(Any) -> Void, failer:@escaping(String) -> Void){
        
        var headers:HTTPHeaders = [:]
        
        if(authorization != ""){
            headers = [.authorization(bearerToken: authorization)]
        }
        
        base += endPoint
        let view = AppUtilities.shared().getMainWindow()
        
        if loader, view != nil{
            AppUtilities.shared().showLoader(in: view!)
        }
        debugPrint("URL : \(base)")
        debugPrint("Headers : \(headers)")
        debugPrint("Parameters : \(params)")
        
        AF.upload(multipartFormData: { multipartFormData in
            for (key, value) in params{
                if let data = value as? Data{
                    multipartFormData.append(data, withName: key, fileName: "\(Date()).jpg", mimeType: "image/jpeg")
                }
                else{
                    let data = String(describing: value)
                    multipartFormData.append(Data((data).utf8), withName: key)
                }
            }
        }, to: base, headers: headers)
            .uploadProgress { progress in
                print("Upload Progress: \(progress.fractionCompleted)")
        }
        .downloadProgress { progress in
            print("Download Progress: \(progress.fractionCompleted)")
        }
        .responseDecodable(of: type.self) { response in
            debugPrint("Response: \(response)")
            if loader, view != nil{
                AppUtilities.shared().hideLoader(from: view!)
            }
            if response.response?.statusCode == 400, let data = response.data{
                if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]{
                    for (_,value) in json{
                        if let val = value as? [String], let str = val.first{
                            failer(str)
                            break
                        }
                    }
                }
                return
            }
            if let error = response.error{
                debugPrint(error.localizedDescription)
                failer(error.localizedDescription)
            }
            if let data = response.data{
                do{
                    let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    print(json ?? "")
                    let decoder = JSONDecoder()
                    let resp = try decoder.decode(type, from: data)
                    success(resp)
                }
                catch{
                    debugPrint(error.localizedDescription)
                    failer(error.localizedDescription)
                }
            }
            
        }
    }
    
    func download(with url:String,  loader:Bool = true, downloaded:@escaping(Double) -> Void, success:@escaping(Any) -> Void, failer:@escaping(String) -> Void){
        
//        let view = AppUtilities.shared().getMainWindow()
//
//        if loader, view != nil{
//            AppUtilities.shared().showLoader(in: view!)
//        }
        AF.download(url)
        .downloadProgress { progress in
            downloaded(progress.fractionCompleted)
//            print("Download Progress: \(progress.fractionCompleted)")
        }
        .responseData { response in
//            AppUtilities.shared().hideLoader(from: view!)
            if let data = response.value {
                success(data)
            }
            else{
                failer(response.error?.localizedDescription ?? "")
            }
        }
    }
}

//MARK: - COMMON METHODS
extension Webservices{
    open func serviceForAddUser(){
        let params:[String:Any] = [
            Parameters.device_id:deviceId,
            Parameters.app_version:appVersion,
            Parameters.fcm_id:fcmToken,
            Parameters.model_number:modelNumber
            
        ]
        self.request(with: params, method: .post, endPoint: EndPoints.addUser, type: AddUser.self, loader: false, success: { (success) in
            guard let user = success as? AddUser else {return}
            if let uid = user.userId{
                userId = uid
                UserDefaults.standard.set(uid, forKey: DefaultKeys.userId)
            }
            
        }) { (failer) in
            if let vc = AppUtilities.shared().getMainWindow()?.rootViewController{
                AppUtilities.shared().showAlert(with: failer, viewController: vc)
            }
            
        }
    }
    
    open func serviceForAppConfig(){
        let params:[String:Any] = [:]
        self.request(with: params, method: .post, endPoint: EndPoints.appList, type: AppConfig.self, loader: false, success: { (success) in
            guard let response = success as? AppConfig else {return}
            if let status = response.status, status == 1, let data = response.appList{
                
                //Force Update
                if let forceUpdate = data.forceUpdate, let version = data.appVersion, version != appVersion{
                    forcefullyUpdate = forceUpdate == "1"
                    guard let window = AppUtilities.shared().getMainWindow(), let controller = window.rootViewController else {
                        return
                    }
                    AppUtilities.shared().showAlert(with: "Please update your application to get better experience and new features", isConfirmation: forceUpdate != "1", viewController: controller){(action) in
                        
                        if let url = URL(string: appStoreLink), UIApplication.shared.canOpenURL(url){
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }
                
                //Interstital Condition
                if let addFrequeny = data.adFreqCount, let count = Int(addFrequeny){
                    kAddFrequency = count
                }
                
                if let totalAds = data.totalAdCount, let count = Int(totalAds){
                    totalAdsCount = count
                }
                
                if let frequency = data.adFreqTime, let time = Int(frequency){
                    frequencyTime = time/1000
                }
                
                if let disableAds = data.adDisable, disableAds == "1"{
                    isSubscribed = true
                }
                
                if let inApp = data.inApp, inApp == "1"{
                    showInAppOnLive = true
                }
            }
            
        }) { (failer) in
            if let vc = AppUtilities.shared().getMainWindow()?.rootViewController{
                AppUtilities.shared().showAlert(with: failer, viewController: vc)
            }
            
        }
    }
}
