//
//  DatabaseManager.swift
//  FindNearByPlaces
//
//  Created by Shivi Agarwal on 05/07/21.
//

import Foundation
import FirebaseDatabase

///Manager object to read and write data to firebase real-time database
final class DatabaseManager
{
    ///shared instance of class
    static let shared = DatabaseManager()
    
    //forces everyone to use this shared property above and not create their own
    private init(){}
    
    ///reference to database
    private let database = Database.database().reference()
    
    static func safeEmail(email: String)-> String
    {
        var safeEmail = email.replacingOccurrences(of: "@", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: ".", with: "-")
        return safeEmail
    }
    
    public enum DatabaseErrors: Error
    {
        case failedToFetch
    }
    
}

extension DatabaseManager
{
    ///returns dictionary node at child path
    public func getDataFor(path: String, completion: @escaping (Result<Any, Error>)-> Void)
    {
        database.child(path).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else
            {
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }
}

//MARK:- Account Management
extension DatabaseManager
{
    ///checks if user exists for given email
    ///Parameters
    ///`email`:       Target emial to be checked
    ///`completion` : async closure to return with result
    public func userExists(with email: String, completion: @escaping (Bool)-> Void)
    {
        let safeEmail = DatabaseManager.safeEmail(email: email)
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            guard let foundEmail = snapshot.value as? [String: Any] else
            {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    ///insert user in database
    public func insertUser(with user: AppUser, completion: @escaping (Bool)-> Void)
    {
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName]) { [weak self] error, _ in
            guard error == nil else
            {
                completion(false)
                return
            }
            completion(true)
            
            print("Successfully inserted user ")
            
        }
        
    }
}


struct AppUser {
    let firstName: String
    let lastName: String
    let email: String
    
    var safeEmail: String
    {
        var safeEmail = email.replacingOccurrences(of: "@", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: ".", with: "-")
        return safeEmail
    }
    
    var profilePictureFileName: String
    {
        /// /images/shivi-agarwal-gmail-com_profile_picture.png

        return "\(safeEmail)_profile_picture.png"
    }
}
