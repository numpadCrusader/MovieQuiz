//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Nikita Khon on 29.12.2024.
//

import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    var stringRepresentation: String {
       "\(correct)/\(total) (\(date.dateTimeString))"
    }
    
    func isBetterThan(_ another: GameResult) -> Bool {
        correct > another.correct
    }
}
