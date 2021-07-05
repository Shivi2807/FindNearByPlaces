//
//  ProfileViewModel.swift
//  FindNearByPlaces
//
//  Created by Shivi Agarwal on 05/07/21.
//


import Foundation

enum ProfileViewModelType {
    case info, logout
}

struct ProfileViewModel {
    let viewModelType: ProfileViewModelType
    let title: String
    let handler: (() ->Void)?
}
