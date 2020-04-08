//
//  ViewController.swift
//  PhotoProject
//
//  Created by Sergey Pohrebnuak on 08.04.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import UIKit
import SwiftyJSON

class ViewController: UIViewController {

    @IBOutlet fileprivate weak var photoCollectionView: UICollectionView!
    
    fileprivate let spacingBetweenCell: CGFloat = 10.0
    fileprivate let countCellInRow = 3
    fileprivate var arrayOfPhoto = [Photo]()
    fileprivate var currentPhotoPage = 1
    fileprivate var countPhotoPerPage = 20
    fileprivate var isLoadPhotoNow = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib.init(nibName: "PhotoCollectionViewCell", bundle: nil)
        photoCollectionView.register(nib, forCellWithReuseIdentifier: "PhotoCollectionViewCell")
        
        loadPhoto()
    }
    
    fileprivate func loadPhoto() {
        isLoadPhotoNow = true
        API.shared.getPhotoFromRoll(page: currentPhotoPage, countPerPage: countPhotoPerPage) { [weak self] (optionalArray) in
            self?.isLoadPhotoNow = false
            guard let arrayOfJson = optionalArray else {return}
            for object in arrayOfJson {
                let newItem = Photo(fromJson: object) {
                    DispatchQueue.main.async {
                        self?.photoCollectionView.reloadData()
                    }
                }
                self?.arrayOfPhoto.append(newItem)
            }
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfPhoto.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        cell.setDataInCell(photoItem: arrayOfPhoto[indexPath.row])
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + 1) >= (scrollView.contentSize.height - scrollView.frame.size.height) && !isLoadPhotoNow && currentPhotoPage < 10 {
            self.currentPhotoPage += 1
            self.loadPhoto()
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widthSize = self.photoCollectionView.bounds.size.width/CGFloat(countCellInRow) - spacingBetweenCell
        return CGSize(width: widthSize, height: widthSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacingBetweenCell
    }
}

