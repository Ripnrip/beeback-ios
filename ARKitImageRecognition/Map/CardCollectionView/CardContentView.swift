//
//  CardCollectionCell.swift
//  ARKitImageRecognition
//
//  Created by Duy Nguyen on 8/4/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class CardContentView: UIView {

    var viewModel: CardContentViewModel? {
        didSet {
            locationImage.image = viewModel?.locationImage
            locationName.text = viewModel?.locationName
            locationSubtitle.text = viewModel?.locationSubtitle
            address.text = viewModel?.address
            distance.text = viewModel?.distance
        }
    }
    
    @IBOutlet var contentView: CardContentView!
    
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var locationSubtitle: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var distance: UILabel!
    

    func fromNib(){
        let bundle = Bundle(for: type(of: self))
//        let nibName = String(describing: type(of: self))
        let nibName = "CardContentView"
        
        let contentView = bundle.loadNibNamed(nibName,
                                              owner: self,
            options: nil)?.first as! UIView
        self.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0),
            self.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0),
            self.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            self.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        ])
    }
    
    func nibSetup() {
        Bundle.main.loadNibNamed("CardContentView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    // MARK: - Initialization
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        nibSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
}
