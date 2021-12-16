//
//  StopWatch.swift
//  Slide
//
//  Created by Sammy Frankel on 11/21/21.
//

import SwiftUI
import Foundation

class StopWatchManager : ObservableObject {
    @Published var secondsElapsed = 0.0
    var timer = Timer()
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            self.secondsElapsed += 0.1
            
        }
    }
    func stop() {
        timer.invalidate()
        
    }
    func restart() {
        self.secondsElapsed = 0.0
    }
    
    
    
}

