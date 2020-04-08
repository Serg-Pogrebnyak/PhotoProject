//
//  PhotoCollectionViewCell.swift
//  PhotoProject
//
//  Created by Sergey Pohrebnuak on 08.04.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet fileprivate weak var photoImageView: UIImageView!
    @IBOutlet fileprivate weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var widthConstraint: NSLayoutConstraint!
    
    func setDataInCell(photoItem item: Photo) {
        heightConstraint.constant = self.bounds.size.height
        widthConstraint.constant = self.bounds.size.width
        photoImageView.image = item.image
    }

}
