//
//  Models.swift
//  WingsJSON
//
//  Created by Conner Yoon on 4/7/25.
//

import Foundation
// MARK: - Models

struct StoryNode: Codable {
    let id: String
    let text: String
    let choices: [Choice]
}

struct Choice: Codable {
    let text: String
    let next: String
    let set: [String: String]?
}

// MARK: - Game Engine

class DragonCYOAGame {
    private var nodes: [String: StoryNode] = [:]
    private var playerState: [String: String] = [:]
    private var currentNode: StoryNode?

    init(jsonData: Data) {
        loadStory(jsonData: jsonData)
    }

    private func loadStory(jsonData: Data) {
        let decoder = JSONDecoder()
        do {
            let storyArray = try decoder.decode([StoryNode].self, from: jsonData)
            for node in storyArray {
                nodes[node.id] = node
            }
            currentNode = nodes["intro_1"]
        } catch {
            print("Failed to load story: \(error)")
        }
    }

    func start() {
        while let node = currentNode {
            present(node: node)
            guard let choiceIndex = getChoiceIndex(from: node) else { break }
            let choice = node.choices[choiceIndex]
            apply(stateChanges: choice.set)
            currentNode = nodes[choice.next]
        }
    }

    private func present(node: StoryNode) {
        let formattedText = formatText(node.text)
        print("\n\(formattedText)\n")
        for (index, choice) in node.choices.enumerated() {
            print("\(index + 1): \(choice.text)")
        }
    }

    private func getChoiceIndex(from node: StoryNode) -> Int? {
        print("Enter your choice:", terminator: " ")
        guard let input = readLine(), let choice = Int(input), choice > 0, choice <= node.choices.count else {
            print("Invalid choice.")
            return nil
        }
        return choice - 1
    }

    private func apply(stateChanges: [String: String]?) {
        guard let changes = stateChanges else { return }
        for (key, value) in changes {
            playerState[key] = value
        }
    }

    private func formatText(_ text: String) -> String {
        var formatted = text
        for (key, value) in playerState {
            formatted = formatted.replacingOccurrences(of: "{{\(key)}}", with: value)
        }
        return formatted
    }
}
