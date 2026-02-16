//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Ilya Pokolev on 16.02.2026.
//

import Foundation

protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    func store(correctAnswersCount: Int, totalQuestionsCount: Int)
}
