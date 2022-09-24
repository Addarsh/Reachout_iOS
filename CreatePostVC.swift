//
//  CreatePostVC.swift
//  reachout_ios
//
//  Created by Addarsh Chandrasekar on 9/23/22.
//

import UIKit

class CreatePostVC: UIViewController {

    @IBOutlet weak var messageView: UITextView!
    
    @IBOutlet weak var messageTitle: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        messageView.backgroundColor = UIColor.white
        messageView.layer.borderWidth = 1
        messageView.layer.borderColor = UIColor.black.cgColor
        
        messageTitle.layer.borderWidth = 1
        messageTitle.layer.borderColor = UIColor.black.cgColor

        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Pass any data back to PostsVC if required.
        // Created post data may not be needed because it will be retrieved
        // by PostsVC from the server anyways.
    }
    
    @IBAction func didSubmit(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

// Put this piece of code anywhere you like
extension CreatePostVC {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(CreatePostVC.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
