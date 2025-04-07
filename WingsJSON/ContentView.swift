//
//  ContentView.swift
//  WingsJSON
//
//  Created by Conner Yoon on 4/7/25.
//

import SwiftUI

// MARK: - ViewModel

class GameViewModel: ObservableObject {
    @Published var currentText: String = ""
    @Published var choices: [Choice] = []

    private var game: DragonCYOAGame?

    init() {
        loadGame()
    }

    func loadGame() {
        if let url = Bundle.main.url(forResource: "intro", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            game = DragonCYOAGame(jsonData: data)
            updateUI()
        } else {
            currentText = "Failed to load story."
        }
    }

    func choose(_ index: Int) {
        game?.makeChoice(index)
        updateUI()
    }

    private func updateUI() {
        guard let node = game?.currentNode else {
            currentText = "The story has ended."
            choices = []
            return
        }
        currentText = game?.formattedText(for: node) ?? ""
        choices = node.choices
    }
}

// MARK: - SwiftUI View

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ScrollView {
                Text(viewModel.currentText)
                    .font(.title2)
                    .padding()
            }

            ForEach(viewModel.choices.indices, id: \.self) { index in
                Button(action: {
                    viewModel.choose(index)
                }) {
                    Text(viewModel.choices[index].text)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(10)
                }
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

