//
//  DinHours.swift
//  TigerTrail
//
//  Created by Yazan Mimi on 7/9/19.
//  Copyright © 2019 Mwad Saleh SPE. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import Contacts
import CoreLocation

class DinHours: UIViewController,UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        scrollView.delegate = self
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0//maximum zoom scale you want
        scrollView.zoomScale = 1.0
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
}

}
