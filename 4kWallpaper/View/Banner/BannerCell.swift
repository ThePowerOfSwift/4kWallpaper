//
//  BannerCell.swift
//  4kWallpaper
//
//  Created by Dixit Rathod on 04/05/20.
//  Copyright © 2020 Dixit Rathod. All rights reserved.
//

import UIKit

protocol BannerCellDelegate:AnyObject {
    func openCategory(category:String)
}

class BannerCell: UICollectionViewCell {
    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var viewBg:UIView!
    @IBOutlet weak var imgBanner:UIImageView!
    @IBOutlet weak var viewShadow:UIView!
    
    var category:String = ""
    weak var delegate:BannerCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        viewBg.layer.cornerRadius = 5.0
        // Initialization code
    }

}
