//
//  WallpaperManager.swift
//  ChandlerBing
//
//  Created by Ananda Ray on 06/12/23.
//

import Foundation
import SwiftUI

class BingPictureManager {
    let netRequest = NSMutableURLRequest()
    let fileManager = FileManager.default
    let workDir: URL;
    
    var pastWallpapersRange = 15
    
    init() {
        netRequest.cachePolicy = NSURLRequest.CachePolicy.useProtocolCachePolicy
        netRequest.timeoutInterval = 15
        netRequest.httpMethod = "GET"
        workDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    fileprivate func buildInfoPath(onDate: String, atRegion: String) -> String {
        if atRegion == "" {
            return "\(workDir)/\(onDate).json"
        }
        return "\(workDir)/\(onDate)_\(atRegion).json"
    }
    
    fileprivate func buildImagePath(onDate: String, atRegion: String) -> String {
        if atRegion == "" {
            return "\(workDir)/\(onDate).jpg"
        }
        return "\(workDir)/\(onDate)_\(atRegion).jpg"
    }
    
    fileprivate func checkAndCreateWorkDirectory() {
        try? fileManager.createDirectory(atPath: workDir.absoluteString, withIntermediateDirectories: true, attributes: nil)
    }
    
    fileprivate func obtainWallpaper(atIndex: Int, atRegion: String) {
        let baseURL = "http://www.bing.com/HpImageArchive.aspx";
        guard let url = URL(string: "\(baseURL)?format=js&n=1&idx=\(atIndex)&cc=\(atRegion)") else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to download json: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            print("JSON downloaded")
            self.obtainWallpaperX(atIndex: atIndex, atRegion: atRegion, reponseData: data)
        }

        task.resume()
        
    }
    
    fileprivate func obtainWallpaperX(atIndex: Int, atRegion: String, reponseData: Data) {
        
        print("Processing index " + String(atIndex) + " & region: " + atRegion);

            let data = try? JSONSerialization.jsonObject(with: reponseData, options: []) as AnyObject
            
            if let objects = data?.value(forKey: "images") as? [NSObject] {
                if let startDateString = objects[0].value(forKey: "startdate") as? String,
                    let urlString = objects[0].value(forKey: "urlbase") as? String {
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyyMMdd"
                    if let startDate = formatter.date(from: startDateString) {
                        formatter.dateFormat = "yyyy-MM-dd"
                        let dateString = formatter.string(from: startDate)
                        
                        let infoPath = buildInfoPath(onDate: dateString, atRegion: atRegion)
                        let imagePath = buildImagePath(onDate: dateString, atRegion: atRegion)
                        
                        if !fileManager.fileExists(atPath: infoPath) {
                            checkAndCreateWorkDirectory()
                            
                            //try? data!.write(to: URL(fileURLWithPath: infoPath), options: [.atomic])
                        }
                        
                        if !fileManager.fileExists(atPath: imagePath) {
                            checkAndCreateWorkDirectory()
                            
                            if urlString.contains("http://") || urlString.contains("https://") {
                                netRequest.url = URL.init(string: urlString)
                            } else {
                                netRequest.url = URL.init(string: "https://www.bing.com\(urlString)_UHD.jpg")
                            }
                            
                            //let imageResponData = try? NSURLConnection.sendSynchronousRequest(netRequest as URLRequest, returning: nil)
                            //try? imageResponData?.write(to: URL(fileURLWithPath: imagePath), options: [.atomic])
                            downloadImage(wallpaperUrl: netRequest.url!.absoluteString, downloadFilePath: imagePath)
                        }
                    }
                }
            }
        
    }
    
    func fetchWallpapers(atRegin: String) {
        for index in -1...pastWallpapersRange {
            obtainWallpaper(atIndex: index, atRegion: atRegin)
        }
    }
    
    func fetchLastWallpaper(atRegin: String) {
        obtainWallpaper(atIndex: 0, atRegion: atRegin)
    }
    
    func checkWallpaperExist(workDir: String, onDate: String, atRegion: String) -> Bool {
        if fileManager.fileExists(atPath: buildImagePath(onDate: onDate, atRegion: atRegion)) {
            return true
        }
        return false
    }
    
    func getWallpaperInfo(workDir: String, onDate: String, atRegion: String) -> (copyright: String, copyrightLink: String) {
        let jsonString = try? String.init(contentsOfFile: buildInfoPath(onDate: onDate, atRegion: atRegion))
        
        if let jsonData = jsonString?.data(using: String.Encoding.utf8) {
            let data = try? JSONSerialization.jsonObject(with: jsonData, options: []) as AnyObject
            
            if let objects = data?.value(forKey: "images") as? [NSObject] {
                if let copyrightString = objects[0].value(forKey: "copyright") as? String,
                    let copyrightLinkString = objects[0].value(forKey: "copyrightlink") as? String {
                    return (copyrightString, copyrightLinkString)
                }
            }
        }
        
        return ("", "")
    }
    
    func setWallpaper(workDir: String, onDate: String, atRegion: String) {
        if checkWallpaperExist(workDir: workDir, onDate: onDate, atRegion: atRegion) {
            NSScreen.screens.forEach({ (screen) in
                try? NSWorkspace.shared.setDesktopImageURL(
                    URL(fileURLWithPath: buildImagePath(onDate: onDate, atRegion: atRegion)),
                    for: screen,
                    options: [:]
                )
            })
        }
    }
    
    
    func downloadImage(wallpaperUrl: String, downloadFilePath: String) {
        guard let url = URL(string: wallpaperUrl) else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to download image: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            print("Image downloaded")
            self.saveImageToFile(imageData: data, filePath: URL(fileURLWithPath: downloadFilePath))
        }

        task.resume()
    }
    
    func saveImageToFile(imageData: Data, filePath: URL) {
        do {
            // Save the image data to the given file
            try imageData.write(to: filePath)
            print("Image saved to cache: \(filePath.absoluteString)")
        } catch {
            print("Failed to save image to cache: \(error.localizedDescription)")
        }
    }
}

