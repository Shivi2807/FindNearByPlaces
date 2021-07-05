//
//  AppDelegate.swift
//  FindNearByPlaces
//
//  Created by Shivi Agarwal on 05/07/21.
//

import UIKit
import Firebase
import GoogleSignIn
import GooglePlaces

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        GMSPlacesClient.provideAPIKey("AIzaSyACrdCYS9RCeorp0pm79giENme6FquXhHg")
        
        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
      -> Bool {
      return GIDSignIn.sharedInstance().handle(url)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

extension AppDelegate: GIDSignInDelegate
{
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        guard error == nil else
        {
            print("Failed to sign in with google")
            return
        }
        
        print("Did sign in with google \(user)")
        
        guard let email = user.profile.email,
              let fName = user.profile.givenName,
              let lName = user.profile.familyName else
        {
            return
        }
        
        DatabaseManager.shared.userExists(with: email) { exists in
            if !exists
            {
                //insert user to db
                let appUser = AppUser(firstName: fName, lastName: lName, email: email)
                DatabaseManager.shared.insertUser(with: appUser) { success in
                    if success
                    {
                        //upload image
                        //check if user has image
                        if user.profile.hasImage
                        {
                            guard let imageUrl = user.profile.imageURL(withDimension: 200) else
                            {
                                return
                            }
                            
                            //downlaod data from image url
                            URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                                guard error == nil else
                                {
                                    print("failed to get data from picture url")
                                    return
                                }
                                print("downlaoding data from picture url")
                                let response = response as! HTTPURLResponse
                                if response.statusCode == 200
                                {
                                    guard let imageData = data else
                                    {
                                        return
                                    }
                                    print("got data from picture url of facebook, uploading.....")
                                    
                                    //upload image
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
                                    }
                                }
                            }.resume()
                        }
                    }
                    
                    guard let authentication = user.authentication else {
                        print("Missing auth object off of google user")
                        return
                        
                    }
                    let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
                    
                    FirebaseAuth.Auth.auth().signIn(with: credential) { authResult, error in
                        guard authResult != nil, error == nil else
                        {
                            print("Failed to sign in with google credential")
                            return
                        }
                        
                        UserDefaults.standard.setValue("\(fName) \(lName)" , forKey: "name")
                        UserDefaults.standard.setValue(email , forKey: "email")

                        print("Successfully signed in with google")
                        NotificationCenter.default.post(name: .didLoginNotification, object: nil)
                    }
            }
        }
            
        }
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("Google user was disconnected")
    }
}

