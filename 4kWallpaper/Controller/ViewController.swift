//
//  ViewController.swift
//  4kWallpaper
//
//  Created by Dixit Rathod on 03/05/20.
//  Copyright © 2020 Dixit Rathod. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionCategory :UICollectionView!
    @IBOutlet weak var stackListing :UIStackView!
    @IBOutlet weak var scrollListing :UIScrollView!
    
    var arrCategories:[String] = ["Home","Home","Home","Home","Home","Home","Home"]
    var arrChildCategories:[String] = ["Home","Home","Home","Home","Home","Home","Home"]
    var selectedIndex = 0
    var selectedMenu = 0
    var imageBase = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadNewsListing()
        // Do any additional setup after loading the view.
    }

}

//MARK: - COLLECTIONVIEW DELEGATES
extension ViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrChildCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.dashCategory, for: indexPath) as! DashboardCategoryCell
        
        cell.lblCategoryName.isHidden = false
        cell.lblCategoryName.text = arrChildCategories[indexPath.item]
        
        if indexPath.row == selectedIndex
        {
            cell.viewSelection.isHidden = false
        }
        else{
            cell.viewSelection.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        selectedIndex = indexPath.item
        self.collectionCategory.reloadData()
        self.collectionCategory.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        let xOffset = CGFloat(indexPath.item) * scrollListing.frame.size.width
        self.scrollListing.setContentOffset(CGPoint(x: xOffset, y: 0), animated: true)
        if let view = stackListing.arrangedSubviews[indexPath.item] as? DashboardCollectionView
        {
//            view.category = arrChildCategories[indexPath.item]
        }
    }
}

//MARK: - CUSTOM METHODS
extension ViewController{
    private func loadNewsListing()
    {
        self.stackListing.arrangedSubviews.forEach({
            if $0.tag == 25{
                $0.removeFromSuperview()
            }
        })
        for i in 0..<arrChildCategories.count
        {
            let nib = Bundle.main.loadNibNamed(CellIdentifier.dashWallpaperView, owner: self, options: nil)![0] as! DashboardCollectionView
//            nib.controller = self
//            nib.arrNews = []
//            nib.arrNewsTemp = []
//            nib.tag = 25
//            nib.currentPage = 1
//            nib.totalPage = 0
//            nib.totalNews = 0
//            nib.tblNewsListing.reloadData()
//            if i == 0
//            {
//                nib.category = arrChildCategories[i]
//            }
            nib.delegate = self
            nib.index = i
            self.stackListing.addArrangedSubview(nib)
            nib.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                nib.widthAnchor.constraint(equalTo: scrollListing.widthAnchor, multiplier: 1.0),
                nib.heightAnchor.constraint(equalTo: scrollListing.heightAnchor, multiplier: 1.0)
            ])
        }
    }
}

//MARK: - COLLECTIONCELL DELEGATE
extension ViewController:DashboardCollectionDelegate{
    func collectionDidSelectWithIndex(index: Int) {
        let vc = WallPaperGridVC.controller()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - SCROLLVIEW DELEGATES
extension ViewController
{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == scrollListing {
            let index = scrollView.contentOffset.x/scrollView.bounds.size.width
            if let view = stackListing.arrangedSubviews[Int(index)] as? DashboardCollectionView
            {
//                view.category = arrChildCategories[Int(index)]
                selectedIndex = Int(index)
                self.collectionCategory.reloadSections([0])
                self.collectionCategory.scrollToItem(at: IndexPath(item: Int(index), section: 0), at: .centeredHorizontally, animated: true)
            }
        }
    }
}
