//
//  DetailImageVC.swift
//  PhotoProject
//
//  Created by Sergey Pohrebnuak on 08.04.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import UIKit
import ZoomImageView

class DetailImageVC: UIViewController {

    var currentPhoto: Photo?
    
    @IBOutlet fileprivate weak var imageView: ZoomImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = currentPhoto?.image
    }

}
