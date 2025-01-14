//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Nikita Khon on 14.01.2025.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // MARK: - Private Properties
    
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var currentQuestionIndex = 0
    private var currentQuestion: QuizQuestion?
    
    private let statisticService: StatisticServiceProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    // MARK: - Initializers
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticService()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        loadQuestionsData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate
        
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Public Methods
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if (isCorrectAnswer) { correctAnswers += 1 }
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func makeResultsMessage(from initialMessage: String) -> String {
        guard let statisticService = statisticService else { return initialMessage }
        
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let alertMessage = """
        \(initialMessage)
        Количество сыгранных квизов: \(statisticService.gamesCount)
        Рекорд: \(statisticService.bestGame.stringRepresentation)
        Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
        """
        
        return alertMessage
    }
    
    // метод конвертации, который принимает вопрос и возвращает вью модель для экрана вопроса
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.imageData) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    func loadQuestionsData() {
        questionFactory?.loadData()
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    // MARK: - Private Methods
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let userAnswer = isYes
        proceedWithAnswer(isCorrect: userAnswer == currentQuestion.correctAnswer)
    }
    
    // приватный метод, который содержит логику перехода в один из сценариев
    private func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            let quizResultViewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(correctAnswers)/10",
                buttonText: "Сыграть ещё раз")
            
            viewController?.show(quiz: quizResultViewModel)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        viewController?.setButtonsEnabled(isEnabled: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
            self.viewController?.setButtonsEnabled(isEnabled: true)
        }
    }
}
