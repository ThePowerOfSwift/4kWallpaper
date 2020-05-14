//
//  AppUtilities.swift
//  Banaji
//
//  Created by Dixit Rathod on 31/03/20.
//  Copyright © 2020 Sassy Infotech. All rights reserved.
//

import Foundation
import UIKit

class AppUtilities{
    let kAppName = "4kWallpaper"
    
    class func shared() -> AppUtilities{
        return AppUtilities()
    }
    
    func showAlert(with message:String, okTitle:String = "OK", isConfirmation:Bool = false, viewController:UIViewController,okAction:((UIAlertAction) -> Void)? = nil)
    {
        
        let alert = UIAlertController(title: kAppName, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: okTitle, style: .default) { (action) in
            if let ok = okAction{
                ok(action)
            }
            
        }
        alert.addAction(ok)
        if isConfirmation
        {
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancel)
        }
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func addLoaderView(view:UIView){
        view.viewWithTag(10)?.removeFromSuperview()
        let loading = LoadingView.mainView()
        view.addSubview(loading)
        loading.translatesAutoresizingMaskIntoConstraints = false
        loading.tag = 10
        NSLayoutConstraint.activate([
            loading.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            loading.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            loading.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            loading.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
    }
    
    func setLoaderProgress(view:UIView, downloaded:Double, total:Double, isProgress:Bool = false){
        guard let loading = view.viewWithTag(10) as? LoadingView else {return}
        
        if !isProgress{
            let progress = (downloaded*100)/total
            loading.lblPercentage.text = String(format: "%.1f", progress)
            loading.progress.progress = Float(progress/100)
            
            loading.lblSize.text = getSizeText(size: downloaded) + "/" + getSizeText(size: total)
        }
        else{
            let progress = downloaded/total
            loading.lblPercentage.text = String(format: "%.1f", progress)
            loading.progress.progress = Float(progress)
            loading.lblSize.text = ""
        }
    }
    
    func getSizeText(size:Double) -> String{
        if size > 1048576{
            return String(format: "%.2f MB", size/1048576)
        }
        else if size > 1024{
            return String(format: "%.2f KB", size/1024)
        }
        else{
            return String(format: "%.2f Byte", size)
        }
    }
    
    func removeLoaderView(view:UIView){
        view.viewWithTag(10)?.removeFromSuperview()
    }
    
    
    func resetAllValues(){
    }
    
    func compressedImageData(image:UIImage, compression:CGFloat = 1.0) -> Data?{
        
        let imgData = NSData(data: image.jpegData(compressionQuality: compression) ?? Data())
        let imageSize: Int = imgData.count/1024
        print("actual size of image in KB: %d ", imageSize)
        if imageSize >= 100, compression > 0.1{
            let _ = compressedImageData(image: image, compression:(compression - 0.1))
        }
        return imgData as Data
    }
    
    func showLoader(in view:UIView)
    {
        UIApplication.shared.beginIgnoringInteractionEvents()
        view.viewWithTag(32)?.removeFromSuperview()
        let activity = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activity.center = CGPoint(x: UIScreen.main.bounds.size.width/2, y: UIScreen.main.bounds.size.height/2)
        activity.hidesWhenStopped = true
        activity.tag = 32
        activity.style = .whiteLarge
//        activity.transform = CGAffineTransform.init(scaleX: 2.5, y: 2.5)
        activity.startAnimating()
        view.addSubview(activity)
    }
    

    func hideLoader(from view:UIView)
    {
        if let activity = view.viewWithTag(32) as? UIActivityIndicatorView
        {
            UIApplication.shared.endIgnoringInteractionEvents()
            activity.stopAnimating()
        }
    }
    
    func showNoDataLabelwith(message:String, in view:UIView)
    {
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        lbl.text = message
        lbl.textColor = UIColor.lightGray
        lbl.tag = 23
        view.addSubview(lbl)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lbl.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            lbl.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0)
            ])
    }

    func removeNoDataLabelFrom(view:UIView)
    {
        view.viewWithTag(23)?.removeFromSuperview()
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9-]+[.][A-Za-z]{2,64}$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func hasAlphabets(str:String) -> Bool{
        let letters = NSCharacterSet.letters

        let range = str.rangeOfCharacter(from: letters)

        // range will be nil if no letters is found
        if range  != nil{
            return true
        }
        else {
            return false
        }
    }
    
    func getMainWindow() -> UIWindow?{
        if #available(iOS 13.0, *) {
            if let window = UIApplication.shared.keyWindow?.windowScene?.delegate as? SceneDelegate{
                return window.window
            }
            
        } else {
            if let window = UIApplication.shared.delegate as? AppDelegate{
                return window.window
            }
            // Fallback on earlier versions
        }
        return nil
    }
    
    func setInDefault<T:Codable>(key:String, type:T.Type, data:T)
    {
        do {
            let encoder = JSONEncoder()
            let encodeData = try encoder.encode(data)
            let dict:[String:Any] = try JSONSerialization.jsonObject(with: encodeData, options: .allowFragments) as! [String : Any]
            
            //archive object to handle null values
            let data = NSKeyedArchiver.archivedData(withRootObject: dict)
            //set user data in defaults
            UserDefaults.standard.set(data, forKey: key)
            UserDefaults.standard.synchronize()
        }
        catch
        {
            print(error)
        }
    }

    func getFromDefault<T:Codable>(key:String,type:T.Type) -> T?
    {
        let archieved = UserDefaults.standard.value(forKey: key)
        let dict = NSKeyedUnarchiver.unarchiveObject(with: archieved as? Data ?? Data())
        let decoder = JSONDecoder()
        do{
            if let dic = dict
            {
                let data = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
                return try decoder.decode(type, from: data)
            }
            
        }
        catch
        {
            print(error)
        }
        return nil
    }
    
    class func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
