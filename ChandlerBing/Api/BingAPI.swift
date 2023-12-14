//
//  BingAPI.swift
//  ChandlerBing
//
//  Created by Ananda Ray on 11/12/23.
//

import Foundation
import AppKit

enum DataError: Error {
    case invalidURL
    case invalidData
    case invalidResponse
    case message(_ error: Error?)
}

class BingAPI {
    
    let storage = LocalStorage()
    let baseURL = Constants.bingBaseURL
    
    static let shared = BingAPI()
    
    private init() {}
    
    
    func fetchData(region: String, completion: @escaping (Result<ImageResponse, Error>) -> Void) {
        fetchData(region: region, offset: 0, completion: completion)
    }
    
    // @escaping captures data in memeory.
    func fetchData(region: String, offset: Int, completion: @escaping (Result<ImageResponse, Error>) -> Void) {
        let date = Date.getCurrentDate()
        if(storage.jsonExists(atRegion: region, onDate: date)) {
            print("Local storage file exists")
            do {
                let imageInfoArray = try JSONDecoder().decode(ImageResponse.self, from: storage.readJson(atRegion: region, onDate: date))
                return completion(.success(imageInfoArray))
            }
            catch {
                print("Error reading local storage file. Will fetch from network..")
            }
        }
        
        guard let url = URL(string: "\(baseURL)?format=js&n=1&idx=\(offset)&cc=\(region)") else {
            completion(.failure(DataError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data else {
                completion(.failure(DataError.invalidData))
                return
            }
            guard let response = response as? HTTPURLResponse, 200 ... 299  ~= response.statusCode else {
                completion(.failure(DataError.invalidResponse))
                return
            }
            
            // JSONDecoder() converts data to model of type Array
            do {
                let imageInfoArray = try JSONDecoder().decode(ImageResponse.self, from: data)
                self.storage.saveJson(data: data, atRegion: region, onDate: imageInfoArray.images[0].enddate)
                completion(.success(imageInfoArray))
            }
            catch {
                completion(.failure(DataError.message(error)))
            }
        }.resume()
    }
    
    func fetchImage(imageInfo: ImageInfo, atRegion: String) {
        let date = imageInfo.enddate
        if storage.imageExists(atRegion: atRegion, onDate: date) {
            print("Image already exists in local storage")
            return
        }
        
        
        guard let url = URL(string: "https://www.bing.com\(imageInfo.urlbase)_UHD.jpg") else {
            print("Invalid URL")
            return
        }
        
        let task: Void = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to download image: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            print("Image downloaded \(url.absoluteString)")
            self.storage.saveImage(data: data, atRegion: atRegion, onDate: date)
        }.resume()
    }
    
    func setWallpaper(imageInfo: ImageInfo, atRegion: String) {
        let date = imageInfo.enddate
        fetchImage(imageInfo: imageInfo, atRegion: atRegion)
        if storage.imageExists(atRegion: atRegion, onDate: date) {
            NSScreen.screens.forEach({ (screen) in
                try? NSWorkspace.shared.setDesktopImageURL(
                    URL(string: storage.buildImagePath(onDate: date, atRegion: atRegion))!,
                    for: screen,
                    options: [:]
                )
            })
        }
    }
}
