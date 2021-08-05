//
//  UIViewExtension.swift
//  AllVehicleModelsAPI
//
//  Created by lijia xu on 8/4/21.
//

import UIKit

extension UIViewController {
    
    func presentAlert(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let dismissAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
}
