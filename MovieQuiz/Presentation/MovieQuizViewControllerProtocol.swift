//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Ilya Pokolev on 14.03.2026.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quizStep: QuizStepViewModel)
    func show(result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func setAnswerButtonsUsable(state: Bool)
    
    func showNetworkError(message: String)
} 
