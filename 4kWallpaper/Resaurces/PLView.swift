//
//  PLView.swift
//  4kWallpaper
//
//  Created by Dixit Rathod on 09/05/20.
//  Copyright © 2020 Dixit Rathod. All rights reserved.
//

import Foundation
import UIKit
import Photos
import PhotosUI

class PLView: UIView {

    let image: UIImage
    let imageURL: URL
    let videoURL: URL

    let liveView: PHLivePhotoView

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(image: UIImage, imageURL: URL, videoURL: URL) {
        self.image = image
        self.imageURL = imageURL
        self.videoURL = videoURL
        let rect = UIScreen.main.bounds
        self.liveView = PHLivePhotoView(frame: rect)
        super.init(frame: rect)
        self.addSubview(self.liveView)
    }

    func prepareLivePhoto() {
        makeLivePhotoFromItems { (livePhoto) in
            self.liveView.livePhoto = livePhoto
            print("\nReady! Click on the LivePhoto in the Assistant Editor panel!\n")
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("\nClicked! Wait for it...\n")
        self.liveView.startPlayback(with: .full)
    }

    private func makeLivePhotoFromItems(completion: @escaping (PHLivePhoto) -> Void) {
        PHLivePhoto.request(withResourceFileURLs: [imageURL, videoURL], placeholderImage: image, targetSize: CGSize.zero, contentMode: .aspectFit) {
            (livePhoto, infoDict) -> Void in

            if let canceled = infoDict[PHLivePhotoInfoCancelledKey] as? NSNumber,
                canceled == 0,
                let livePhoto = livePhoto
            {
                completion(livePhoto)
            }
        }
    }

}
