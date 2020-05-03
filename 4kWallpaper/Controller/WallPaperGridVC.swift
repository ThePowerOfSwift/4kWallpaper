//
//  WallPaperGridVC.swift
//  4kWallpaper
//
//  Created by Dixit Rathod on 03/05/20.
//  Copyright © 2020 Dixit Rathod. All rights reserved.
//

import UIKit

class WallPaperGridVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layoutIfNeeded()
        let carousel = iCarousel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height/1.2))
        carousel.dataSource = self
        carousel.delegate = self
        carousel.type = .custom
        view.addSubview(carousel)
        // Do any additional setup after loading the view.
    }
    
    class func controller() -> WallPaperGridVC
    {
        let story = UIStoryboard(name: StoryboardIds.main, bundle: nil)
        return story.instantiateViewController(withIdentifier: ControllerIds.wallPaperGrid) as! WallPaperGridVC
    }

}

//MARK: - CARAUSEL DELEGATES
extension WallPaperGridVC:iCarouselDelegate, iCarouselDataSource{
    func numberOfItems(in carousel: iCarousel) -> Int {
        return 10
    }

    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width/1.5, height: self.view.bounds.size.height/2))
        view.layer.cornerRadius = 10.0
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        return view
        
        
//        let imageView: UIImageView
//
//        if view != nil {
//            imageView = view as! UIImageView
//        } else {
//            imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 128, height: 128))
//        }
//
//        imageView.image = UIImage(named: "example")
//
//        return imageView
    }
    
    func carouselItemWidth(_ carousel: iCarousel) -> CGFloat {
        print(carousel.contentOffset)
        return 250
    }
    
    
    func carousel(_ carousel: iCarousel, itemTransformForOffset offset: CGFloat, baseTransform transform: CATransform3D) -> CATransform3D {
        let spacing : CGFloat = 0.15
        let distance : CGFloat = 100
        let clampedOffset = min(1.0, max(-1.0, offset))

        var offset = offset

        let z : CGFloat = CGFloat(-abs(clampedOffset)) * distance

        offset += clampedOffset*spacing
        return CATransform3DTranslate(transform, offset * carousel.itemWidth , 0.5 , z );
    }
    
}
