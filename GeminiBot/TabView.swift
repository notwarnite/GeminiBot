//
//  TabView.swift
//  GeminiBot
//
//  Created by Ritwik Singh on 01/01/24.
//

import SwiftUI

struct TabItem: Identifiable {
    var id = UUID()
    var dest: AnyView
    var title: Text
    var image: Image
    var tag: Int
}

struct TabNav: View {
    let tabData = [
        TabItem(dest: AnyView(PromptWindow()), title: Text("PROMPT"), image: Image(systemName: "option"), tag: 1),
        TabItem(dest: AnyView(ChatWindow()), title: Text("CHAT"), image: Image(systemName: "option"), tag: 2)
    ]

    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(tabData) { tabItem in
                tabItem.dest
                    .tabItem {
                        Label(
                            title: { tabItem.title },
                            icon: { tabItem.image }
                        )
                    }
                    .tag(tabItem.tag)
            }
        }
    }
}

#Preview {
    TabNav()
}
