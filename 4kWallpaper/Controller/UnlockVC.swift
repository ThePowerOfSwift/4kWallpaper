//
//  UnlockVC.swift
//  4kWallpaper
//
//  Created by Dixit Rathod on 22/05/20.
//  Copyright © 2020 Dixit Rathod. All rights reserved.
//

import UIKit
protocol UnlockDelegate :AnyObject{
    func btnPremiumPressed()
    func btnVideoPressed()
}

class UnlockVC: UIViewController {
    @IBOutlet weak var imgLock:UIImageView!
    @IBOutlet weak var btnWatchVideo:UIButton!
    @IBOutlet weak var btnPremium:UIButton!
    @IBOutlet weak var viewBg:UIView!
    weak var delegate:UnlockDelegate?
    
    let selectedColor = UIColor(red: 251.0/255.0, green: 210.0/255.0, blue: 19.0/255.0, alpha: 1.0)
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
    }
    
    class func controller() -> UnlockVC{
        let story = UIStoryboard(name: StoryboardIds.main, bundle: nil)
        return story.instantiateViewController(withIdentifier: ControllerIds.unlock) as! UnlockVC
    }

}

//MARK: - CUSTOM METHODS
extension UnlockVC{
    private func setupView(){
        self.view.layoutIfNeeded()
        btnWatchVideo.setRounded()
        btnPremium.setRounded()
        btnWatchVideo.setBorder(with: selectedColor, width: 1.0)
        btnPremium.setBorder(with: selectedColor, width: 1.0)
        
        viewBg.layer.cornerRadius = 20.0
        
        imgLock.transform = CGAffineTransform(rotationAngle: -CGFloat(Double.pi/4))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - ACTION METHODS
extension UnlockVC{
    @IBAction func btnWatchVideo(_ sender:UIButton){
        self.dismiss(animated: true) {
            self.delegate?.btnVideoPressed()
        }
        
    }
    
    @IBAction func btnPremium(_ sender:UIButton){
        self.dismiss(animated: true) {
            self.delegate?.btnPremiumPressed()
        }
    }
}
