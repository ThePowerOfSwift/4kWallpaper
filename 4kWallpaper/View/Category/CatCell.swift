//
//  BannerCatCell.swift
//  4kWallpaper
//
//  Created by Dixit Rathod on 04/05/20.
//  Copyright © 2020 Dixit Rathod. All rights reserved.
//

import UIKit

class CatCell: UICollectionViewCell {
    @IBOutlet weak var imgWallpaper:UIImageView!
    @IBOutlet weak var viewBg:UIView!
    @IBOutlet weak var viewGradient:UIView!
    @IBOutlet weak var lblName:UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewBg.layer.cornerRadius = 10.0
        viewBg.layer.masksToBounds = true
        
        
        // Initialization code
    }

}
