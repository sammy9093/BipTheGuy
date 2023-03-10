//
//  ContentView.swift
//  BipTheGuy
//
//  Created by Sammy on 1/18/23.
//

import SwiftUI
import AVFAudio
import PhotosUI




struct ContentView: View {
    @State private var audioPlayer: AVAudioPlayer!
    @State private var selectedPhoto: PhotosPickerItem? //? = Could be nil
    //        This is the audioPlayer object. Implicitly Unwrapped Optional without additional handiling.
    //        @State private var scale = 1.0 // 100% scale, or original size
    @State private var animateImage = true
    @State private var bipImage = Image("clown")
    
    var body: some View {
        VStack {
            Spacer()
            
            bipImage
                .resizable()
                .scaledToFit()
            //                    .scaleEffect(scale)
                .scaleEffect(animateImage ? 1.0 : 0.9)
                .onTapGesture {
                    playSound(soundName: "punchSound")
                    animateImage = false
                    //                         will immediately shrink using .scaleEffect to 90% of size
                    //                        scale = scale + 0.1 // Increase scale by 10%
                    withAnimation (.spring(response: 0.3, dampingFraction: 0.3)) {
                        animateImage = true //will go from 90% size to 100% size but using the .spring animation
                        // All of this leads to a bounce that never increased in size!
                    }
                }
            //                    .animation(.spring(response: 0.3, dampingFraction: 0.3), value: scale)
            
            Spacer()
            
            PhotosPicker(selection: $selectedPhoto, matching: .images, preferredItemEncoding: .automatic) {
                Label("Photo Library", systemImage: "photo.fill.on.rectangle.fill")
            }
            .onChange(of: selectedPhoto) { newValue in
                    // We need to:
                    // - get the data inside the PhotosPickerItem selectedPhoto
                    // - use the data to create a UIImage
                    // - use the UIImage to create an Image,
                    // - and assign that image to bipImage
                Task {
                    do {
                        if let data = try await newValue?.loadTransferable(type: Data.self) {
                            if let uiImage = UIImage(data: data) {
                                bipImage = Image(uiImage: uiImage)
                            }
                        }
                    } catch {
                        print("???? ERRPR:loading failed \(error.localizedDescription)")
                    }
                }
            }
//            .buttonStyle(.borderedProminent)
            
        }
        .padding()
    }
    func playSound(soundName: String) {
        guard let soundFile = NSDataAsset(name: soundName) else {
            print("Could not read file name \(soundName)")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(data: soundFile.data)
            audioPlayer.play()
        } catch {
            print("ERROR: \(error.localizedDescription) creating audioPlayer.")
        }
    }
}
    


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

