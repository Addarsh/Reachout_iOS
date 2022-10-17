//
//  FeedbackVC.swift
//  reachout_ios
//
//  Created by Addarsh Chandrasekar on 10/16/22.
//

import UIKit

class FeedbackVC: UIViewController {
    
    @IBOutlet weak var loadingView: UIView! {
        didSet {
            loadingView.layer.cornerRadius = 6
            loadingView.isHidden = true
        }
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var messageView: UITextView!
    
    @IBOutlet weak var submitButton: UITextView!
    
    let messageViewPlaceholder = "Please provide feedback so we can make the app better! :)"
    
    private let feedbackServiceQueue = DispatchQueue(label: "Feedback service queue", qos: .default, attributes: [], autoreleaseFrequency: .inherit, target: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        messageView.backgroundColor = UIColor.white
        messageView.layer.borderWidth = 1
        messageView.layer.cornerRadius = 5
        messageView.layer.borderColor = UIColor.black.cgColor
        messageView.text = messageViewPlaceholder
        messageView.textColor = UIColor.lightGray
        messageView.delegate = self
        
        submitButton.layer.cornerRadius = 10
    }

    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func submit(_ sender: Any) {
        if messageView.text.isEmpty {
            return
        }
        
        let description = messageView.text.description
        
        // Fetch token.
        guard let token = KeychainHelper.read(service: KeychainHelper.TOKEN, account: KeychainHelper.REACHOUT) else {
            print("Could not read token from keychain")
            // TODO: Ask user to login again.
            return
        }
        
        showSpinner()
        
        // Submit post.
        FeedbackService.createFeedback(description: description, token: token, resultQueue: feedbackServiceQueue) { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.hideSpinner()
                    self.dismiss(animated: true)
                }
            case .failure(let error):
                // TODO: Show error toast here.
                print("Create Post failed with error: \(error.localizedDescription)")
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

extension FeedbackVC: UITextViewDelegate {
    
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
