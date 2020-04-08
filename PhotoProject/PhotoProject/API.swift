//
//  API.swift
//  PhotoProject
//
//  Created by Sergey Pohrebnuak on 08.04.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import SwiftyJSON

class API {
    
    static var shared = API()
    
    fileprivate static let baseURL = "https://api.unsplash.com/"
    fileprivate static let photos = "photos"
    fileprivate static let searchPhotos = "search/photos"
    fileprivate static let accessKey = "Client-ID 4c9fbfbbd92c17a2e95081cec370b4511659666240eb4db9416c40c641ee843b"
    
    enum Method: String {
        case post = "POST"
        case get = "GET"
    }
    
    func getPhotosFromRoll(page: Int, countPerPage: Int, callback: @escaping ([JSON]?) -> Void) {
        sendRequest(API.baseURL + API.photos + "?page=\(page)&per_page=\(countPerPage)", method: .get) { (json, isError) in
            guard !isError, let arrayOfJson = json?.array else {
                callback(nil)
                return
            }
            callback(arrayOfJson)
        }
    }
    
    func getPhotosBySearch(text: String, page: Int, countPerPage: Int, callback: @escaping ([JSON]?) -> Void) {
        sendRequest(API.baseURL + API.searchPhotos + "?query=\(text)&page=\(page)&per_page=\(countPerPage)", method: .get) { (json, isError) in
            guard !isError, let arrayOfJson = json?["results"].array else {
                callback(nil)
                return
            }
            callback(arrayOfJson)
        }
    }
    
    fileprivate func sendRequest(_ url: String,
                                 method: Method = .post,
                                 jsonParams: [String : Any]? = nil,
                                 callback: @escaping ((JSON?, Bool) -> ())) {
        do {
            
            guard let url = URL(string: url) else {return}
            let session = URLSession.shared
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            request.setValue(API.accessKey, forHTTPHeaderField: "Authorization")

            if let jsonParams = jsonParams {
                request.httpBody = try JSONSerialization.data(withJSONObject: jsonParams, options: .prettyPrinted)
            }
            
            let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
                session.finishTasksAndInvalidate()
                guard   let data:Data = data,
                        let _:URLResponse = response,
                        error == nil,
                        let httpUrlResponse = response as? HTTPURLResponse,
                        httpUrlResponse.statusCode == 200,
                        let jsonObject = try? JSON(data: data)
                else {
                    callback(nil, true)
                    return
                }
                
                callback(jsonObject, false)
                
            })
            task.resume()
        } catch {
            fatalError("can't add body")
        }
    }
}
