//
//  RegisterViewController.swift
//  FindNearByPlaces
//
//  Created by Shivi Agarwal on 05/07/21.
//

import UIKit
import Firebase
import JGProgressHUD

class RegisterViewController: UIViewController {
    
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
            imageView.image = UIImage(systemName: "person.circle")
            imageView.layer.borderWidth = 2
            imageView.layer.borderColor = UIColor.gray.cgColor
            imageView.layer.masksToBounds = true
            imageView.tintColor = .gray
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
    
    private let firstName : UITextField =
        {
            
            let field = UITextField()
            field.autocapitalizationType = .none
            field.autocorrectionType = .no
            field.returnKeyType = .continue
            field.layer.cornerRadius = 12
            field.layer.borderWidth = 1
            field.layer.borderColor = UIColor.lightGray.cgColor
            field.placeholder = "First name.."
            //field.leftView adds space from the left of textfield
            field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
            field.leftViewMode = .always
            field.backgroundColor = .secondarySystemBackground
            return field
            
        }()
    
    private let lastName : UITextField =
        {
            
            let field = UITextField()
            field.autocapitalizationType = .none
            field.autocorrectionType = .no
            field.returnKeyType = .continue
            field.layer.cornerRadius = 12
            field.layer.borderWidth = 1
            field.layer.borderColor = UIColor.lightGray.cgColor
            field.placeholder = "Last name.."
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
    
    private let registerButton: UIButton =
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Create an account"
        
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(firstName)
        scrollView.addSubview(lastName)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerButton)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        scrollView.isUserInteractionEnabled = true
        imageView.isUserInteractionEnabled  = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic))
        gesture.numberOfTouchesRequired = 1
        gesture.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(gesture)

    }
    
    @objc private func didTapChangeProfilePic()
    {
        presentPhotoActionSheet()
    }
    
    private func presentPhotoActionSheet()
    {
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How do you want to choose a photo for your profile pic", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoLibrary()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    private func presentCamera()
    {
        let vc = UIImagePickerController()
        vc.allowsEditing = true
        vc.sourceType = .camera
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    private func presentPhotoLibrary()
    {
        let vc = UIImagePickerController()
        vc.allowsEditing = true
        vc.sourceType = .photoLibrary
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 20,
                                 width: size,
                                 height: size)
        imageView.layer.cornerRadius = imageView.width / 2
        
        firstName.frame = CGRect(x: 30,
                                  y: imageView.bottom + 10,
                                  width: scrollView.width - 60,
                                  height: 52)
        
        lastName.frame = CGRect(x: 30,
                                  y: firstName.bottom + 10,
                                  width: scrollView.width - 60,
                                  height: 52)
      
        emailField.frame = CGRect(x: 30,
                                  y: lastName.bottom + 10,
                                  width: scrollView.width - 60,
                                  height: 52)
        
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom + 10,
                                     width: scrollView.width - 60,
                                     height: 52)
        
        registerButton.frame = CGRect(x: 30,
                                   y: passwordField.bottom + 10,
                                   width: scrollView.width - 60,
                                   height: 52)
}
    
    @objc private func didTapRegister()
    {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        firstName.resignFirstResponder()
        lastName.resignFirstResponder()
        guard let email = emailField.text, let password = passwordField.text, let fname = firstName.text, let lname = lastName.text, !password.isEmpty, !email.isEmpty, password.count > 6 else
        {
            alertLoginUser()
            return
        }
        
        DatabaseManager.shared.userExists(with: email) { [weak self] exists in
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard !exists else
            {
                strongSelf.alertLoginUser(message: "User already exists. Please sign up with another email")
                return
            }
            
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
                
              guard let result = authResult, error == nil else
              {
                print("Error creating user")
                return
              }
                UserDefaults.standard.setValue(email, forKey: "email")
                UserDefaults.standard.setValue("\(fname) \(lname)", forKey: "name")
                
                let appUser = AppUser(firstName: fname, lastName: lname, email: email)
                DatabaseManager.shared.insertUser(with: appUser) { success in
                    if success
                    {
                        //upload image
                       guard let image = strongSelf.imageView.image, let imageData = image.pngData() else
                       {
                           return
                       }
                       
                       let fileName = appUser.profilePictureFileName
                       StorageManager.shared.uploadProfilePicture(data: imageData, fileName: fileName) { result in
                           switch result
                           {
                           case .success(let downlaodUrl):
                               UserDefaults.standard.setValue(downlaodUrl, forKey: "profile_picture_url ")
                               print("Got the download url - \(downlaodUrl)")
                           case .failure(let err):
                               print("Strorage maanger error - \(err.localizedDescription)")
                           }
                        print("User inserted successfully")
                    }
                }
            }
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    }
    
    private func alertLoginUser(message: String = "Error in login. Please enter your info correctly")
    {
        let alert = UIAlertController(title: "Oops", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
   
}

extension RegisterViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField
        {
            passwordField.becomeFirstResponder()
        }
        
        if textField == passwordField
        {
            didTapRegister()
        }
        
        return true
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else
        {
            return
        }
        
        imageView.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
