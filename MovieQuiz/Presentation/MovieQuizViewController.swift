import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Public Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Private Properties
    
    private var presenter: MovieQuizPresenter!
    private lazy var alertPresenter = AlertPresenter(viewController: self)
    
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    // MARK: - IB Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    // MARK: - Public Methods
    
    // приватный метод вывода на экран вопроса
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.image = step.image
    }
    
    // приватный метод для показа результатов раунда квиза
    func show(quiz result: QuizResultsViewModel) {
        let alertMessage = presenter.makeResultsMessage(from: result.text)
        
        alertPresenter.showAlert(with: AlertModel(
            title: result.title,
            message: alertMessage,
            buttonText: result.buttonText,
            completion: { [weak self] in
                self?.presenter.restartGame()
            }
        ))
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypAssetGreen.cgColor : UIColor.ypAssetRed.cgColor
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
    }
    
    func setButtonsEnabled(isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        alertPresenter.showAlert(with: AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз",
            completion: { [weak self] in
                self?.presenter.restartGame()
                self?.presenter.loadQuestionsData()
            }
        ))
    }
}
