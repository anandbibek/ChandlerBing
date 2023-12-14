//
//  Helper.swift
//  ChandlerBing
//
//  Created by Ananda Ray on 13/12/23.
//

import Foundation

extension Date {

 static func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.string(from: Date())
    }
}
