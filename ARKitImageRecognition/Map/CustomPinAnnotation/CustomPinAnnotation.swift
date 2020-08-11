//
//  CustomPinAnnotation.swift
//  ARKitImageRecognition
//
//  Created by Duy Nguyen on 8/10/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import MapKit

class CustomPinAnnotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var image: UIImage?
    var color: UIColor?
    
    override init() {
        self.coordinate = CLLocationCoordinate2D()
        self.title = nil
        self.subtitle = nil
        self.image = nil
        self.color = UIColor.green
    }
    
}


class CustomPinAnnotationView: MKAnnotationView {
    private var imageView: UIImageView!
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        centerOffset = CGPoint(x: 0, y: -frame.size.height / 2)
        
        self.imageView = UIImageView(image: UIImage(named: "locationPinGuitar"))
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.imageView)
        NSLayoutConstraint.activate(getImageViewConstraints(imageView: self.imageView))
    }
    
    override var image: UIImage? {
        get {
            return self.imageView.image
        }
        
        set {
            self.imageView.image = newValue
        }
    }
    
    func getImageViewConstraints(imageView: UIImageView) -> Array<NSLayoutConstraint>{
        return [
            imageView.topAnchor.constraint(equalTo: imageView.superview!.topAnchor,
                                           constant: 0),
            imageView.bottomAnchor.constraint(equalTo: imageView.superview!.bottomAnchor,
                                              constant: 0),
            
            imageView.trailingAnchor.constraint(equalTo: imageView.superview!.trailingAnchor,
                                                constant: 0),
            imageView.leadingAnchor.constraint(equalTo: imageView.superview!.leadingAnchor,
                                               constant: 0)
        ]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
