//
//  ReportVC.swift
//  4kWallpaper
//
//  Created by Dixit Rathod on 10/05/20.
//  Copyright © 2020 Dixit Rathod. All rights reserved.
//

import UIKit
@objc protocol ReportDelegate:AnyObject {
    @objc optional func didFinishWithReport(reasone:String)
}

class ReportVC: UIViewController {
    @IBOutlet weak var lblReportId:UILabel!
    @IBOutlet weak var btnSexuallyExplicit:UIButton!
    @IBOutlet weak var btnOffensive:UIButton!
    @IBOutlet weak var btnBadQuality:UIButton!
    @IBOutlet weak var btnCopyrighted:UIButton!
    @IBOutlet weak var viewBg:UIView!
    
    weak var delegate:ReportDelegate?
    var postId:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblReportId.text = "Report Item Id : \(postId)"
        self.viewBg.layer.cornerRadius = 5.0
        self.viewBg.dropShadow(color: UIColor.white)
        // Do any additional setup after loading the view.
    }
    
    class func controller() -> ReportVC{
        let story = UIStoryboard(name: StoryboardIds.main, bundle: nil)
        return story.instantiateViewController(withIdentifier: ControllerIds.report) as! ReportVC
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true, completion: nil)
    }
}


//MARK: - ACTION METHODS
extension ReportVC{
    @IBAction func btnReportPressed(_ sender:UIButton){
        self.dismiss(animated: true) {
            self.delegate?.didFinishWithReport?(reasone: sender.title(for: .normal) ?? "")
        }
    }
}
