//
//  SoundManager.swift
//  Slide
//
//  Created by Skylar Luo on 12/4/21.
//

import Foundation
import AVKit

class SoundManager {
    
    static let instance = SoundManager()
    
    var player: AVAudioPlayer?
    
    func slideSound() {
        
        guard let url = Bundle.main.url(forResource: "slideSound", withExtension: ".mp3") else {return}
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch let error {
            print("Error playing sound.")
        }
    }
    
    func gameFinishedSound() {
        
        guard let url = Bundle.main.url(forResource: "gameFinishedSound", withExtension: ".mp3") else {return}
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch let error {
            print("Error playing sound.")
        }
    }
}
