//
//  Photo.swift
//  PhotoProject
//
//  Created by Sergey Pohrebnuak on 08.04.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import UIKit
import SwiftyJSON

class Photo {
    var image = UIImage(named: "defaultImage")
    
    private let imageURL: URL
    private let compleationBlockAfterDownload: () -> Void
    
    init (fromJson json: JSON, compleationBlock: @escaping () -> Void) {
        self.imageURL = URL(string: json["urls"].dictionaryValue["small"]!.stringValue)!
        self.compleationBlockAfterDownload = compleationBlock
        DispatchQueue.global().async {
            self.downloadPhoto()
        }
    }
    
    private func downloadPhoto() {
        do {
            let data = try Data(contentsOf: self.imageURL)
            self.image = UIImage.init(data: data)
            compleationBlockAfterDownload()
        } catch {
            image = UIImage(named: "error")
            compleationBlockAfterDownload()
        }
    }
}
