//
//  TabView.swift
//  GeminiBot
//
//  Created by Ritwik Singh on 01/01/24.
//

import SwiftUI

struct TabNav: View {
    var body: some View {
        TabView {
            PromptWindow()
                .tabItem {
                    Label("Prompt", systemImage: "list.dash")
                }
                .tag(1)
            
            ChatWindow()
                .tabItem {
                    Label("Chat", systemImage: "list.dash")
                }
                .tag(2)
        }
    }
}

#Preview {
    TabNav()
}
