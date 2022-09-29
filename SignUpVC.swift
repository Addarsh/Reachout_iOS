//
//  SignUpVC.swift
//  reachout_ios
//
//  Created by Addarsh Chandrasekar on 9/28/22.
//

import UIKit

class SignUpVC: UIViewController, UITextFieldDelegate  {

    @IBOutlet weak var emailTextField: UITextField! {
        didSet {
            let grayPlaceholderText = NSAttributedString(string: "Email",
                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
            
            emailTextField.attributedPlaceholder = grayPlaceholderText
        }
    }
    
    
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            let grayPlaceholderText = NSAttributedString(string: "Password",
                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
            
            passwordTextField.attributedPlaceholder = grayPlaceholderText
        }
    }
    
    private let authServiceQueue = DispatchQueue(label: "Auth service queue", qos: .default, attributes: [], autoreleaseFrequency: .inherit, target: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = UIColor.gray.cgColor
        emailTextField.layer.cornerRadius = 5
        emailTextField.delegate = self
        
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = UIColor.gray.cgColor
        passwordTextField.layer.cornerRadius = 5
        passwordTextField.delegate = self
        
        self.hideKeyboardWhenTappedAround()
    }

    @IBAction func signUp(_ sender: Any) {
        // Sign Up.
        AuthService.loginOrSignUp(requestType: .SignUp, email: self.emailTextField.text!, password: self.passwordTextField.text!, resultQueue: authServiceQueue) { result in
            switch result {
            case .success(let response):
                print("sign up response: \(response)")
            case .failure(let error):
                print("User Sign Up failed with error: \(error.localizedDescription)")
            }
        }
    }
    @IBAction func loginInstead(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}

extension SignUpVC {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginVC.dismissKeyboard))
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
