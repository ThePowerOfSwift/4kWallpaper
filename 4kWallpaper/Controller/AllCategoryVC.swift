//
//  AllAllCategoryVC.swift
//  4kWallpaper
//
//  Created by Dixit Rathod on 13/05/20.
//  Copyright © 2020 Dixit Rathod. All rights reserved.
//

import UIKit

class AllCategoryVC: UIViewController {
    @IBOutlet weak var collectionCategory:UICollectionView!
    
    var arrWallPapers:[Wallpaper] = []
    var arrBanners:[Wallpaper] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
    }
    
    class func controller() -> AllCategoryVC{
        let story = UIStoryboard(name: StoryboardIds.main, bundle: nil)
        return story.instantiateViewController(withIdentifier: CellIdentifier.allCategory) as! AllCategoryVC
    }
}

//MARK: - CUSTOM METHODS
extension AllCategoryVC{
    fileprivate func setupView(){
        //register nib
        collectionCategory.register(UINib(nibName: CellIdentifier.categoryCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.categoryCell)
    }
    
}

//MARK: - COLLECTION DELEGATES
extension AllCategoryVC:UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrWallPapers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.categoryCell, for: indexPath) as! CatCell
        let wallpaper = arrWallPapers[indexPath.item]
        cell.lblName.text = wallpaper.name
        if let str = wallpaper.webp, let url = URL(string:str){
            cell.imgWallpaper.kf.setImage(with: url)
        }
        DispatchQueue.main.async {
            cell.layoutIfNeeded()
            cell.viewGradient.applyGradient(location: [0.0, 1.0], startPoint: CGPoint(x: 0.0, y: 0.4), endPoint: CGPoint(x: 0.0, y: 1.0), colors: [UIColor.clear.cgColor, UIColor.black.cgColor])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.size.width/2
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        kActivity += 1
        
        let obj = arrWallPapers[indexPath.item]
        let vc = SimilarCatVC.controller()
        vc.category = obj.name ?? ""
        navigationController?.pushViewController(vc, animated: true)
    }
}
