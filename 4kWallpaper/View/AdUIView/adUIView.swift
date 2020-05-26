//
//  adUIView.swift
//  CollectionDemo
//
//  Created by Dixit Rathod on 21/05/20.
//  Copyright © 2020 Dixit Rathod. All rights reserved.
//

import UIKit
import FBAudienceNetwork

class adUIView: UICollectionReusableView {
    @IBOutlet weak var adIconImageView:FBMediaView!
    @IBOutlet weak var adTitleLabel:UILabel!
    @IBOutlet weak var adCoverMediaView:FBMediaView!
    @IBOutlet weak var adSocialContext:UILabel!
    @IBOutlet weak var adCallToActionButton:UIButton!
    @IBOutlet weak var adOptionsView:FBAdOptionsView!
    @IBOutlet weak var adBodyLabel:UILabel!
    @IBOutlet weak var sponsoredLabel:UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        adIconImageView.setRounded()
        adCallToActionButton.layer.cornerRadius = 5.0
        adCallToActionButton.layer.masksToBounds = true
        // Initialization code
    }
    
}
