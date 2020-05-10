//
//  WallpaperCell.swift
//  4kWallpaper
//
//  Created by Dixit Rathod on 03/05/20.
//  Copyright © 2020 Dixit Rathod. All rights reserved.
//

import UIKit

class WallpaperCell: UICollectionViewCell {
    @IBOutlet weak var imgWallPaper:UIImageView!
    @IBOutlet weak var viewBg:UIView!
    @IBOutlet weak var imgLive:UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.viewBg.layer.cornerRadius = 10.0
        self.viewBg.layer.masksToBounds = true
        // Initialization code
    }

}
