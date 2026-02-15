//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Ilya Pokolev on 15.02.2026.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
