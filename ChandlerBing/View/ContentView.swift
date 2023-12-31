//
//  ContentView.swift
//  ChandlerBing
//
//  Created by Ananda Ray on 05/12/23.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        VStack {
                            Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                            
                            
                            
                            HStack {
                                Button(action: {
                                    BingPictureManager().downloadData()
                                }) {
                                    Text("<")
                                }
                                Button(action: {
                                    BingPictureManager().downloadData()
                                }) {
                                    Text("Set Wallpaper")
                                }
                                Button(action: {
                                    BingPictureManager().downloadData()
                                }) {
                                    Text(">")
                                }
                            }
                            
                            Button(action: {
                                LocalStorage().openCacheFolder()
                            }) {
                                Text("Open Cache Folder")
                            }
                        }
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
