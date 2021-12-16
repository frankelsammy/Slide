//
//  SwapLeaderBoardView.swift
//  Slide
//
//  Created by Yoel Popovici on 12/2/21.
//

import SwiftUI

struct SwapLeaderBoardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(entity: Score_Swap.entity(), sortDescriptors: [])
    private var scores: FetchedResults<Score_Swap>
    
    
    var body: some View {
        ZStack{
            Color.red
            VStack{
                NavigationView {
                    ZStack{
                        
                        List {
                            ForEach(scores) { score in
                                ZStack{
                                    NavigationLink(destination: SavedSwapScoreView(score: score)) {
                                        
                                        Text("\(score.totalMoves) moves on \(score.timeStamp!)")
                                            .font(.custom("Marker Felt Thin", size: 20.0))
                                    }
                                }
                            }.onDelete(perform: deleteItems)
                        }
                    }
                }
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { scores[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}


struct SavedSwapScoreView: View {
    var score: Score_Swap
    
    var body: some View {
        ZStack{
            VStack {
                Text("You made \(score.totalMoves) moves on \(score.timeStamp!) to beat this puzzle")
                    .font(.title)
                    .foregroundColor(Color.white)
                    .frame(width: 340, height: 150)
                    .background(RoundedRectangle(cornerRadius: CGFloat(15)).fill(Color.yellow))
                    .padding()
                Image(uiImage: UIImage(data: (score.puzzleSolved)!)!).resizable().scaledToFit()
                
            }
        }
    }
    
}

struct SwapLeaderBoardView_Previews: PreviewProvider {
    static var previews: some View {
        SwapLeaderBoardView()
    }
}

