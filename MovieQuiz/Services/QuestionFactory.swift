//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Ilya Pokolev on 15.02.2026.
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    // MARK: - State
    
    private enum QuestionType: String, CaseIterable {
        case lesser = "меньше"
        case bigger = "больше"
        
    }
    
    private enum Constants {
        static let defaultRatingThreshold: Float = 7
        static let defaultQuestionType = QuestionType.bigger
        static let ratingRangeForRandom = 1...9
        static let randomRatingTermBound: Float = 0.5
        static let randomRatingTermStep: Float = 0.1
    }
    
    private var randomRatingTerm: Float {
        let index = (0..<moviesRatingRandomTerms.count).randomElement() ?? 0
        return moviesRatingRandomTerms[safe: index] ?? Constants.randomRatingTermStep
    }
    
    private let moviesLoader: MoviesLoadingProtocol
    private weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []
    private var moviesRatingRandomTerms: [Float] = []
    
    // MARK: - Public members
    
    init(moviesLoader: MoviesLoadingProtocol, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
        
        for val in stride(from: -Constants.randomRatingTermBound,
                          to: Constants.randomRatingTermBound,
                          by: Constants.randomRatingTermStep) {
            moviesRatingRandomTerms.append(Float(val))
        }
    }
    
    // MARK: - QuestionFactoryProtocol
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            guard !self.movies.isEmpty else { return }
            
            let index = (0..<self.movies.count).randomElement() ?? 0
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            do {
                imageData = try Data(contentsOf: movie.resizedUrl)
            } catch {
                print("Failed to load image")
            }
            
            let question = CreateQuestion(imageData: imageData, movieRating: movie.rating)
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    // MARK: - Private members
    
    private func CreateQuestion(imageData: Data,
                                actualMovieRating: Float,
                                questionType: QuestionType = Constants.defaultQuestionType,
                                ratingForQuestion: Float = Constants.defaultRatingThreshold) -> QuizQuestion {
        var correctAnswer: Bool
        switch questionType {
        case .lesser:
            correctAnswer = actualMovieRating < ratingForQuestion
        default:
            correctAnswer = actualMovieRating > ratingForQuestion
        }
        
        let text = "Рейтинг этого фильма \(questionType.rawValue) чем \(String(format: "%.1f", ratingForQuestion))?"
        
        return QuizQuestion(image: imageData, text: text, correctAnswer: correctAnswer)
    }
    
    private func CreateQuestion(imageData: Data, movieRating: String) -> QuizQuestion {
        let actualMovieRating = Float(movieRating) ?? 0
        if actualMovieRating.isZero || actualMovieRating < 0 {
            return CreateQuestion(imageData: imageData, actualMovieRating: actualMovieRating)
        }
        
        let randomQuestionType = QuestionType.allCases.randomElement() ?? Constants.defaultQuestionType
        let ratingForQuestion = max(Float(Constants.ratingRangeForRandom.lowerBound),
                                    min(actualMovieRating + Float(randomRatingTerm), Float(Constants.ratingRangeForRandom.upperBound)))
        
        return CreateQuestion(imageData: imageData,
                              actualMovieRating: actualMovieRating,
                              questionType: randomQuestionType,
                              ratingForQuestion: ratingForQuestion)
    }
}
