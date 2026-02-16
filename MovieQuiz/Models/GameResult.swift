//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Ilya Pokolev on 16.02.2026.
//

import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan(_ resultToCheck: GameResult) -> Bool {
        return correct > resultToCheck.correct
    }
}
