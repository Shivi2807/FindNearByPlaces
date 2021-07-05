//
//  SearchResultViewController.swift
//  FindNearByPlaces
//
//  Created by Shivi Agarwal on 05/07/21.
//

import UIKit
import MapKit
import CoreLocation

class SearchResultViewController: UIViewController {

    private let mapView = MKMapView()
    
    private var coordinates: CLLocationCoordinate2D
    
    init(with coordinates: CLLocationCoordinate2D)
    {
        self.coordinates = coordinates
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(didTapBackButton))
        view.addSubview(mapView)
        //mapView.delegate = self
        setConstraints()
        showLocation()
        
    }
    
    @objc func didTapBackButton()
    {
        //dismiss(animated: true, completion: nil)
        //navigationController?.popToViewController(ViewController, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationItem.hidesBackButton = false
    }
    
    private func setConstraints()
    {
        var constraints = [NSLayoutConstraint]()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        //mapview.top = safearea.top
        constraints += [NSLayoutConstraint.init(item: mapView, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1.0, constant: 0.0)]
        
        //mapview.leading = view.leading
        constraints += [NSLayoutConstraint.init(item: mapView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0)]
        
        //mapview.trailing = view.trailing
        constraints += [NSLayoutConstraint.init(item: mapView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0)]
        
        //mapview.height = view.height * 0.0
        constraints += [NSLayoutConstraint.init(item: mapView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0.3, constant: 0.0)]
        
        view.addConstraints(constraints)
        
    }
    
    private func showLocation()
    {
        //remove existing pins
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
        
        //add a map pin
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        mapView.addAnnotation(pin)
        let region = MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
        mapView.setRegion(region, animated: true)
    }
   
}
