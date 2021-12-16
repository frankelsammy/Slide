//
//  SwapView.swift
//  Slide
//
//  Created by Yoel Popovici on 12/2/21.
//

import SwiftUI

struct SwapView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var showImagePicker = false
    @State private var inputImage: UIImage?
    @State private var prevInputImage: UIImage?
    @State private var image: Image?
    @State private var imageArray = [(UIImage, Int)]()
    @State private var tile1: Int?
    @State private var tile2: Int?
    @State private var columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())]
    @State private var boardSize: Int = 2
    @State private var numMoves = 0
    @State private var answers: [Int]?
    @State private var showingAlert = false
    @ObservedObject var music : MusicPlayer
    
    
    var body: some View {
        let controlConrnerRadius = 15.0
        ZStack{
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
                .offset(x: 100)
                
                if image != nil {
                    //                ZStack{
                    //                    Color.purple
                    HStack{
                        Text("Moves \(numMoves)").padding().font(.title)
                            .foregroundColor(Color.white)
                            .frame(width: 150, height: 150)
                            .background(RoundedRectangle(cornerRadius: CGFloat(controlConrnerRadius)).fill(Color.yellow))
                        Image(uiImage: inputImage!).resizable().frame(width: 150, height: 150).clipped().scaledToFill()
                    }
                    LazyVGrid(columns: self.columns) {
                        ForEach(0..<self.imageArray.count, id: \.self){ uiImageIndex in
                            Image(uiImage: imageArray[uiImageIndex].0).resizable().scaledToFit().onTapGesture {
                                if tile1 == nil {
                                    tile1 = uiImageIndex
                                }else {
                                    tile2 = uiImageIndex
                                    swap()
                                    checkSolution()
                                }
                                
                            }
                        }
                    }.alert(isPresented: $showingAlert) {
                        Alert(
                            title: Text("You win in \(numMoves), Congragulations."),
                            message: Text("Game over"), dismissButton: .default( Text("New Game"),
                                                                                 action: newGame))
                        
                        
                    }
                    
                    Text("New Photo")
                        .onTapGesture {
                            self.showImagePicker = true
                        }.sheet(isPresented: $showImagePicker, onDismiss: loadImage, content: {
                            ImagePicker(image: self.$inputImage)
                        }).font(.title)
                        .foregroundColor(Color.white)
                        .frame(width: 150, height: 100)
                        .background(RoundedRectangle(cornerRadius: CGFloat(controlConrnerRadius)).fill(Color.yellow))
                        .padding()
                        .offset(x:0, y: 60)
                    Spacer()
                } else {
                    Text("Tap to insert image").sheet(isPresented: $showImagePicker, onDismiss: loadImage) {
                        ImagePicker(image: self.$inputImage)
                    }.font(.title)
                    .foregroundColor(Color.white)
                    .frame(width: 300, height: 300)
                    .background(RoundedRectangle(cornerRadius: CGFloat(controlConrnerRadius)).fill(Color.yellow))
                    .padding().onTapGesture {
                        self.showImagePicker = true
                    }.sheet(isPresented: $showImagePicker, onDismiss: loadImage, content: {
                        ImagePicker(image: self.$inputImage)
                    })
                }
            }
        }
    }
    
    func newGame(){
        showingAlert = false
        addScoreToLeaderboards()
        numMoves = 0
        imageArray = []
    }
    
    
    private func addScoreToLeaderboards() {
        let newScore = Score_Swap(context: viewContext)
        
        // date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_US")
        let date = Date()
        
        newScore.timeStamp = dateFormatter.string(from: date)
        newScore.totalMoves = Int32(numMoves)
        
        let data = inputImage!.jpegData(compressionQuality: 1.0)
        newScore.puzzleSolved = data
        
        do {
            try viewContext.save()
            print("saved successfully")
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    
    func checkSolution(){
        
        for i in 0..<answers!.count{
            print(imageArray[i].1)
        }
        for i in 0..<answers!.count{
            if(answers![i] != imageArray[i].1){
                print("keep trying")
                return
            }
        }
        showingAlert = true
    }
    
    func swap(){
        if(tile1 != nil && tile2 != nil && tile1 == tile2){
            tile1 = nil
            tile2 = nil
            
        }
        if tile1 != nil && tile2 != nil && tile1 != tile2{
            let temp = imageArray[tile1!]
            imageArray[tile1!] = imageArray[tile2!]
            imageArray[tile2!] = temp
            tile1 = nil
            tile2 = nil
            numMoves += 1
        }
    }
    
    func parseImage(image: UIImage, count: Int, imageArray: inout [(UIImage, Int)], randomBool: Bool) {
        if(count == boardSize){
            imageArray.append((image, imageArray.count + 1))
        }else{
            if(randomBool == true){
                parseImage(image: (image.leftHalf?.topHalf)!, count: count + 1,imageArray: &imageArray, randomBool: randomBool)
                parseImage(image: (image.leftHalf?.bottomHalf)!, count: count + 1,imageArray: &imageArray, randomBool: randomBool)
                parseImage(image: (image.rightHalf?.topHalf)!, count: count + 1,imageArray: &imageArray, randomBool: randomBool)
                parseImage(image:(image.rightHalf?.bottomHalf)!, count: count + 1,imageArray: &imageArray, randomBool: randomBool)
            }else{
                parseImage(image: (image.rightHalf?.topHalf)!, count: count + 1,imageArray: &imageArray, randomBool: randomBool)
                parseImage(image: (image.leftHalf?.bottomHalf)!, count: count + 1,imageArray: &imageArray, randomBool: randomBool)
                parseImage(image:(image.rightHalf?.bottomHalf)!, count: count + 1,imageArray: &imageArray, randomBool: randomBool)
                parseImage(image: (image.leftHalf?.topHalf)!, count: count + 1,imageArray: &imageArray, randomBool: randomBool)
            }
        }
        
    }
    
    func loadImage() {
        if(prevInputImage != inputImage){
            numMoves = 0
            imageArray = []
            guard let inputImage = inputImage else {return }
            image = Image(uiImage: inputImage)
            let randomBool = Bool.random()
            parseImage(image: inputImage, count: 0, imageArray: &imageArray, randomBool: randomBool)
            if(randomBool){
                self.answers = [1,3,9,11,2,4,10,12,5,7,13,15,6,8,14,16]
            }else{
                self.answers =  [16,13,4,1,14,15,2,3,8,5,12,9,6,7,10,11]
            }
            prevInputImage = inputImage
        }
    }
}

