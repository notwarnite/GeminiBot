//
//  PromptWindow.swift
//  GeminiBot
//
//  Created by Ritwik Singh on 01/01/24.
//

import SwiftUI
import GoogleGenerativeAI

struct PromptWindow: View {
    let model = GenerativeModel(name: "gemini-pro", apiKey: APIKey.default)
    let modelImage = GenerativeModel(name: "gemini-pro-vision", apiKey: APIKey.default)

    
    @State var textInput = ""
    @State var aiResponse = "Hello! What brings you here?"
    @State var isLoading = false
    
    var body: some View {
        ZStack{
            LinearGradient(
                colors: [
                    Color.blue,
                    Color.purple,
                    Color.cyan
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                Image(.logo)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                
                ScrollView {
                    if isLoading{
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    }
                    else{
                        Text(aiResponse)
                            .font(.title)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                HStack {
                    TextField("Enter Prompt", text: $textInput)
                        .textFieldStyle(.roundedBorder)
                        .foregroundColor(.black)
                        .disabled(isLoading)
                    
//                    Button(action: uploadImage, label: {
//                        Image(systemName: "photo.fill")
//                            .foregroundColor(.white)
////                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
//                    })
                    
                    Button(action: sendRequest, label: {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
//                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    })
                }
            }
            .padding()
        }
        
    }
    
    func sendRequest() {
        aiResponse = ""
        Task {
            do {
                isLoading = true
                let response = try await model.generateContent(textInput)
                guard let text = response.text else {
                    textInput = "Sorry, Try Again :("
                    isLoading = false
                    return
                }
                
                isLoading = false
                textInput = ""
                aiResponse = text
                
            }catch {
                isLoading = false
                aiResponse = "Something Went Wrong!!!"
            }
            
        }
    }
}
    
    #Preview {
        PromptWindow()
    }
