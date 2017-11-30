//
//  UIViewController.swift
//  netguru
//
//  Created by Piotr Sochalewski on 27.11.2017.
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func presentAddAlert(title: String, placeholder: String, handler: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = placeholder
            textField.autocapitalizationType = .sentences
            textField.addTarget(self, action: #selector(UIViewController.textChanged(_:)), for: .editingChanged)
        }
        
        let createAction = UIAlertAction(title: "Add", style: .default) { _ in
            guard let text = alert.textFields?.first?.text else { return }
            handler(text)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        [createAction, cancelAction].forEach { alert.addAction($0) }
        alert.actions.first?.isEnabled = false
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func textChanged(_ sender: UITextField) {
        var responder = sender as UIResponder
        while !(responder is UIAlertController) {
            responder = responder.next!
        }
        let alert = responder as! UIAlertController
        alert.actions.first?.isEnabled = (sender.text != "")
    }
}
