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
    
    @IBAction func didSubmit(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PostsVC")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
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
