//
//  CreatePostVC.swift
//  reachout_ios
//
//  Created by Addarsh Chandrasekar on 9/23/22.
//

import UIKit

class CreatePostVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var messageView: UITextView!
    @IBOutlet weak var messageTitle: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var loadingView: UIView! {
        didSet {
            loadingView.layer.cornerRadius = 6
            loadingView.isHidden = true
        }
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        messageTitle.layer.borderWidth = 1
        messageTitle.layer.cornerRadius = 5
        messageTitle.layer.borderColor = UIColor.black.cgColor
        messageTitle.delegate = self
        
        
        messageView.backgroundColor = UIColor.white
        messageView.layer.borderWidth = 1
        messageView.layer.cornerRadius = 5
        messageView.layer.borderColor = UIColor.black.cgColor
        
        submitButton.layer.cornerRadius = 10

        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Pass any data back to PostsVC if required.
        // Created post data may not be needed because it will be retrieved
        // by PostsVC from the server anyways.
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func didSubmit(_ sender: Any) {
        if messageTitle.text!.isEmpty || messageView.text.isEmpty {
            // Title or description cannot be empty
            // TODO: Show error toast.
            return
        }
        let title = messageTitle.text!
        let description = messageView.text.description
        
        // Fetch token.
        guard let token = KeychainHelper.read(service: KeychainHelper.TOKEN, account: KeychainHelper.REACHOUT) else {
            print("Could not read token from keychain")
            // TODO: Ask user to login again.
            return
        }
        
        showSpinner()
        
        // Submit post.
        PostsService.createPost(title: title, description: description, token: token) { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.hideSpinner()
                    self.dismiss(animated: true)
                }
            case .failure(let error):
                print("Create Post failed with error: \(error.localizedDescription)")
            }
        }
    }
    
    private func validateInputs() {
        
    }
    
    // Show loading spinner.
    private func showSpinner() {
        activityIndicator.startAnimating()
        loadingView.isHidden = false
    }

    // Hide loading spinner.
    private func hideSpinner() {
        activityIndicator.stopAnimating()
        loadingView.isHidden = true
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
    
    // Hide keyboard when Enter key is pressed.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
