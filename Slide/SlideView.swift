//
//  SlideView.swift
//  Slide
//
//  Created by Yoel Popovici on 12/5/21.
//

import SwiftUI

struct SlideView: View {
    @EnvironmentObject var slides: Slides
    
    //core data
    @Environment(\.managedObjectContext) private var viewContext
    let persistenceController = PersistenceController.shared
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Score.time, ascending: true)],
        animation: .default)
    private var scores: FetchedResults<Score>
    
    @State var animationTime: Double = 0.7
    @State var dir: Direction? = nil
    @State var moveTileRow: Int?
    @State var moveTileCol: Int?
    
    @State var name: String = ""
    @State var playing: Bool = false
    @State var gameMode: Int = 100
    
    
    @ObservedObject var music : MusicPlayer
    @ObservedObject var stopWatch : StopWatchManager
    
    var drag: some Gesture {
        DragGesture()
            .onEnded { v in
                
                
                let x = v.startLocation.x
                let y = v.startLocation.y
                
                
                if (x < -39 && x > -101) {
                    moveTileCol = 0
                } else if (x < 31 && x > -36) {
                    moveTileCol = 1
                } else if (x < 96 && x > 34) {
                    moveTileCol = 2
                } else if (x < 161 && x > 99) {
                    moveTileCol = 3
                }
                
                if (y < -39 && y > -101) {
                    moveTileRow = 0
                } else if (y < 31 && y > -36) {
                    moveTileRow = 1
                } else if (y < 96 && y > 34) {
                    moveTileRow = 2
                } else if (y < 161 && y > 99) {
                    moveTileRow = 3
                }
                
                
                if v.translation.height < 0 && abs(v.translation.width) < 10 {
                    dir = Direction.up
                } else if v.translation.height > 0 && abs(v.translation.width) < 10 {
                    dir = Direction.down
                } else if abs(v.translation.height) < 10 && v.translation.width > 0 {
                    dir = Direction.right
                } else if abs(v.translation.height) < 10 && v.translation.width < 0 {
                    dir = Direction.left
                }
                
                if (moveTileRow != nil && moveTileCol != nil && dir != nil) {
                    let (mr,mc) = slides.findMissingTile()
                    if slides.shift(t: slides.board[moveTileRow!][moveTileCol!], dir: dir!) {
                        var d: Direction
                        switch dir! {
                        case Direction.up:
                            d = Direction.down
                        case Direction.down:
                            d = Direction.up
                        case Direction.right:
                            d = Direction.left
                        case Direction.left:
                            d = Direction.right
                        }
                        slides.recordedSlide.append((mr,mc,d))
                        SoundManager.instance.slideSound()
                    }
                    slides.isGameDone()
                    if slides.isDone {
                        SoundManager.instance.gameFinishedSound()
                        self.stopWatch.stop()
                        
                    }
                }
                
            }
    }
    
    var body: some View {
        
        let tiles = slides.board2array()
        let controlConrnerRadius = 15.0
        let x = [-102.0, -34.0 , 34.0, 102.0]
        let y = [-102.0, -34.0, 34.0, 102.0]
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.white, Color(UIColor(red: 0, green: 0.902, blue: 0.949, alpha: 1.0))]), startPoint: .top, endPoint: .bottom)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Button(action: {
                    if (music.playing) {
                        music.audioPlayer?.stop()
                    } else {
                        music.audioPlayer?.play()
                    }
                    
                    music.playing.toggle()
                    print(music.playing)
                    
                }){
                    Image(systemName: music.playing ? "speaker.wave.2.fill" : "speaker.slash.fill")
                        .renderingMode(.original)
                }
                .offset(x: 140)
                Spacer()
                Text(String(format: "%.1f", stopWatch.secondsElapsed))
                    .font(.custom("Marker Felt Thin", size: 60.0))
                    .frame(width: 200, height: 80)
                    .background(RoundedRectangle(cornerRadius: CGFloat(controlConrnerRadius)).fill(Color.yellow))
                    .offset(y:-30)
                
                Spacer()
                
                ZStack {
                    ForEach (tiles) {
                        TileView(tile: $0)
                            .offset(x:CGFloat(x[$0.lastCol]), y:CGFloat(y[$0.lastRow]))
                            .animation(.easeInOut(duration: animationTime))
                            .gesture(drag)
                        
                        
                    }
                }
                
                
                HStack {
                    
                    Button("Scramble") {
                        if (playing) {
                            animationTime = 0.5
                            slides.scramble(times: gameMode)
                            animationTime = 0.7
                            self.stopWatch.stop()
                            self.stopWatch.start()
                        }
                    }.font(.custom("Marker Felt Thin", size: 30.0))
                        .foregroundColor(Color.white)
                        .frame(width: 150, height: 100)
                    .background(RoundedRectangle(cornerRadius: CGFloat(controlConrnerRadius)).fill(Color.yellow))
                        .padding()
                        .offset(x:0, y: 120)
                    
                    Button("Solve") {
                        self.stopWatch.stop()
                        animationTime = 0.3
                        let timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) {
                            (timer) in
                            
                            let step = slides.recordedSlide.popLast()
                            if step == nil {
                                animationTime = 0.7
                                timer.invalidate()
                            } else {
                                let (mr,mc,d) = step!
                                slides.shift(t: slides.board[mr][mc], dir: d)
                            }
                        }
                        
                    }.font(.custom("Marker Felt Thin", size: 30.0))
                        .foregroundColor(Color.white)
                        .frame(width: 120, height: 100)
                    .background(RoundedRectangle(cornerRadius: CGFloat(controlConrnerRadius)).fill(Color.yellow))
                        .padding()
                        .offset(x:0, y: 120)
                }
                
                Menu("New Game") {
                    Button("Easy") {
                        gameMode = 20
                        self.stopWatch.stop()
                        self.stopWatch.restart()
                        slides.newGame()
                        playing = true
                        
                    }
                    Button("Medium") {
                        gameMode = 40
                        self.stopWatch.stop()
                        self.stopWatch.restart()
                        slides.newGame()
                    }
                    Button("Hard") {
                        gameMode = 80
                        self.stopWatch.stop()
                        self.stopWatch.restart()
                        slides.newGame()
                    }
                }
                .font(.custom("Marker Felt Thin", size: 30.0))
                .foregroundColor(Color.white)
                .frame(width: 200, height: 50)
                .background(RoundedRectangle(cornerRadius: CGFloat(controlConrnerRadius)).fill(Color.yellow))
                .padding()
                .offset(x:0, y: 120)
                
                
                Spacer()
            }
            InputAlert(text: $name, onDone: { text in
                addItem(name: text, time: self.stopWatch.secondsElapsed, mode: gameMode)
                
            })
        }
    }
    private func addItem(name: String, time: Double, mode: Int) {
        withAnimation {
            let newScore = Score(context: viewContext)
            newScore.time = time
            newScore.name = name
            newScore.date = Date()
            if (mode == 20) {
                newScore.mode = "Easy"
            }
            if (mode == 40) {
                newScore.mode = "Medium"
            }
            if (mode == 80) {
                newScore.mode = "Hard"
            }
            
            do {
                try viewContext.save()
            } catch {
                
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

//struct SlideView_Previews: PreviewProvider {
//    static var previews: some View {
//        SlideView()
//    }
//}
