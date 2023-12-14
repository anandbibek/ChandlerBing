//
//  Image.swift
//  ChandlerBing
//
//  Created by Ananda Ray on 11/12/23.
//

import Foundation

final class ImageInfo: Codable {
    
    let startdate, fullstartdate, enddate, url: String
    let urlbase, copyright: String
    let copyrightlink: String
    let title, quiz: String
    let wp: Bool
    let hsh: String
    let drk, top, bot: Int
    let hs: [String]
    
}

final class ImageResponse: Codable {
    let images: [ImageInfo]
}
