//
//  ContentView.swift
//  Slide
//
//  Created by Yoel Popovici on 11/15/21.
//

import SwiftUI
import CoreData
import MessageUI

struct TileView: View {
    var tile: Tile
    
    init(tile: Tile) {
        self.tile = tile
    }
    
    var body: some View {
        Image("cat_\(tile.id)")
            .resizable()
            .scaledToFit()
            .frame(width: 60, height: 60)
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var stopWatch = StopWatchManager()
    let persistenceController = PersistenceController.shared
    @EnvironmentObject var game : Slides
    @StateObject var slides = Slides()
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Score.time, ascending: true)],
        animation: .default)
    private var scores: FetchedResults<Score>
    @ObservedObject var music = MusicPlayer()
    init() {
        music.startBackgroundMusic(sound: "wii", type: "mp3")
    }
    var body: some View {
        HomeScreen(music: music)
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

extension UIImage {
    var topHalf: UIImage? {
        guard let image = cgImage?
                .cropping(to: CGRect(origin: .zero,
                                     size: CGSize(width: size.width,
                                                  height: size.height / 2 )))
        else { return nil }
        return UIImage(cgImage: image, scale: 1, orientation: imageOrientation)
    }
    var bottomHalf: UIImage? {
        guard let image = cgImage?
                .cropping(to: CGRect(origin: CGPoint(x: 0,
                                                     y: size.height - (size.height/2).rounded()),
                                     size: CGSize(width: size.width,
                                                  height: size.height -
                                                  (size.height/2).rounded())))
        else { return nil }
        return UIImage(cgImage: image)
    }
    var leftHalf: UIImage? {
        guard let image = cgImage?
                .cropping(to: CGRect(origin: .zero,
                                     size: CGSize(width: size.width/2,
                                                  height: size.height)))
        else { return nil }
        return UIImage(cgImage: image)
    }
    var rightHalf: UIImage? {
        guard let image = cgImage?
                .cropping(to: CGRect(origin: CGPoint(x: size.width - (size.width/2).rounded(), y: 0),
                                     size: CGSize(width: size.width - (size.width/2).rounded(),
                                                  height: size.height)))
        else { return nil }
        return UIImage(cgImage: image)
    }
}
struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView().environmentObject(Slides())
        
    }
}
