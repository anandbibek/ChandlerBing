//
//  LocalStorage.swift
//  ChandlerBing
//
//  Created by Ananda Ray on 10/12/23.
//

import Foundation
import AppKit

class LocalStorage {
    let fileManager = FileManager.default
    let cacheDir: URL;
    
    init() {
        self.cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        print("cache dir \(cacheDir.absoluteString)")
        initCacheDir()
    }
    
    func openCacheFolder() {
        showInFinder(url: cacheDir)
    }
    
    
    func jsonExists(atRegion: String, onDate: String) -> Bool {
        return fileExists(atPath: buildDataPath(onDate: onDate, atRegion: atRegion))
    }
    
    func saveJson(data: Data, atRegion: String, onDate: String) {
        saveToFile(data: data, filePath: buildDataPath(onDate: onDate, atRegion: atRegion))
    }
    
    func imageExists(atRegion: String, onDate: String) -> Bool {
        return fileExists(atPath: buildImagePath(onDate: onDate, atRegion: atRegion))
    }
    
    func saveImage(data: Data, atRegion: String, onDate: String) {
        saveToFile(data: data, filePath: buildImagePath(onDate: onDate, atRegion: atRegion))
    }
    
    func saveToFile(data: Data, filePath: String) {
        guard let url = URL(string: filePath) else {
            print("Invalid filepath for URL")
            return
        }
        
        do {
            try data.write(to: url, options: [.atomic])
            print("Saved to cache: \(url.absoluteString)")
        } catch {
            print("Failed to save file: \(error.localizedDescription)")
        }
    }
    
    func readJson(atRegion: String, onDate: String) -> Data {
        let filepath = buildDataPath(onDate: onDate, atRegion: atRegion)
        do {
            return try Data(contentsOf: URL(string: filepath)!)
        } catch {
            print("Failed to read file \(filepath)")
            return Data()
        }
    }
    
    func fileExists(atPath: String) -> Bool {
        return fileManager.fileExists(atPath: (URL(string: atPath)?.path())!)
    }

    func showInFinder(url: URL) {
        if(url.hasDirectoryPath) {
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path())
        } else {
            NSWorkspace.shared.activateFileViewerSelecting([url])
        }
    }
    
    func buildDataPath(onDate: String, atRegion: String) -> String {
        if atRegion == "" {
            return "\(cacheDir)/.json"
        }
        return "\(cacheDir)/\(onDate)_\(atRegion).json"
    }
    
    func buildImagePath(onDate: String, atRegion: String) -> String {
        if atRegion == "" {
            return "\(cacheDir)/\(onDate).jpg"
        }
        return "\(cacheDir)/\(onDate)_\(atRegion).jpg"
    }
    
    fileprivate func initCacheDir() {
        try? fileManager.createDirectory(atPath: cacheDir.path(), withIntermediateDirectories: true, attributes: nil)
    }
}
