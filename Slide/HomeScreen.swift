//
//  HomeScreen.swift
//  Slide
//
//  Created by Sammy Frankel on 11/30/21.
//

import SwiftUI

struct InputAlert: View {
    @EnvironmentObject var slides: Slides
    var title : String = "Enter your name"
    @Binding var text : String
    let screenSize = UIScreen.main.bounds
    var onDone: (String) -> Void = { _ in }

    var body: some View {
        VStack {
            Text("Congragulations!")
            Text(title)
            TextField("Enter your name", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            HStack {
                Button("Done") {
                    slides.isDone = false
                    self.onDone(self.text)
                }
                Button(action: {
                   EmailHelper.shared.sendEmail(subject: "Slide Puzzle",
                                                body: "Wow! I just finished this Slide puzzle! Check it out!", to: "")
                 }) {
                     Text("Share")
                 }
            }
        } .padding()
            .frame(width: screenSize.width * 0.5, height: screenSize.height * 0.2)
            .background(Color.gray)
            .clipShape(RoundedRectangle(cornerRadius: 20.0))
            .offset(y: slides.isDone ? 0 : screenSize.height)
            .animation(.spring())
            
    }
}



struct HomeScreen: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var stopWatch = StopWatchManager()
    let persistenceController = PersistenceController.shared
    @EnvironmentObject var game : Slides
    @StateObject var slides = Slides()
    @ObservedObject var music : MusicPlayer
    let screenSize = UIScreen.main.bounds
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Score.time, ascending: true)],
        animation: .default)
    private var scores: FetchedResults<Score>
    
    @State var title: String = ""
    @State var instructions: String = ""
    @State var tabSelection = 1
    @State var start : Bool = false
    var body: some View {
        TabView(selection: $tabSelection) {
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


                        }){
                            Image(systemName: music.playing ? "speaker.wave.2.fill" : "speaker.slash.fill")
                                    .renderingMode(.original)
                        }
                        .offset(x: 140)
                
                    Text(title)
                        .font(.custom("Marker Felt Thin", size: 50.0))
                        .animate(using: .easeIn(duration: 3.0), {title = "Slide"
                            start = true
                        })
                        .foregroundColor(Color.black)
                    Text(instructions)
                        .font(.custom("Marker Felt Thin", size: 25.0))
                        .animate(using: .easeIn(duration: 3.0), {instructions = "Select a Gamemode"})
                        .foregroundColor(Color.black)
                    
                    Spacer()
                    HStack {
                        Button("Slide") {
                            tabSelection = 2
                        }
                        .frame(width: 150.0, height: 100.0)
                        .foregroundColor(Color.red)
                        .font(.largeTitle)
                        .background(Color.gray)
                        .opacity(0.5)
                        .cornerRadius(30.0)
                        .offset(x: start ? 0 : (-1 * screenSize.width))
                        .animate(using: .linear(duration: 2.0), {})
                        Button("Swap") {
                            tabSelection = 3
                        }
                        .foregroundColor(Color.red)
                        .frame(width: 150.0, height: 100.0)
                        .font(.largeTitle)
                        .background(Color.gray)
                        .opacity(0.5)
                        .cornerRadius(30.0)
                        .animate(using: .spring(), {})
                        .offset(x: start ? 0 : screenSize.width)
                    }
                    Spacer()
                }
            }
            .tabItem{Label("Home", systemImage: "house")}
            .tag(1)
            
            SlideView(music: music, stopWatch: stopWatch).environmentObject(slides)
                .tabItem {
                    Label("Slide", systemImage: "puzzlepiece.fill")
                }
                .tag(2)
            SwapView(music: music)
                .tabItem {
                    Label("Swap", systemImage: "pip.swap")
                }
                .tag(3)
            Leaderboard(music: music)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .tabItem {
                    Label("High Scores", systemImage: "crown")
                }
            
        }
    }
}

extension View {
    func animate(using animation: Animation = .easeInOut(duration: 1), _ action: @escaping () -> Void) -> some View {
        onAppear {
            withAnimation(animation) {
                action()
            }
        }
    }
}
