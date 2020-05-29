//
//  ProfileViewController.swift
//  ARKitImageRecognition
//
//  Created by Gurinder Singh on 5/27/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

struct TrophyItem {
    let image: UIImage
    let title: String
    let earnedDate: String
}
class ProfileViewController: UIViewController, Storyboarded, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileHeaderView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let disposeBag = DisposeBag()
    
    var trophies:[TrophyItem] = [TrophyItem(image: #imageLiteral(resourceName: "whiskeyTrophy"), title: "BUBULOUS", earnedDate: "Earned 12/24/2019"),TrophyItem(image: #imageLiteral(resourceName: "ideaTrophy"), title: "CRYPTOGROPHER", earnedDate: "Earned 12/24/2019")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileHeaderView.layer.cornerRadius = CGFloat(20)
        profileHeaderView.clipsToBounds = true
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.isNavigationBarHidden = true
        
        profileHeaderView.layer.borderWidth = 3
        profileHeaderView.layer.borderColor = UIColor.red.cgColor//UIColor.init(red: 232, green: 237, blue: 244, alpha: 1.0).cgColor

        // Do any additional setup after loadings the view.
        getProfileImage()
        nameLabel.text = FirebaseServices.shared.currentUser?.displayName
        
        
        Observable.just(trophies).bind(to: self.collectionView.rx.items(cellIdentifier: ProfileTrophesCollectionViewCell.reuseIdentifier, cellType: ProfileTrophesCollectionViewCell.self)) { row, data, cell in
            cell.trophyImageView.image = data.image
            cell.trophyLabel.text = data.title
            cell.trophyEarnedDateLabel.text = data.earnedDate
        }.disposed(by: disposeBag)

        // add this line you can provide the cell size from delegate method
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let cellWidth = (width - 30) / 3 // compute your cell width
        return CGSize(width: cellWidth, height: cellWidth / 0.6)
    }
    
    func getProfileImage() {
        self.profileImageView.sd_setImage(with: FirebaseServices.shared.profileRef)
    }
    


}
