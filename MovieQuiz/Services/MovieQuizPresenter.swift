//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Ilya Pokolev on 14.03.2026.
//

import Foundation

final class MovieQuizPresenter: QuestionFactoryDelegate {
    // MARK: - State
    
    private let statisticService: StatisticServiceProtocol!
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    private let questionsAmount: Int = 10
    private var correctAnswersCount = 0
    private var currentQuestionIndex = 0
    private var currentQuestion: QuizQuestion?
    
    // MARK: - Lifecycle
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticService()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        
        currentQuestion = question
        let stepViewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quizStep: stepViewModel)
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - Public members
    
    func noButtonUp() {
        didAnswer(isYes: false)
    }
    
    func yesButtonUp() {
        didAnswer(isYes: true)
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let stepViewModel = QuizStepViewModel(
            posterImage: model.image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
        
        return stepViewModel
    }
    
    func resetCurrentGame(needDataLoading: Bool) {
        currentQuestionIndex = 0
        correctAnswersCount = 0
        
        if needDataLoading {
            questionFactory?.loadData()
        } else {
            questionFactory?.requestNextQuestion()
        }
    }
    
    // MARK: - Private members
    
    private func proceedToNextQuestionOrResults() {
        if isLastQuestion() {
            statisticService.store(correctAnswersCount: correctAnswersCount,
                                   totalQuestionsCount: questionsAmount)
            
            let resultModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                scoreText: makeResultMessage(),
                buttonText: "Сыграть еще раз"
            )
            viewController?.show(result: resultModel)
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        if isCorrect {
            correctAnswersCount += 1
        }
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        viewController?.setAnswerButtonsUsable(state: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    private func makeResultMessage() -> String {
        let currentGameResultMsg = "Ваш результат: \(correctAnswersCount)/\(questionsAmount)"
        guard let statisticService else { return currentGameResultMsg }
        
        let fullResultsMsg = """
        \(currentGameResultMsg)
        Количество сыграных квизов: \(statisticService.gamesCount)
        Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) \
        \(statisticService.bestGame.date.dateTimeString)
        Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
        """
        
        return fullResultsMsg
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion else { return }
        proceedWithAnswer(isCorrect: isYes == currentQuestion.correctAnswer)
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
}
