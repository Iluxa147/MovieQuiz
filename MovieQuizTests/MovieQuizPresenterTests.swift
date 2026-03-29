//
//  MovieQuizPresenterTests.swift
//  MovieQuizTests
//
//  Created by Ilya Pokolev on 14.03.2026.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func show(quizStep: QuizStepViewModel) {}
    func show(result: QuizResultsViewModel) {}
    
    func highlightImageBorder(isCorrectAnswer: Bool) {}
    func showLoadingIndicator() {}
    func hideLoadingIndicator() {}
    func setAnswerButtonsUsable(state: Bool) {}
    
    func showNetworkError(message: String) {}
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        // Given
        let viewControllerMock = MovieQuizViewControllerMock()
        let presenter = MovieQuizPresenter(viewController: viewControllerMock)
        let emptyData = Data()
        
        // When
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let quizStepViewModel = presenter.convert(model: question)
        
        // Then
        XCTAssertEqual(quizStepViewModel.posterImage, emptyData)
        XCTAssertEqual(quizStepViewModel.question, "Question Text")
        XCTAssertEqual(quizStepViewModel.questionNumber, "1/10")
    }
}
