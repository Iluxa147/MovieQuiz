import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - UI
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    // MARK: - State
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactory = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    
    private var currentQuestionIndex = 0 // TODO unused
    private var correctAnswersCount = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let firstQuestion = questionFactory.requestNewQuestion() {
            currentQuestion = firstQuestion
            let stepViewModel = convert(model: firstQuestion)
            show(quizStep: stepViewModel)
        }
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
    
    private func setAnswerButtonsUsable(state: Bool) {
        noButton.isUserInteractionEnabled = state
        yesButton.isUserInteractionEnabled = state
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let stepViewModel = QuizStepViewModel(
            posterImage: UIImage(named: model.imageName) ?? UIImage(),
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
            let resultModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                scoreText: "Ваш результат: \(correctAnswersCount)/\(questionsAmount)",
                buttonText: "Сыграть еще раз"
            )
            show(result: resultModel)
        } else {
            if let nextQuestion = questionFactory.requestNewQuestion() {
                currentQuestionIndex += 1
                currentQuestion = nextQuestion
                let stepViewModel = convert(model: nextQuestion)
                show(quizStep: stepViewModel)
            }
        }
    }
    
    private func show(result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.scoreText,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswersCount = 0
            
            if let firstQuestion = self.questionFactory.requestNewQuestion() {
                self.currentQuestion = firstQuestion
                let stepViewModel = self.convert(model: firstQuestion)
                self.show(quizStep: stepViewModel)
            }
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
