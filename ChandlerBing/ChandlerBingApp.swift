//
//  ChandlerBingApp.swift
//  ChandlerBing
//
//  Created by Ananda Ray on 05/12/23.
//

import SwiftUI
import SwiftData

@main
struct ChandlerBingApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}


//import SwiftUI
//
//struct ContentViewX: View {
//    @State private var downloadedImage: NSImage?
//
//    var body: some View {
//        VStack {
//            if let image = downloadedImage {
//                Image(nsImage: image)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 200, height: 200)
//            } else {
//                Button("Download Image") {
//                    downloadImage()
//                }
//            }
//        }
//    }
//
//    func downloadImage() {
//        guard let url = URL(string: "https://i.ytimg.com/vi/2pycF6hMy0s/mqdefault.jpg") else {
//            print("Invalid URL")
//            return
//        }
//
//        let task = URLSession.shared.dataTask(with: url) { data, response, error in
//            guard let data = data, error == nil else {
//                print("Failed to download image: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//
//            if let uiImage = NSImage(data: data) {
//                downloadedImage = uiImage
//                saveImageToCache(imageData: data)
//            }
//        }
//
//        task.resume()
//    }
//
//    func saveImageToCache(imageData: Data) {
//        do {
//            // Get the URL for the app's cache directory
//            if let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
//                let imageURL = cacheURL.appendingPathComponent("downloaded_image.jpg")
//
//                // Save the image data to the cache directory
//                try imageData.write(to: imageURL)
//                print("Image saved to cache: \(imageURL.absoluteString)")
//            }
//        } catch {
//            print("Failed to save image to cache: \(error.localizedDescription)")
//        }
//    }
//}
//
//@main
//struct ImageDownloadApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentViewX()
//        }
//    }
//}
