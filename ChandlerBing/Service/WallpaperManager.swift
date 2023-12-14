//
//  WallpaperManager.swift
//  ChandlerBing
//
//  Created by Ananda Ray on 06/12/23.
//

import Foundation
import SwiftUI

class BingPictureManager {
    
    init() {}
    
    func downloadData() {
        let region = "IN"
        BingAPI.shared.fetchData(region: region, completion: {
            result in
            switch result {
            case .success(let response):
                let imageInfo = response.images[0]
                BingAPI.shared.setWallpaper(imageInfo: imageInfo, atRegion: region)
            case .failure(let error):
                print(error)
            }
        })
    }  
    
    
}

