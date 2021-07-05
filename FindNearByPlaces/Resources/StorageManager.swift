//
//  StorageManager.swift
//  FindNearByPlaces
//
//  Created by Shivi Agarwal on 05/07/21.
//

import Foundation

import FirebaseStorage

///Allows you to get, fetch and upload files to firebase storage
final class StorageManager
{
    static let shared = StorageManager()//singleton
    
    //forces everyone to use this shared property above and not create their own
    private init(){}
    
    private let storage = Storage.storage().reference()
    
    /* /images/shivi-agarwal-gmail-com_profile_picture.png
     */
    
    typealias uploadPictureHandler = (Result<String, Error>)-> Void
    
    ///uploads profile picture that user selected to firebase storage and on completion return the downlaod url so that it can be cached in the app
    public func uploadProfilePicture(data: Data, fileName: String, completion: @escaping uploadPictureHandler)
    {
        storage.child("images/\(fileName)").putData(data, metadata: nil) { [weak self] metadata, error in
            guard error == nil else
            {
                print("failed to upload data of image to firebase storage ")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self?.storage.child("images/\(fileName)").downloadURL { url, error in
                guard let url = url, error == nil else
                {
                    print("image uploaded to firebase storage but failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("Download url returned \(urlString)")
                completion(.success(urlString))
            }
        }
    }
    
    public func downloadUrl(path: String, completion: @escaping (Result<URL, Error>)-> Void)
    {
        let reference = storage.child(path)
        
        reference.downloadURL { url, error in
            guard let url = url, error == nil else
            {
                debugPrint(error)
               
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            
            completion(.success(url))
        }
    }
    
    public enum StorageErrors: Error
    {
        case failedToUpload
        case failedToGetDownloadUrl
    }
}

