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

class PreviewVC: UIViewController {
    @IBOutlet weak var imgWallpaper:UIImageView!
    @IBOutlet weak var btnFavourite:UIButton!
    @IBOutlet weak var btnDownload:UIButton!
    @IBOutlet weak var btnMore:UIButton!
    @IBOutlet weak var btnReport:UIButton!
    @IBOutlet weak var btnCategory:UIButton!
    @IBOutlet weak var lblReport:UILabel!
    @IBOutlet weak var lblCategory:UILabel!
    @IBOutlet weak var viewCategory:UIView!
    @IBOutlet weak var viewReport:UIView!
    @IBOutlet weak var stackMore:UIStackView!
    @IBOutlet weak var livePhotos:PHLivePhotoView!
    var player: AVPlayer?
    
    var post:Post?

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

}

//MARK: - CUSTOM METHODS
extension PreviewVC{
    fileprivate func setupView(){
        self.title = post?.category ?? ""
        btnDownload.setRounded()
        btnMore.setRounded()
        btnCategory.setRounded()
        viewCategory.layer.cornerRadius = 5.0
        viewReport.layer.cornerRadius = 5.0
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    fileprivate func setupData(){
        if let wallpaper = post{
            lblCategory.text = wallpaper.category
            if wallpaper.type == "live_wallpaper"{
                if let strImg = wallpaper.liveImg, let live = wallpaper.liveVideo, let imgUrl = URL(string: strImg), let vidURL = URL(string: live){

                    self.loadVideoWithVideoURL(vidURL)
                    self.imgWallpaper.kf.setImage(with: imgUrl)
                    return
                }
                
            }
            AppUtilities.shared().addLoaderView(view: self.view)
            if let strUrl = wallpaper.thumbWebp, let url = URL(string: strUrl){
                KingfisherManager.shared.retrieveImage(with: url, progressBlock: { (downloaded, outOf) in
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
        let asset = AVURLAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = NSValue(time: CMTimeMakeWithSeconds(CMTimeGetSeconds(asset.duration)/2, preferredTimescale: asset.duration.timescale))
        generator.generateCGImagesAsynchronously(forTimes: [time]) { [weak self] _, image, _, _, _ in
            if let image = image, let data = UIImage(cgImage: image).pngData() {
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
                DispatchQueue.main.async{
                    guard let view = self?.view else {return}
                    AppUtilities.shared().setLoaderProgress(view: view, downloaded: 1.0, total: 1.0, isProgress:true)
                }
                
                _ = DispatchQueue.main.sync {
                    guard let view = self?.view else {return}
                    PHLivePhoto.request(withResourceFileURLs: [ URL(fileURLWithPath: FilePaths.VidToLive.livePath + "/IMG.MOV"), URL(fileURLWithPath: FilePaths.VidToLive.livePath + "/IMG.JPG")],
                                        placeholderImage: nil,
                                        targetSize: view.bounds.size,
                                        contentMode: PHImageContentMode.aspectFit,
                                        resultHandler: { (livePhoto, info) -> Void in
                                            
                                            AppUtilities.shared().removeLoaderView(view: view)
                                            let livePhotoView = PHLivePhotoView(frame: self?.imgWallpaper.bounds ?? CGRect.zero)
                                            self?.imgWallpaper.addSubview(livePhotoView)
                                            self?.imgWallpaper.isUserInteractionEnabled = true
                                            livePhotoView.livePhoto = livePhoto
                                            livePhotoView.startPlayback(with: .full)
                                            
                    })
                }
            }
        }
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
    
    @IBAction func btnDownload(_ sender:UIButton){
        if post?.type == "live_wallpaper"{
            self.exportLivePhoto()
            return
        }
        let controller = UIAlertController(title: "Quality of image", message: nil, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "HD", style: .default, handler: { (hd) in
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
        
        controller.addAction(UIAlertAction(title: "Ultra HD", style: .default, handler: { (hd) in
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
}

//MARK: - ACTION METHODS
extension PreviewVC{
    @IBAction func btnMorePressed(_ sender:UIButton){
        sender.isSelected = !sender.isSelected
        for view in stackMore.arrangedSubviews{
            if view.tag == 2{
                view.isHidden = !sender.isSelected
            }
        }
        UIView.animate(withDuration: 0.2) {
            sender.transform = sender.isSelected ? CGAffineTransform(rotationAngle: 45.0) : .identity
        }
    }
}

struct FilePaths {
    static let documentsPath : AnyObject = NSSearchPathForDirectoriesInDomains(.cachesDirectory,.userDomainMask,true)[0] as AnyObject
    struct VidToLive {
        static var livePath = FilePaths.documentsPath.appending("/")
    }
}
