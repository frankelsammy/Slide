//
//  Leaderboard.swift
//  Slide
//
//  Created by Sammy Frankel on 11/19/21.
//
import CoreData
import SwiftUI
import Foundation
import AudioToolbox

struct Leaderboard: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isSlide = true
    @State private var mode = "Slide"
    @ObservedObject var music : MusicPlayer
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Score.time, ascending: true)],
        animation: .default)
    private var scores: FetchedResults<Score>
    
    @FetchRequest(entity: Score_Swap.entity(), sortDescriptors: [])
    private var score_swap: FetchedResults<Score_Swap>
    init(music: MusicPlayer) {
        UITableView.appearance().tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Double.leastNonzeroMagnitude))
        // Remove lines between rows
        UITableView.appearance().separatorColor = .clear
        // Set list row background color to clear
        UITableViewCell.appearance().backgroundColor = UIColor.clear
        // Set list background color to clear
        UITableView.appearance().backgroundColor = UIColor.clear
        self.music = music
    }
    
    
    var body: some View {
        let controlConrnerRadius = 15.0
        ZStack {
//            LinearGradient(gradient: Gradient(colors: [Color.white, Color(UIColor(red: 0, green: 0.902, blue: 0.949, alpha: 1.0))]), startPoint: .top, endPoint: .bottom)
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .edgesIgnoringSafeArea(.all)
            
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
                
                Text("Top Scores")
                    .font(.custom("Marker Felt Thin", size: 50.0))
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color.black)
                if(isSlide){
                    
                    List {
                        ForEach(scores) { score in
                            Text("\(round(score.time * 10) / 10.0) seconds by " + score.name! + " (\(score.mode!))")
                                .font(.custom("Marker Felt Thin", size: 20.0))
                            
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .opacity(0.5)
                    
                }else{
                    SwapLeaderBoardView()
                }
                
                Spacer()
                
                
                    Button(action: gameMode) {
                        Text("\(mode)")
                    }.font(.title)
                    .foregroundColor(Color.white)
                    .frame(width: 150, height: 100)
                    .background(RoundedRectangle(cornerRadius: CGFloat(controlConrnerRadius)).fill(Color.yellow))
                    .padding()
    
                
                
            }
            
        }
    }
    
    private func gameMode(){
        isSlide = !isSlide
        if(isSlide){
            mode = "Slide"
        }else{
            mode = "Swap"
        }
    }
    
    
    private func addItem() {
        withAnimation {
            let newScore = Score(context: viewContext)
            newScore.time = 10.0
            newScore.name = "sammy"
            newScore.date = Date()
            
            do {
                try viewContext.save()
            } catch {
                
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { scores[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

