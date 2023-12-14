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
                BingAPI.shared.fetchImage(imageInfo: response.images[0], atRegion: region)
            case .failure(let error):
                print(error)
            }
        })
    }  
    
    
}

