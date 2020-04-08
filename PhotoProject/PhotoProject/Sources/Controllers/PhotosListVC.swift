//
//  PhotosListVC.swift
//  PhotoProject
//
//  Created by Sergey Pohrebnuak on 08.04.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import UIKit
import SwiftyJSON
import PhotoAPI

class PhotosListVC: UIViewController {
    
    enum Mode {
        case normal
        case search
    }

    @IBOutlet fileprivate weak var photoCollectionView: UICollectionView!
    
    fileprivate var closeSearchButton: UIBarButtonItem!
    fileprivate var cellLongPressRecognizer : UILongPressGestureRecognizer!
    fileprivate var searchBar = UISearchBar(frame: CGRect.zero)
    fileprivate let spacingBetweenCell: CGFloat = 10.0
    fileprivate let countCellInRow = 3
    fileprivate var arrayOfPhoto = [Photo]()
    fileprivate var currentPhotoPage = 1
    fileprivate var countPhotoPerPage = 30
    fileprivate var isLoadPhotoNow = false
    fileprivate var currentMode = Mode.normal

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        //load first page of photos
        loadPhoto()
    }
    
    //MARK: - Fileprivate functions
    fileprivate func configureUI() {
        //add tap recognizer on navigation bar for search bar
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(titleWasTapped))
        self.navigationController?.navigationBar.addGestureRecognizer(recognizer)
        //add cell for collection view
        let nib = UINib.init(nibName: "PhotoCollectionViewCell", bundle: nil)
        photoCollectionView.register(nib, forCellWithReuseIdentifier: "PhotoCollectionViewCell")
        //search bar and cancell button
        searchBar.delegate = self
        closeSearchButton = UIBarButtonItem(title: "Close",
                                            style: .done,
                                            target: self,
                                            action: #selector(closeSearch))
        //configure long press recognizer
        cellLongPressRecognizer = UILongPressGestureRecognizer(target: self,
                                                               action: #selector(handleLongPress(gestureRecognizer:)))
        cellLongPressRecognizer.minimumPressDuration = 0.5
        cellLongPressRecognizer.delaysTouchesBegan = true
        cellLongPressRecognizer.isEnabled = false
        photoCollectionView.addGestureRecognizer(cellLongPressRecognizer)
    }
    //MARK: Functions for loading photos
    fileprivate func loadPhoto() {
        isLoadPhotoNow = true
        API.shared.getPhotosFromRoll(page: currentPhotoPage, countPerPage: countPhotoPerPage) { [weak self] (dictionaryOptional) in
            self?.isLoadPhotoNow = false
            self?.convertJSONArray(object: dictionaryOptional)
        }
    }
    
    fileprivate func loadPhotoBySearch() {
        guard searchBar.text!.count > 3 else {return}
        API.shared.getPhotosBySearch(text: searchBar.text!, page: currentPhotoPage, countPerPage: countPhotoPerPage) { [weak self] (dictionaryOptional) in
            self?.convertJSONArray(object: dictionaryOptional)
        }
    }
    
    //additional function for convert from json to model
    fileprivate func convertJSONArray(object: Any?) {
        guard   let dictionary = object,
                let array = JSON(dictionary).array else {return}
        
        for object in array {
            let newItem = Photo(fromJson: object) {
                DispatchQueue.main.async {
                    self.photoCollectionView.reloadData()
                }
            }
            self.arrayOfPhoto.append(newItem)
        }
    }
    //MARK: selector functions for UI
    @objc fileprivate func titleWasTapped() {
        if navigationItem.titleView == nil {
            cellLongPressRecognizer.isEnabled = true
            self.navigationItem.rightBarButtonItem = closeSearchButton
            currentMode = .search
            photoCollectionView.reloadData()
            navigationItem.titleView = searchBar
            searchBar.becomeFirstResponder()
            currentPhotoPage = 1
        }
    }
    
    @objc fileprivate func closeSearch() {
        cellLongPressRecognizer.isEnabled = false
        photoCollectionView.scrollsToTop = true
        arrayOfPhoto.removeAll()
        navigationItem.rightBarButtonItem = nil
        navigationItem.titleView = nil
        currentMode = .normal
        photoCollectionView.reloadData()
        currentPhotoPage = 1
        loadPhoto()
    }
    @objc fileprivate func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer) {
        let p = gestureRecognizer.location(in: self.photoCollectionView)
        guard   gestureRecognizer.state == .ended,
            let indexPath : NSIndexPath = photoCollectionView.indexPathForItem(at: p) as NSIndexPath?
            else {return}

        let alert = UIAlertController(title: "Are you sure?", message: "Photo will be removed, confirm please!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .destructive) { [weak self]action in
            self?.arrayOfPhoto.remove(at: indexPath.row)
            self?.photoCollectionView.reloadData()
        }
        let cancell = UIAlertAction(title: "Cancell", style: .default)
        alert.addAction(okAction)
        alert.addAction(cancell)
        self.present(alert, animated: true, completion: nil)
    }
}

extension PhotosListVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let datailImageVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailImageVC") as! DetailImageVC
        datailImageVC.currentPhoto = arrayOfPhoto[indexPath.row]
        self.navigationController?.pushViewController(datailImageVC, animated: true)
    }
}

extension PhotosListVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfPhoto.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        guard arrayOfPhoto.count > indexPath.row else {return cell}
        cell.setDataInCell(photoItem: arrayOfPhoto[indexPath.row])
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + 1) >= (scrollView.contentSize.height - scrollView.frame.size.height) && !isLoadPhotoNow && currentPhotoPage < 10 {
            self.currentPhotoPage += 1
            switch currentMode {
            case .normal:
                self.loadPhoto()
            case .search:
                self.loadPhotoBySearch()
            }
        }
    }
}

extension PhotosListVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var widthSize: CGFloat!
        switch currentMode {
        case .normal:
            widthSize = self.photoCollectionView.bounds.size.width/CGFloat(countCellInRow) - spacingBetweenCell
        case .search:
            widthSize = self.photoCollectionView.bounds.size.width
        }
        return CGSize(width: widthSize, height: widthSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacingBetweenCell
    }
}

extension PhotosListVC: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 3 {
            arrayOfPhoto.removeAll()
            currentPhotoPage = 1
            loadPhotoBySearch()
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
}
