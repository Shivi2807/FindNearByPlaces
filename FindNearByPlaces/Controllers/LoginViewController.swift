//
//  LoginViewController.swift
//  FindNearByPlaces
//
//  Created by Shivi Agarwal on 05/07/21.
//

import UIKit
import JGProgressHUD
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView =
        {
            let scrollView = UIScrollView()
            scrollView.clipsToBounds = true
            return scrollView
            
        }()
    
    private let imageView: UIImageView =
        {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "location")
            imageView.contentMode = .scaleAspectFit
            return imageView
            
        }()
    
    private let emailField : UITextField =
        {
            let field = UITextField()
            field.autocapitalizationType = .none
            field.autocorrectionType = .no
            field.returnKeyType = .continue
            field.layer.cornerRadius = 12
            field.layer.borderWidth = 1
            field.layer.borderColor = UIColor.lightGray.cgColor
            field.placeholder = "Email Address.."
            //field.leftView adds space from the left of textfield
            field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
            field.leftViewMode = .always
            field.backgroundColor = .secondarySystemBackground
            return field
            
        }()
    
    private let passwordField : UITextField =
        {
            let field = UITextField()
            field.autocapitalizationType = .none
            field.autocorrectionType = .no
            field.returnKeyType = .done
            field.layer.cornerRadius = 12
            field.layer.borderWidth = 1
            field.layer.borderColor = UIColor.lightGray.cgColor
            field.placeholder = "Password"
            field.isSecureTextEntry = true
            field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
            field.leftViewMode = .always
            field.backgroundColor = .secondarySystemBackground
            return field
            
        }()
    
    private let loginButton: UIButton =
        {
            let button = UIButton()
            button.setTitle("Log In", for: .normal)
            button.backgroundColor = .link
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 12
            //masksToBounds cuts off the text that over flows the layer corner
            button.layer.masksToBounds = true
            button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
            return button
            
        }()
    private let googleLoginButton: GIDSignInButton =
        {
            let button = GIDSignInButton()
            return button
        }()
    
    private var loginObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Log In"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        
        scrollView.addSubview(googleLoginButton)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()

        
        loginObserver = NotificationCenter.default.addObserver(forName: Notification.Name.didLoginNotification, object: nil, queue: .main) { [weak self] _ in
            self?.navigationController?.dismiss(animated: true, completion: nil)
        }

    }
    
    deinit {
        if let observer = loginObserver
        {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    @objc private func didTapRegister()
    {
        let vc = RegisterViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapLogin()
    {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        guard let email = emailField.text, let password = passwordField.text, !password.isEmpty, !email.isEmpty, password.count > 6 else
        {
            alertLoginUser()
            return
        }
        
        spinner.show(in: view)
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard let result = authResult, error == nil else
            {
                print("Error logging user")
                return
            }
            print(result)
            let user = result.user
            print(user)
            
            let safeEmail = DatabaseManager.safeEmail(email: email)
            DatabaseManager.shared.getDataFor(path: safeEmail) { result in
                switch result
                {
                case .success(let data):
                    guard let userData = data as? [String: Any],
                          let firstName = userData["first_name"] as? String,
                          let lastName = userData["last_name"] as? String else{
                        return
                    }
                 
                UserDefaults.standard.setValue("\(firstName) \(lastName)" , forKey: "name")
                    
                case .failure(let err):
                    print("failed to get first name and last name for user - \(err)")
                }
            }
            
            UserDefaults.standard.setValue(email , forKey: "email")
            
            print("user logged in successfully")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
    }
}
    
    private func alertLoginUser()
    {
        let alert = UIAlertController(title: "Oops", message: "Error in login. Please enter your info correctly", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        let size = scrollView.width/4
        
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 20,
                                 width: size,
                                 height: size)
       
        emailField.frame = CGRect(x: 30,
                                  y: imageView.bottom + 10,
                                  width: scrollView.width - 60,
                                  height: 52)
        
        
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom + 10,
                                     width: scrollView.width - 60,
                                     height: 52)
        
        loginButton.frame = CGRect(x: 30,
                                   y: passwordField.bottom + 10,
                                   width: scrollView.width - 60,
                                   height: 52)
        googleLoginButton.frame = CGRect(x: 30,
                                     y: loginButton.bottom + 10,
                                     width: scrollView.width - 60,
                                     height: 52)
        
    }
   
}

extension LoginViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField
        {
            passwordField.becomeFirstResponder()
        }
        
        if textField == passwordField
        {
            didTapLogin()
        }
        
        return true
    }
}
