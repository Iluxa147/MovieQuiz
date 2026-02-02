import UIKit

struct QuizQuestion {
    let imageName: String
    let text: String
    let correctAnswer: Bool
}

struct QuizStepViewModel {
  let posterImage: UIImage
  let question: String
  let questionNumber: String
}

struct QuizResultsViewModel {
  let title: String
  let scoreText: String
  let buttonText: String
}

final class MovieQuizViewController: UIViewController {
    // MARK: - UI
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    // MARK: - State
    private var currentQuestionIndex = 0
    private var correctAnswersCount = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let firstQuestion = questions[currentQuestionIndex]
        let stepViewModel = convert(model: firstQuestion)
        show(quizStep: stepViewModel)
    }
    
    // MARK: - Actions
    
    @IBAction private func noButtonUp(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonUp(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
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
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)"
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            let resultModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                scoreText: "Ваш результат: \(correctAnswersCount)/\(questions.count)",
                buttonText: "Сыграть еще раз"
            )
            show(result: resultModel)
        } else {
            currentQuestionIndex += 1
            let nextQuestion = questions[currentQuestionIndex]
            let stepViewModel = convert(model: nextQuestion)
            show(quizStep: stepViewModel)
        }
    }
    
    private func show(result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.scoreText,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.currentQuestionIndex = 0
            self.correctAnswersCount = 0
            
            let firstQuestion = self.questions[self.currentQuestionIndex]
            let stepViewModel = self.convert(model: firstQuestion)
            self.show(quizStep: stepViewModel)
        }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Mock
    private let questions: [QuizQuestion] = [
            QuizQuestion(
                imageName: "The Godfather",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                imageName: "The Dark Knight",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                imageName: "Kill Bill",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                imageName: "The Avengers",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                imageName: "Deadpool",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                imageName: "The Green Knight",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                imageName: "Old",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                imageName: "The Ice Age Adventures of Buck Wild",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                imageName: "Tesla",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                imageName: "Vivarium",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false)
        ]
}
