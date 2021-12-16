//
//  Music.swift
//  Slide
//
//  Created by Sammy Frankel on 12/2/21.
//

import SwiftUI
import AVFoundation
import Foundation

class MusicPlayer : ObservableObject {
    
    var audioPlayer: AVAudioPlayer?
    @Published var playing: Bool = false
    func startBackgroundMusic(sound: String, type: String) {
        if let path = Bundle.main.path(forResource: sound, ofType: type) {
            do  {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer?.play()
                audioPlayer?.numberOfLoops = -1
                playing = true
            } catch {
                print("Can't find file ")
            }
        }
        }
}
struct Music: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct Music_Previews: PreviewProvider {
    static var previews: some View {
        Music()
    }
}
