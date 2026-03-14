//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Ilya Pokolev on 14.03.2026.
//

import Foundation

final class MovieQuizPresenter {
    
    let questionsAmount: Int = 10
    private var currentQuestionIndex = 0
    
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let stepViewModel = QuizStepViewModel(
            //posterImage: UIImage(data: model.image) ?? UIImage(),
            posterImage: model.image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
        
        return stepViewModel
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
}
