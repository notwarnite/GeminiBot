//
//  ChatWindow.swift
//  GeminiBot
//
//  Created by Ritwik Singh on 01/01/24.
//

import Foundation
import SwiftUI
import GoogleGenerativeAI

enum ChatRole {
    case user
    case model
}

struct ChatMessage: Identifiable, Equatable {
    let id = UUID().uuidString
    var role: ChatRole
    var message: String
}

@Observable
class ChatModel {
    private var chat: Chat?
    private(set) var messages = [ChatMessage]()
    private(set) var loadingResponse = false
    
    func sendMessage(_ message: String) {
        loadingResponse = true
        
        if (chat == nil) {
            let history: [ModelContent] = messages.map { ModelContent(role: $0.role == .user ? "user" : "model", parts: $0.message)}
            chat = GenerativeModel(name: "gemini-pro", apiKey: APIKey.default).startChat(history: history)
        }
        
        messages.append(.init(role: .user, message: message))
        
        Task {
            do {
                let response = try await chat?.sendMessage(message)
                
                loadingResponse = false
                
                guard let text = response?.text else {
                    messages.append(.init(role: .model, message: "Something went wrong!!!"))
                    return
                }
                
                messages.append(.init(role: .model, message: text))
            }
            catch {
                loadingResponse = false
                messages.append(.init(role: .model, message: "Something went wrong!!!"))
            }
        }
    }
}



// ref: https://github.com/prafullakumar/ChatUI/blob/master/ChatUI/ChatBubble.swift

struct ChatBubbleShape: Shape {
    enum Direction {
        case left
        case right
    }
    
    let direction: Direction
    
    func path(in rect: CGRect) -> Path {
        return (direction == .left) ? getLeftBubblePath(in: rect) : getRightBubblePath(in: rect)
    }
    
    private func getLeftBubblePath(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let path = Path { p in
            p.move(to: CGPoint(x: 25, y: height))
            p.addLine(to: CGPoint(x: width - 20, y: height))
            p.addCurve(to: CGPoint(x: width, y: height - 20),
                       control1: CGPoint(x: width - 8, y: height),
                       control2: CGPoint(x: width, y: height - 8))
            p.addLine(to: CGPoint(x: width, y: 20))
            p.addCurve(to: CGPoint(x: width - 20, y: 0),
                       control1: CGPoint(x: width, y: 8),
                       control2: CGPoint(x: width - 8, y: 0))
            p.addLine(to: CGPoint(x: 21, y: 0))
            p.addCurve(to: CGPoint(x: 4, y: 20),
                       control1: CGPoint(x: 12, y: 0),
                       control2: CGPoint(x: 4, y: 8))
            p.addLine(to: CGPoint(x: 4, y: height - 11))
            p.addLine(to: CGPoint(x: -0.05, y: height - 0.01))
            
        }
        return path
    }
    
    private func getRightBubblePath(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let path = Path { p in
            p.move(to: CGPoint(x: 25, y: height))
            p.addLine(to: CGPoint(x:  20, y: height))
            p.addCurve(to: CGPoint(x: 0, y: height - 20),
                       control1: CGPoint(x: 8, y: height),
                       control2: CGPoint(x: 0, y: height - 8))
            p.addLine(to: CGPoint(x: 0, y: 20))
            p.addCurve(to: CGPoint(x: 20, y: 0),
                       control1: CGPoint(x: 0, y: 8),
                       control2: CGPoint(x: 8, y: 0))
            p.addLine(to: CGPoint(x: width - 21, y: 0))
            p.addCurve(to: CGPoint(x: width - 4, y: 20),
                       control1: CGPoint(x: width - 12, y: 0),
                       control2: CGPoint(x: width - 4, y: 8))
            p.addLine(to: CGPoint(x: width - 4, y: height - 11))
            p.addLine(to: CGPoint(x: width + 0.05, y: height - 0.01))
            
        }
        return path
    }
}

struct ChatBubble<Content>: View where Content: View {
    let direction: ChatBubbleShape.Direction
    let content: () -> Content
    init(direction: ChatBubbleShape.Direction, @ViewBuilder content: @escaping () -> Content) {
            self.content = content
            self.direction = direction
    }
    
    var body: some View {
        HStack {
            if direction == .right {
                Spacer()
            }
            content().clipShape(ChatBubbleShape(direction: direction))
            if direction == .left {
                Spacer()
            }
        }.padding([(direction == .left) ? .leading : .trailing, .top, .bottom], 20)
        .padding((direction == .right) ? .leading : .trailing, 50)
    }
}

struct ChatWindow: View {
    @State var textInput = ""
    @State var logoAnimating = false
    @State var timer: Timer?
    @State var chatModel = ChatModel()
    var body: some View {
        ZStack {
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
                ScrollView {
                    ForEach(chatModel.messages) { chatMessage in
                        chatMessageView(chatMessage)
                    }
                }
                .frame(maxWidth: .infinity)
                .overlay {
                    if chatModel.messages.isEmpty {
                        ContentUnavailableView(label: {
                            Label("Enter Message To Start Chat", systemImage: "bubble.left.and.bubble.right.fill")
                        })
                        .offset(y: -40)
                    }
                }
                
                HStack {
                    TextField("Enter Message", text: $textInput)
                        .textFieldStyle(.roundedBorder)
                        .foregroundColor(.black)
                    
                    Button(action: sendMessage, label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.white)
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    })
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder func chatMessageView(_ message: ChatMessage) -> some View {
        ChatBubble(direction: message.role == .model ? .left : .right) {
            Text(message.message)
                .padding(.all, 20)
                .foregroundStyle(.white)
                .background(message.role == .model ? Color.blue : Color.green)
        }
    }
    
    func sendMessage() {
        chatModel.sendMessage(textInput)
        textInput = ""
    }
}

#Preview {
    ChatWindow()
}
