//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Nikita Khon on 14.01.2025.
//

import UIKit

final class MovieQuizPresenter {
    
    // MARK: - Public Properties
    
    let questionsAmount: Int = 10
    
    // MARK: - Private Properties
    
    private var currentQuestionIndex = 0
    
    // MARK: - Public Methods
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    /// метод конвертации, который принимает вопрос и возвращает вью модель для экрана вопроса
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.imageData) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
}
