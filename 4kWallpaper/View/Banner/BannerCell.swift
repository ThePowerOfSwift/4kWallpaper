//
//  BannerCell.swift
//  4kWallpaper
//
//  Created by Dixit Rathod on 04/05/20.
//  Copyright © 2020 Dixit Rathod. All rights reserved.
//

import UIKit

class BannerCell: UICollectionViewCell {
    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var btnExplore:UIButton!
    @IBOutlet weak var viewBg:UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        viewBg.layer.cornerRadius = 5.0
        // Initialization code
    }

}
