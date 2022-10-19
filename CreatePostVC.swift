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
    
    let messageViewPlaceholder = "Describe your problem here so others can reach out and chat with you :)"
    let messageTitlePlaceHolder = "Title of your message"
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let postsServiceQueue = DispatchQueue(label: "Posts service queue", qos: .default, attributes: [], autoreleaseFrequency: .inherit, target: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        messageTitle.layer.borderWidth = 1
        messageTitle.layer.cornerRadius = 5
        messageTitle.layer.borderColor = UIColor.black.cgColor
        messageTitle.attributedPlaceholder = NSAttributedString(
            string: messageTitlePlaceHolder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        messageTitle.delegate = self
        
        
        messageView.backgroundColor = UIColor.white
        messageView.layer.borderWidth = 1
        messageView.layer.cornerRadius = 5
        messageView.layer.borderColor = UIColor.black.cgColor
        messageView.text = messageViewPlaceholder
        messageView.textColor = UIColor.lightGray
        messageView.delegate = self
        
        submitButton.layer.cornerRadius = 10

        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func didSubmit(_ sender: Any) {
        if messageTitle.text!.isEmpty || messageView.text == messageViewPlaceholder || messageView.text.isEmpty {
            // Title or description cannot be empty
            self.present(Utils.createOkAlert(title: "Error", message: "Title or message cannot be empty"), animated: true)
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
        PostsService.createPost(title: title, description: description, token: token, resultQueue: postsServiceQueue) { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.hideSpinner()
                    self.dismiss(animated: true)
                }
            case .failure(let error):
                print("Create Post failed with error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.present(Utils.createOkAlert(title: "Error", message: "Failed to create post"), animated: true)
                }
            }
        }
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

extension CreatePostVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = messageViewPlaceholder
            textView.textColor = UIColor.lightGray
        }
    }
}
