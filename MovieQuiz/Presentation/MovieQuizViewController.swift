import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - UI
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - State
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticServiceProtocol?
    private var alertPresenter = AlertPresenter()
    private var currentQuestion: QuizQuestion?
    
    private var currentQuestionIndex = 0
    private var correctAnswersCount = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statisticService = StatisticService()
        
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        //questionFactory.setup(delegate: self) // TODO delete
        self.questionFactory = questionFactory
        
        showLoadingIndicator()
        self.questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        
        currentQuestion = question
        let stepViewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quizStep: stepViewModel)
        }
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - Actions
    
    @IBAction private func noButtonUp(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonUp(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
    
    // MARK: - Private members
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        //activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswersCount = 0
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter.show(at: self, alertModel: alertModel)
    }
    
    private func setAnswerButtonsUsable(state: Bool) {
        noButton.isUserInteractionEnabled = state
        yesButton.isUserInteractionEnabled = state
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let stepViewModel = QuizStepViewModel(
            posterImage: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
        
        return stepViewModel
    }
    
    private func show(quizStep: QuizStepViewModel) {
        setAnswerButtonsUsable(state: true)
        
        counterLabel.text = quizStep.questionNumber
        posterImageView.image = quizStep.posterImage
        posterImageView.layer.borderWidth = 0
        questionLabel.text = quizStep.question
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswersCount += 1
        }
        
        posterImageView.layer.borderWidth = 8
        posterImageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        setAnswerButtonsUsable(state: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService?.store(correctAnswersCount: correctAnswersCount, totalQuestionsCount: questionsAmount)
            
            let resultModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                scoreText: makeResultMessage(),
                buttonText: "Сыграть еще раз"
            )
            show(result: resultModel)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func show(result: QuizResultsViewModel) {
        let alertModel = AlertModel(title: result.title, message: result.scoreText, buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswersCount = 0
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter.show(at: self, alertModel: alertModel)
    }
    
    private func makeResultMessage() -> String {
        let currentGameResultMsg = "Ваш результат: \(correctAnswersCount)/\(questionsAmount)"
        guard let statisticService = statisticService else { return currentGameResultMsg }
        
        let fullResultsMsg = """
        \(currentGameResultMsg)
        Количество сыграных квизов: \(statisticService.gamesCount)
        Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) \
        \(statisticService.bestGame.date.dateTimeString)
        Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
        """
        
        return fullResultsMsg
    }
}
