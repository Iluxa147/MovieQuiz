//
//  File.swift
//  MovieQuiz
//
//  Created by Ilya Pokolev on 15.02.2026.
//

import UIKit

final class AlertPresenter {
    func show(at viewController: UIViewController, alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
            alertModel.completionAction()
        }
        
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
}
