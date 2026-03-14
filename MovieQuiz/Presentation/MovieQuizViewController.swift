import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    // MARK: - UI
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - State
    
    private var presenter: MovieQuizPresenter!
    private var alertPresenter = AlertPresenter()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    // MARK: - Actions
    
    @IBAction private func noButtonUp(_ sender: UIButton) {
        presenter.noButtonUp()
    }
    
    @IBAction private func yesButtonUp(_ sender: UIButton) {
        presenter.yesButtonUp()
    }
    
    // MARK: - MovieQuizViewControllerProtocol
    
    func show(quizStep: QuizStepViewModel) {
        setAnswerButtonsUsable(state: true)
        
        counterLabel.text = quizStep.questionNumber
        posterImageView.image = UIImage(data: quizStep.posterImage) ?? UIImage()
        posterImageView.layer.borderWidth = 0
        questionLabel.text = quizStep.question
    }
    
    func show(result: QuizResultsViewModel) {
        let alertModel = AlertModel(title: result.title, message: result.scoreText, buttonText: result.buttonText) { [weak self] in
            guard let self else { return }
            
            self.presenter.resetCurrentGame(needDataLoading: false)
        }
        
        alertPresenter.show(at: self, alertModel: alertModel)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        posterImageView.layer.borderWidth = 8
        posterImageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    func setAnswerButtonsUsable(state: Bool) {
        noButton.isUserInteractionEnabled = state
        yesButton.isUserInteractionEnabled = state
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать еще раз") { [weak self] in
            guard let self else { return }
            
            showLoadingIndicator()
            self.presenter.resetCurrentGame(needDataLoading: true)
        }
        
        alertPresenter.show(at: self, alertModel: alertModel)
    }
}
