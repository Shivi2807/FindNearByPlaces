//
//  SearchPlacesViewController.swift
//  FindNearByPlaces
//
//  Created by Shivi Agarwal on 05/07/21.
//

import UIKit

class SearchPlacesViewController: UIViewController {

    private let tblView: UITableView =
        {
            let tbleView = UITableView()
            tbleView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            return tbleView
        }()
    
    private var places : [Place] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tblView)
        tblView.delegate = self
        tblView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tblView.frame = view.bounds
        
    }
    
    public func update(with places: [Place])
    {
        tblView.isHidden = false
        self.places = places
        print(places.count)
        tblView.reloadData()
    }
    
}
   
extension SearchPlacesViewController: UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = places[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tblView.deselectRow(at: indexPath, animated: true)
        
        tableView.isHidden = true
        
        let place = places[indexPath.row]
        GooglePlacesManager.shared.resolveLocation(for: place) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result
            {
            case .success(let coordinate):
                let vc = SearchResultViewController(with: coordinate)
                vc.title = "Searched Location"
                    let navVC = UINavigationController(rootViewController: vc)
                    navVC.modalPresentationStyle = .fullScreen
                strongSelf.present(navVC, animated: true, completion: nil)
                break
                
            case .failure(let error):
                print(error)
            }
        }
    }
}

