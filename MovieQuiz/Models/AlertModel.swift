//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Ilya Pokolev on 15.02.2026.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completionAction: () -> Void
}
