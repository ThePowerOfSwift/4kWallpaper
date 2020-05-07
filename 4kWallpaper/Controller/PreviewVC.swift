//
//  PreviewVC.swift
//  4kWallpaper
//
//  Created by Dixit Rathod on 07/05/20.
//  Copyright © 2020 Dixit Rathod. All rights reserved.
//

import UIKit
import Kingfisher

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
    
    var post:Post?

    override func viewDidLoad() {
        super.viewDidLoad()
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
            let loading = LoadingView.mainView()
            self.view.addSubview(loading)
            loading.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                loading.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
                loading.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
                loading.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
                loading.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
            ])
            if let strUrl = wallpaper.thumbWebp, let url = URL(string: strUrl){
                KingfisherManager.shared.retrieveImage(with: url, progressBlock: { (downloaded, outOf) in
                    let progress = (downloaded*100)/outOf
                    loading.lblPercentage.text = "\(progress)%"
                    loading.progress.progress = Float(progress/100)
                    loading.lblSize.text = "\(downloaded)/\(outOf)"
                }, downloadTaskUpdated: nil) { (result) in
                    loading.removeFromSuperview()
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
    
    @IBAction func btnDownload(_ sender:UIButton){
        let controller = UIAlertController(title: "Quality of image", message: nil, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "HD", style: .default, handler: { (hd) in
            if let wallpaper = self.post{
                let loading = LoadingView.mainView()
                self.view.addSubview(loading)
                
                loading.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    loading.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
                    loading.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
                    loading.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
                    loading.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
                ])
                if let strUrl = wallpaper.hd, let url = URL(string: strUrl){
                    
                    KingfisherManager.shared.retrieveImage(with: url, progressBlock: { (downloaded, outOf) in
                        let progress = (downloaded*100)/outOf
                        loading.lblPercentage.text = "\(progress)%"
                        loading.progress.progress = Float(progress/100)
                        loading.lblSize.text = "\(downloaded)/\(outOf)"
                    }, downloadTaskUpdated: nil) { (result) in
                        loading.removeFromSuperview()
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
                let loading = LoadingView.mainView()
                self.view.addSubview(loading)
                loading.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    loading.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
                    loading.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
                    loading.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
                    loading.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
                ])
                if let strUrl = wallpaper.uhd, let url = URL(string: strUrl){
                    
                    KingfisherManager.shared.retrieveImage(with: url, progressBlock: { (downloaded, outOf) in
                        let progress = (downloaded*100)/outOf
                        loading.lblPercentage.text = "\(progress)%"
                        loading.progress.progress = Float(progress/100)
                        loading.lblSize.text = "\(downloaded)/\(outOf)"
                    }, downloadTaskUpdated: nil) { (result) in
                        loading.removeFromSuperview()
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
