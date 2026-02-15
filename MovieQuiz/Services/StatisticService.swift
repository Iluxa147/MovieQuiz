//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Ilya Pokolev on 16.02.2026.
//

import Foundation

final class StatisticService: StatisticServiceProtocol {
    private enum StorageKeys: String {
        case gamesCount
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case totalCorrectAnswers
        case totalQuestionsAsked
    }
    
    // MARK: - Private
    
    private let storage: UserDefaults = .standard
    
    private var totalCorrectAnswers: Int {
        get {
            storage.integer(forKey: StorageKeys.totalCorrectAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: StorageKeys.totalCorrectAnswers.rawValue)
        }
    }
    
    private var totalQuestionsAsked: Int {
        get {
            storage.integer(forKey: StorageKeys.totalQuestionsAsked.rawValue)
        }
        set {
            storage.set(newValue, forKey: StorageKeys.totalQuestionsAsked.rawValue)
        }
    }
    
    // MARK: - StatisticServiceProtocol
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: StorageKeys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: StorageKeys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: StorageKeys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: StorageKeys.bestGameTotal.rawValue)
            let date = storage.object(forKey: StorageKeys.bestGameDate.rawValue) as? Date ?? Date()

            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: StorageKeys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: StorageKeys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: StorageKeys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        guard totalQuestionsAsked != 0 else { return 0 }
        return Double(totalCorrectAnswers) / Double(totalQuestionsAsked) * 100.0
    }
    
    func store(correctAnswersCount: Int, totalQuestionsCount: Int) {
        gamesCount += 1
        totalQuestionsAsked += totalQuestionsCount
        totalCorrectAnswers += correctAnswersCount
        
        let currentResult = GameResult(correct: correctAnswersCount, total: totalQuestionsCount, date: Date())
        if currentResult.isBetterThan(bestGame) {
            bestGame = currentResult
        }
    }
}
