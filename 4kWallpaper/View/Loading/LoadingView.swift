//
//  LoadingView.swift
//  4kWallpaper
//
//  Created by Dixit Rathod on 07/05/20.
//  Copyright © 2020 Dixit Rathod. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    @IBOutlet weak var lblPercentage:UILabel!
    @IBOutlet weak var progress:UIProgressView!
    @IBOutlet weak var lblSize:UILabel!
    @IBOutlet weak var viewVisualEffect:UIVisualEffectView!
    
    override func awakeFromNib() {
        progress.transform = CGAffineTransform(scaleX: 1.0, y: 1.5)
    }
    
    class func mainView() -> LoadingView{
        return Bundle.main.loadNibNamed(ControllerIds.loadingView, owner: self, options: nil)![0] as! LoadingView
    }
}
