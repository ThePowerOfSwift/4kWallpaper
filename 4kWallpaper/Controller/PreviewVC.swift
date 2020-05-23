//
//  PreviewVC.swift
//  4kWallpaper
//
//  Created by Dixit Rathod on 07/05/20.
//  Copyright © 2020 Dixit Rathod. All rights reserved.
//

import UIKit
import Kingfisher
import Photos
import PhotosUI
import AVFoundation
import GoogleMobileAds
import MessageUI

class PreviewVC: UIViewController {
    @IBOutlet weak var imgWallpaper:UIImageView!
    @IBOutlet weak var btnFavourite:UIButton!
    @IBOutlet weak var btnDownload:UIButton!
    @IBOutlet weak var btnMore:UIButton!
    @IBOutlet weak var btnReport:UIButton!
    @IBOutlet weak var btnCategory:UIButton!
    @IBOutlet weak var btnShare:UIButton!
    @IBOutlet weak var lblReport:UILabel!
    @IBOutlet weak var lblCategory:UILabel!
    @IBOutlet weak var viewCategory:UIView!
    @IBOutlet weak var viewShare:UIView!
    @IBOutlet weak var viewReport:UIView!
    @IBOutlet weak var stackMore:UIStackView!
    @IBOutlet weak var livePhotos:PHLivePhotoView!
    @IBOutlet weak var bannerView:GADBannerView!
    var player: AVPlayer?
    
    var post:Post?
    var type:String = ""
    var previewImage:UIImage?
    var hdSize:String = "0"
    var uHdSize:String = "0"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layoutIfNeeded()
        setupView()
        setupData()
        // Do any additional setup after loading the view.
    }
    
    class func controller() -> PreviewVC{
        let story = UIStoryboard(name: StoryboardIds.main, bundle: nil)
        return story.instantiateViewController(withIdentifier: ControllerIds.previewVC) as! PreviewVC
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isSubscribed{
            bannerView.isHidden = true
        }
        else{
            AppUtilities.shared().loadBannerAd(in: self.bannerView, view: self.view)
        }
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to:size, with:coordinator)
        coordinator.animate(alongsideTransition: { _ in
            AppUtilities.shared().loadBannerAd(in: self.bannerView, view: self.view)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

//MARK: - CUSTOM METHODS
extension PreviewVC{
    fileprivate func setupView(){
        self.title = post?.category ?? ""
        
        btnMore.setRounded()
        btnReport.setRounded()
        btnCategory.setRounded()
        btnShare.setRounded()
        viewCategory.layer.cornerRadius = 5.0
        viewReport.layer.cornerRadius = 5.0
        viewShare.layer.cornerRadius = 5.0
        if let type = post?.type{
            self.type = type
        }
        self.imgWallpaper.image = previewImage
        
        if let wall = post, let hd = URL(string: wall.hd ?? ""), let uhd = URL(string: wall.uhd ?? ""), type != PostType.live.rawValue{
            self.getDownloadSize(url: hd) { (size, error) in
                if error != nil {return}
                self.hdSize = AppUtilities.shared().getSizeText(size: Double(size))
            }
            
            self.getDownloadSize(url: uhd) { (size, error) in
                if error != nil {return}
                self.uHdSize = AppUtilities.shared().getSizeText(size: Double(size))//String(format: "%.f", size/1048576)
            }
        }
        
        bannerView.adUnitID = bannerAdUnitId
        bannerView.rootViewController = self
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            self.serviceForAddAll(key: Parameters.download)
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    fileprivate func setupData(){
        if let wallpaper = post{
            lblCategory.text = wallpaper.category
//            btnFavourite.tintColor = wallpaper.isFav == "1" ? .red : .black
            btnFavourite.isSelected = wallpaper.isFav == "1"
            if self.type == PostType.live.rawValue{
                if let strImg = wallpaper.liveWebP, let live = wallpaper.liveVideo, let imgUrl = URL(string: strImg), let vidURL = URL(string: live){

                    self.loadVideoWithVideoURL(vidURL)
                    self.imgWallpaper.kf.setImage(with: imgUrl)
                    return
                }
                
            }
            AppUtilities.shared().addLoaderView(view: self.view)
            var wallURL:URL!
            if let strUrl = wallpaper.thumbWebp, let url = URL(string: strUrl){
                wallURL = url
            }
            else if let strUrl = wallpaper.webpThumb, let url = URL(string: strUrl){
                wallURL = url
            }
            
            KingfisherManager.shared.retrieveImage(with: wallURL, progressBlock: { (downloaded, outOf) in
                AppUtilities.shared().setLoaderProgress(view: self.view, downloaded: Double(downloaded), total: Double(outOf))
            }, downloadTaskUpdated: nil) { (result) in
                AppUtilities.shared().removeLoaderView(view: self.view)
                switch result {
                case .success(let value):
                    print("Image: \(value.image). Got from: \(value.cacheType)")
                    self.imgWallpaper.image = value.image
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
            
        }
    }
    
    func loadVideoWithVideoURL(_ videoURL: URL) {
//        livePhotoView.livePhoto = nil
        AppUtilities.shared().addLoaderView(view: self.view)
        Webservices().download(with: videoURL.absoluteString, downloaded: { (progress) in
            AppUtilities.shared().setLoaderProgress(view: self.view, downloaded: progress, total: 1.0, isProgress:true)
        }, success: { (data) in
            
            guard let urlData = data as? Data else {return}
            
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let imageURL = urls[0].appendingPathComponent("image.mov")
            do{
                try? urlData.write(to: imageURL, options: [.atomic])
                self.showLivePhoto(videoURL: imageURL)
            }
        }) { (failer) in
            AppUtilities.shared().showAlert(with: failer, viewController: self)
        }
    }
    
    func showLivePhoto(videoURL:URL){
//        let asset = AVURLAsset(url: videoURL)
//        let generator = AVAssetImageGenerator(asset: asset)
//        generator.appliesPreferredTrackTransform = true
//        let time = NSValue(time: CMTimeMakeWithSeconds(CMTimeGetSeconds(asset.duration)/2, preferredTimescale: asset.duration.timescale))
//        generator.generateCGImagesAsynchronously(forTimes: [time]) {[weak self] (cmtime, image, cmtime1, result, error) in
//            if let error = error{
//                print("Live wallpaper error : \(error)")
//                return
//            }
        if let image = imgWallpaper.image, let data = image.pngData() {
                let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                let imageURL = urls[0].appendingPathComponent("image.jpg")
                try? data.write(to: imageURL, options: [.atomic])
                
                let image = imageURL.path
                let mov = videoURL.path
                let output = FilePaths.VidToLive.livePath
                let assetIdentifier = UUID().uuidString
                let _ = try? FileManager.default.createDirectory(atPath: output, withIntermediateDirectories: true, attributes: nil)
                do {
                    try FileManager.default.removeItem(atPath: output + "/IMG.JPG")
                    try FileManager.default.removeItem(atPath: output + "/IMG.MOV")
                    
                } catch {
                    
                }
                JPEG(path: image).write(output + "/IMG.JPG",
                                        assetIdentifier: assetIdentifier)
                QuickTimeMov(path: mov).write(output + "/IMG.MOV",
                                              assetIdentifier: assetIdentifier)
//                DispatchQueue.main.async{
                    guard let view = self.view else {return}
                    AppUtilities.shared().setLoaderProgress(view: view, downloaded: 1.0, total: 1.0, isProgress:true)
//                }
                
//                _ = DispatchQueue.main.sync {
//                    guard let view = self.view else {return}
                    PHLivePhoto.request(withResourceFileURLs: [ URL(fileURLWithPath: FilePaths.VidToLive.livePath + "/IMG.MOV"), URL(fileURLWithPath: FilePaths.VidToLive.livePath + "/IMG.JPG")],
                                        placeholderImage: nil,
                                        targetSize: view.bounds.size,
                                        contentMode: PHImageContentMode.aspectFit,
                                        resultHandler: { (livePhoto, info) -> Void in
                                            
                                            AppUtilities.shared().removeLoaderView(view: view)
                                            let livePhotoView = PHLivePhotoView(frame: self.imgWallpaper.bounds)
                                            self.imgWallpaper.addSubview(livePhotoView)
                                            self.imgWallpaper.isUserInteractionEnabled = true
                                            livePhotoView.livePhoto = livePhoto
                                            livePhotoView.startPlayback(with: .full)
                                            
                    })
//                }
            }
//        }
    }
    
    func exportLivePhoto () {
        PHPhotoLibrary.shared().performChanges({ () -> Void in
            let creationRequest = PHAssetCreationRequest.forAsset()
            let options = PHAssetResourceCreationOptions()
            
            creationRequest.addResource(with: PHAssetResourceType.pairedVideo, fileURL: URL(fileURLWithPath: FilePaths.VidToLive.livePath + "/IMG.MOV"), options: options)
            creationRequest.addResource(with: PHAssetResourceType.photo, fileURL: URL(fileURLWithPath: FilePaths.VidToLive.livePath + "/IMG.JPG"), options: options)
            
            }, completionHandler: { (success, error) -> Void in
                DispatchQueue.main.async {
                    if success {
                        AppUtilities.shared().showAlert(with: "Photos downloaded successfully", viewController: self)
                    }
                    else if let error = error{
                        AppUtilities.shared().showAlert(with: error.localizedDescription, viewController: self)
                    }
                }
        })
    }
    
    
}

//MARK: - ACTION METHODS
extension PreviewVC{
    @IBAction func btnMorePressed(_ sender:UIButton){
        sender.isSelected = !sender.isSelected
        UIView.animate(withDuration: 0.2) {
            for view in self.stackMore.arrangedSubviews{
                if view.tag == 2{
                    view.isHidden = !sender.isSelected
                }
            }
        }
        
        UIView.animate(withDuration: 0.2) {
            sender.transform = sender.isSelected ? CGAffineTransform(rotationAngle: 45.0) : .identity
        }
    }
    
    @IBAction func btnShare(_ sender:UIButton){
        let image = imgWallpaper.image

        // set up activity view controller
        let imageToShare = [ image! ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash

        // exclude some activity types from the list (optional)
//        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]

        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func btnFavourite(_ sender:UIButton){
        sender.isSelected = !sender.isSelected
//        sender.tintColor = sender.isSelected ? .red : .black
        if type == PostType.live.rawValue{
            if sender.isSelected{
                serviceForAddAll(key: Parameters.live_w_like)
            }
            else{
                serviceForAddAll(key: Parameters.live_w_unlike)
            }
        }
        else{
            if sender.isSelected{
                serviceForAddAll(key: Parameters.like)
            }
            else{
                serviceForAddAll(key: Parameters.unlike)
            }
        }
    }
    
    @IBAction func btnReport(_ sender:UIButton){
        let vc = ReportVC.controller()
        vc.postId = post?.postId ?? "-"
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnCategory(_ sender:UIButton){
        let vc = SimilarCatVC.controller()
        vc.category = post?.category ?? ""
        vc.postType = PostType(rawValue: type) ?? .wallpaper
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnBackPressed(_ sender:UIButton){
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnDownload(_ sender:UIButton){
        if self.type == PostType.live.rawValue{
            if !isSubscribed, type == PostType.live.rawValue{
                if showInAppOnLive{
                    let vc = SubscriptionVC.controller()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else{
                    let vc = UnlockVC.controller()
                    vc.delegate = self
                    self.present(vc, animated: true, completion: nil)
                }
                return
            }
        }
        let controller = UIAlertController(title: "Select quality of image to download", message: nil, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "HD: \(hdSize)", style: .default, handler: { (hd) in
            if let wallpaper = self.post{
                AppUtilities.shared().addLoaderView(view: self.view)
                if let strUrl = wallpaper.hd, let url = URL(string: strUrl){
                    
                    KingfisherManager.shared.retrieveImage(with: url, progressBlock: { (downloaded, outOf) in
                        AppUtilities.shared().setLoaderProgress(view: self.view, downloaded: Double(downloaded), total: Double(outOf))
                    }, downloadTaskUpdated: nil) { (result) in
                        AppUtilities.shared().removeLoaderView(view: self.view)
                        switch result {
                        case .success(let value):
                            print("Image: \(value.image). Got from: \(value.cacheType)")
                            UIImageWriteToSavedPhotosAlbum(value.image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                        case .failure(let error):
                            print("Error: \(error)")
                        }
                    }
                }
            }
            
        }))
        
        controller.addAction(UIAlertAction(title: "Ultra HD: \(uHdSize)", style: .default, handler: { (hd) in
            if let wallpaper = self.post{
                AppUtilities.shared().addLoaderView(view: self.view)
                if let strUrl = wallpaper.uhd, let url = URL(string: strUrl){
                    
                    KingfisherManager.shared.retrieveImage(with: url, progressBlock: { (downloaded, outOf) in
                        AppUtilities.shared().setLoaderProgress(view: self.view, downloaded: Double(downloaded), total: Double(outOf))
                    }, downloadTaskUpdated: nil) { (result) in
                        AppUtilities.shared().removeLoaderView(view: self.view)
                        switch result {
                        case .success(let value):
                            print("Image: \(value.image). Got from: \(value.cacheType)")
                           UIImageWriteToSavedPhotosAlbum(value.image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                        case .failure(let error):
                            print("Error: \(error)")
                        }
                    }
                }
            }
        }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(controller, animated: true, completion: nil)
    }
    
    func getDownloadSize(url: URL, completion: @escaping (Int64, Error?) -> Void) {
        let timeoutInterval = 5.0
        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: timeoutInterval)
        request.httpMethod = "HEAD"
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            let contentLength = response?.expectedContentLength ?? NSURLSessionTransferSizeUnknown
            completion(contentLength, error)
        }.resume()
    }
}

struct FilePaths {
    static let documentsPath : AnyObject = NSSearchPathForDirectoriesInDomains(.cachesDirectory,.userDomainMask,true)[0] as AnyObject
    struct VidToLive {
        static var livePath = FilePaths.documentsPath.appending("/")
    }
}

//MARK: - REPORT DELEGATES
extension PreviewVC:ReportDelegate,MFMailComposeViewControllerDelegate{
    func didFinishWithReport(reasone: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([kReportMailId])
            mail.setSubject("Report Item Id : \(post?.postId ?? "-") - iOS")
            mail.setMessageBody("Please explain why you found it \(reasone)", isHTML: false)
            present(mail, animated: true, completion: nil)
        } else {
            print("Cannot send mail")
            // give feedback to the user
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            print("Cancelled")
        case MFMailComposeResult.saved.rawValue:
            print("Saved")
        case MFMailComposeResult.sent.rawValue:
            print("Sent")
        case MFMailComposeResult.failed.rawValue:
            print("Error: \(String(describing: error?.localizedDescription))")
        default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }
}

//MARK: - WEBSERVICES
extension PreviewVC{
    fileprivate func serviceForAddAll(key:String){
        let params:[String:Any] = [
            Parameters.user_id:userId,
            key:post?.postId ?? ""
        ]
        Webservices().request(with: params, method: .post, endPoint: EndPoints.addAll, type: Trending.self, loader: false, success: { (success) in
            
        }) {[weak self] (failer) in
            guard let vc = self else {return}
            AppUtilities.shared().showAlert(with: kNoInternet, viewController: vc, hideButtons: true)
        }
    }
}

//MARK: - REWARD DELEGATE
extension PreviewVC:RewardCompletionDelegate{
    func rewardDidDismiss(rewarded: Bool) {
        if rewarded{
            self.exportLivePhoto()
            self.serviceForAddAll(key: Parameters.live_w_download)
        }
        else{
            AppUtilities.shared().showAlert(with: "Please watch complete video to unlock this wallpaper", viewController: self)
        }
    }
}

//MARK: - UNLOCK WALLPAPER DELEGATE
extension PreviewVC:UnlockDelegate{
    func btnPremiumPressed() {
        navigationController?.pushViewController(SubscriptionVC.controller(), animated: true)
    }
    
    func btnVideoPressed() {
        AppDelegate.shared.showRewardVideo()
        AppDelegate.shared.delegate = self
    }
}
