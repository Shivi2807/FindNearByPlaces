//
//  ViewController.swift
//  FindNearByPlaces
//
//  Created by Shivi Agarwal on 05/07/21.
//

import UIKit
import MapKit
import Firebase

class MainViewController: UIViewController {
    
    let searchVC = UISearchController(searchResultsController: SearchPlacesViewController())
    let mapView = MKMapView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)
        navigationItem.searchController = searchVC
        searchVC.searchBar.backgroundColor = .secondarySystemBackground
        searchVC.searchResultsUpdater = self
        validateAuth()
    }
    
    private func validateAuth()
    {
        if FirebaseAuth.Auth.auth().currentUser == nil
        {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.size.width, height: view.frame.size.height - view.safeAreaInsets.top)
    }
}

extension MainViewController: UISearchResultsUpdating
{
    func updateSearchResults(for searchController: UISearchController) {
        //
    }
    
    
}

