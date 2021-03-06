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
    
    var responseResult : [MKMapItem]! = nil

    private let mapView = MKMapView()
    
    private let view1: UIView =
        {
            let view =  UIView()
            view.backgroundColor = .systemGray2
            return view
        }()
    
    private let tblView: UITableView =
        {
            let tbl = UITableView()
            tbl.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            return tbl
        }()
    
    private let mechanicsButton: UIButton =
        {
            let button = UIButton()
            //button.backgroundColor = .blue
            button.setTitle("MECHANICS", for: .normal)
            button.setTitleColor(.systemPink, for: .normal)
            button.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 10)
            //button.titleLabel?.minimumScaleFactor = 8.0
            //button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.addTarget(self, action: #selector(didTapMechanicsButton), for: .touchUpInside)
            return button
        }()
    
    private let petrolPumpButton: UIButton =
        {
            let button = UIButton()
            //button.backgroundColor = .blue
            button.setTitle("PETROL PUMPS", for: .normal)
            button.setTitleColor(.systemPink, for: .normal)
            button.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 10)
            //button.titleLabel?.minimumScaleFactor = 8.0
            //button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.addTarget(self, action: #selector(didTapPetrolPumpButton), for: .touchUpInside)
            return button
        }()
    
    private let chargingStationButton: UIButton =
        {
            let button = UIButton()
            //button.backgroundColor = .blue
            button.setTitle("CHARGING STATIONS", for: .normal)
            button.setTitleColor(.systemPink, for: .normal)
            button.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 10)
            //button.titleLabel?.minimumScaleFactor = 8.0
            //button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.addTarget(self, action: #selector(didTapChargingStaionsButton), for: .touchUpInside)
            return button
        }()
    
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
        view.addSubview(view1)
        view.addSubview(tblView)
        view1.addSubview(petrolPumpButton)
        view1.addSubview(chargingStationButton)
        view1.addSubview(mechanicsButton)
        fetchLocalData(category: "Petrol")
        tblView.delegate = self
        tblView.dataSource = self
        setConstraints()
        showLocation()
    }
    
    @objc func didTapBackButton()
    {
        dismiss(animated: true, completion: nil)
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
        
        //mapview.height = view.height * 0.3 + 0.0
        constraints += [NSLayoutConstraint.init(item: mapView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0.3, constant: 0.0)]
        
        view1.translatesAutoresizingMaskIntoConstraints = false
        
        //view.top = mapview.bottom
        
        constraints += [NSLayoutConstraint.init(item: view1, attribute: .top, relatedBy: .equal, toItem: mapView, attribute: .bottom, multiplier: 1.0, constant: 0.0)]
        
        //view1.leading = view.leading
        constraints += [NSLayoutConstraint.init(item: view1, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0)]
        
        //view1.trailing = view.trailing
        constraints += [NSLayoutConstraint.init(item: view1, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0)]
        
        //view1.height = view.height * 0.0
        constraints += [NSLayoutConstraint.init(item: view1, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40)]
        
        petrolPumpButton.translatesAutoresizingMaskIntoConstraints = false
        
        //petrolPumpButton.leading = view1.leading
        constraints += [NSLayoutConstraint.init(item: petrolPumpButton, attribute: .leading, relatedBy: .equal, toItem: view1, attribute: .leading, multiplier: 1.0, constant: 0.0)]
        
        //petrolPumpButton.height = view1.height
        
        constraints += [NSLayoutConstraint.init(item: petrolPumpButton, attribute: .height, relatedBy: .equal, toItem: view1, attribute: .height, multiplier: 1.0, constant: 0.0)]
        
        //petrolPumpButton.bottom = view1.bottom
        
        constraints += [NSLayoutConstraint.init(item: petrolPumpButton, attribute: .bottom, relatedBy: .equal, toItem: view1, attribute: .bottom, multiplier: 1.0, constant: 0.0)]
        
        //petrolPumpButton.width = view1.width * 0.3
        constraints += [NSLayoutConstraint.init(item: petrolPumpButton, attribute: .width, relatedBy: .equal, toItem: view1, attribute: .width, multiplier: 0.3, constant: 0.0)]
        
        chargingStationButton.translatesAutoresizingMaskIntoConstraints = false
        
        //chargingStationButton.leading = petrolPunpButton.trailing + 12
        constraints += [NSLayoutConstraint.init(item: chargingStationButton, attribute: .leading, relatedBy: .equal, toItem: petrolPumpButton, attribute: .trailing, multiplier: 1.0, constant: 12.0)]
        
        //chargingStationButton.height = view1.height
        
        constraints += [NSLayoutConstraint.init(item: chargingStationButton, attribute: .height, relatedBy: .equal, toItem: view1, attribute: .height, multiplier: 1.0, constant: 0.0)]
        
        //chargingStationButton.bottom = view1.bottom
        
        constraints += [NSLayoutConstraint.init(item: chargingStationButton, attribute: .bottom, relatedBy: .equal, toItem: view1, attribute: .bottom, multiplier: 1.0, constant: 0.0)]
        
        //chargingStationButton.width = view1.width * 0.35
        constraints += [NSLayoutConstraint.init(item: chargingStationButton, attribute: .width, relatedBy: .equal, toItem: view1, attribute: .width, multiplier: 0.35, constant: 0.0)]
        
        mechanicsButton.translatesAutoresizingMaskIntoConstraints = false
        
        //mechanicsButton.leading = chargingStationButton.trailing + 12
//        constraints += [NSLayoutConstraint.init(item: mechanicsButton, attribute: .leading, relatedBy: .equal, toItem: chargingStationButton, attribute: .trailing, multiplier: 1.0, constant: 12.0)]
        
        //mechanicsButton.height = view1.height
        
        constraints += [NSLayoutConstraint.init(item: mechanicsButton, attribute: .height, relatedBy: .equal, toItem: view1, attribute: .height, multiplier: 1.0, constant: 0.0)]
        
        //mechanicsButton.bottom = view1.bottom
        
        constraints += [NSLayoutConstraint.init(item: mechanicsButton, attribute: .bottom, relatedBy: .equal, toItem: view1, attribute: .bottom, multiplier: 1.0, constant: 0.0)]
        
        //mechanicsButton.width = view1.width * 0.3
        constraints += [NSLayoutConstraint.init(item: mechanicsButton, attribute: .width, relatedBy: .equal, toItem: view1, attribute: .width, multiplier: 0.3, constant: 0.0)]
        
        constraints += [NSLayoutConstraint.init(item: mechanicsButton, attribute: .trailing, relatedBy: .equal, toItem: view1, attribute: .trailing, multiplier: 1.0, constant: 0.0)]
        
        
        
        tblView.translatesAutoresizingMaskIntoConstraints = false
        
        //tblview.leading = view.leading
        constraints += [NSLayoutConstraint.init(item: tblView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0)]
        
        //tblview.trailing = view.trailing
        constraints += [NSLayoutConstraint.init(item: tblView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0)]
        
        //tblview.top = view1.bottom
        
        constraints += [NSLayoutConstraint.init(item: tblView, attribute: .top, relatedBy: .equal, toItem: view1, attribute: .bottom, multiplier: 1.0, constant: 0.0)]
        
        //tblview.bottom = view.bottom
        
        constraints += [NSLayoutConstraint.init(item: tblView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0)]

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
    
    
    @objc func didTapMechanicsButton()
    {
        fetchLocalData(category: "Mechanic")
    }
    
    @objc func didTapPetrolPumpButton()
    {
        fetchLocalData(category: "Petrol")
    }
    
    @objc func didTapChargingStaionsButton()
    {
        fetchLocalData(category: "Charging")
    }
    
    func fetchLocalData(category: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = category
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let response = response else {
               
                print("There was an error searching for: \(String(describing: request.naturalLanguageQuery)) error: \(String(describing: error))")
                return
            }
            self?.responseResult = response.mapItems
            DispatchQueue.main.async {
                self?.tblView.reloadData()
            }
        }
        return
    }
   
}

extension SearchResultViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(responseResult != nil){
            return responseResult!.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        let eachResponse = responseResult[indexPath.row]
        var customAddress:String? = ""
        
        if((eachResponse.name) != nil){
            customAddress = customAddress! + eachResponse.name!
        }
        if(eachResponse.phoneNumber != nil){
            customAddress = customAddress! + "\n" + "\(eachResponse.phoneNumber!)"
        }
    
        if(eachResponse.url != nil){
            customAddress = customAddress! + "\n" + "\(eachResponse.url!)"
        }
        cell.textLabel?.text = customAddress
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
}
