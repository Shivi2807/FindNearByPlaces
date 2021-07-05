//
//  ProfileViewController.swift
//  FindNearByPlaces
//
//  Created by Shivi Agarwal on 05/07/21.
//

import UIKit

import Firebase
import GoogleSignIn
import SDWebImage

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var data = [ProfileViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        data.append(ProfileViewModel(viewModelType: .info, title: "Name: \(UserDefaults.standard.value(forKey: "name") ?? "No Name")", handler: nil))
        data.append(ProfileViewModel(viewModelType: .info, title: "Email: \(UserDefaults.standard.value(forKey: "email") ?? "No Email")", handler: nil))
        data.append(ProfileViewModel(viewModelType: .logout, title: "Log Out", handler: {[weak self] in
            
            let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
                guard let strongSelf = self else { return}
                
                //set user defaults to nil to remove the cache
                UserDefaults.standard.setValue(nil, forKey: "email")
                UserDefaults.standard.setValue(nil, forKey: "name")
                
                //log out of google
                GIDSignIn.sharedInstance().signOut()
                do
                {
                    try FirebaseAuth.Auth.auth().signOut()
                    
                    let vc = LoginViewController()
                    let nav = UINavigationController(rootViewController: vc)
                    nav.modalPresentationStyle = .fullScreen
                    strongSelf.present(nav, animated: true)
                }
                catch
                {
                   print("Failed to log out")
                }
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self?.present(actionSheet, animated: true)
            
            
        }))
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.identifier)
        tableView.tableHeaderView = createTableViewHeader()
    }
    
    func createTableViewHeader()-> UIView?
    {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else
        {
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(email: email)
        let fileName = safeEmail + "_profile_picture.png"
        let path = "images/"+fileName
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 300))
        headerView.backgroundColor = .link
        
        let imageView = UIImageView(frame: CGRect(x: (headerView.width - 150)/2, y: 75, width: 150, height: 150))
       
        imageView.contentMode = .scaleToFill
        imageView.backgroundColor = .white
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.width/2
        headerView.addSubview(imageView)
        
        StorageManager.shared.downloadUrl(path: path) { [weak self] result in
            guard let stronSelf = self else { return }
            switch result
            {
            case .success(let url):
                stronSelf.downloadImage(imageView: imageView, url: url)
            case .failure(let err):
                print("Failed to get download url for profile picture tab in application- \(err)")
            }
        }
        
        return headerView
    }
    
    func downloadImage(imageView: UIImageView, url: URL)
    {
        imageView.sd_setImage(with: url, completed: nil)
//        URLSession.shared.dataTask(with: url) { data, _, error in
//            guard let data = data, error == nil else
//            {
//                return
//            }
//
//            DispatchQueue.main.async {
//                let image = UIImage(data: data)
//                imageView.image = image
//            }
//        }.resume()
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let viewModel = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier, for: indexPath) as! ProfileTableViewCell
        cell.setUp(with: viewModel)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        data[indexPath.row].handler?()
    }
}

class ProfileTableViewCell: UITableViewCell
{
    static let identifier = "ProfileTableViewCell"
    
    public func setUp(with viewModel: ProfileViewModel)
    {
        textLabel?.text = viewModel.title
        switch viewModel.viewModelType {
        case .info:
            textLabel?.textAlignment = .left
            selectionStyle = .none
        case .logout:
            textLabel?.textColor = .red
            textLabel?.textAlignment = .center
        
        }
    }
}
