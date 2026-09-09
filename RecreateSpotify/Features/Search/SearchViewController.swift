//
//  SearchViewController.swift
//  RecreateSpotify
//
//  Created by George Maximillian Theodore on 02/09/26.
//

import UIKit

class SearchViewController: UIViewController {
    
    private let viewModel = SearchViewModel()
    private let trackListViewController = TrackListViewController()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        searchBar.placeholder = "Songs, artists, albums"
        searchBar.backgroundImage = UIImage()
        
        return searchBar
    }()
    
    private let searchLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = "Search"
        label.textColor = .primaryText
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        
        return label
    }()
    
    private let searchBarStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .leading
        
        
        return stack
    }()
    
    private let searchResultsStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .leading
        
        
        return stack
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        searchBar.delegate = self
        
        viewModel.onStateChange = { [weak self] state in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.trackListViewController.updateState(for: state)
            }
        }
    }
    
    
    private func setupView() {
        
        addChild(trackListViewController)
        trackListViewController.viewModel = self.viewModel
        
        searchBarStackView.addArrangedSubview(searchLabel)
        searchBarStackView.addArrangedSubview(searchBar)
        
        view.addSubview(searchBarStackView)
        view.addSubview(trackListViewController.view)
        trackListViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            searchBarStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBarStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchBarStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            searchBar.leadingAnchor.constraint(equalTo: searchBarStackView.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: searchBarStackView.trailingAnchor),
            
            trackListViewController.view.topAnchor.constraint(equalTo: searchBarStackView.bottomAnchor, constant: 16),
            trackListViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
            trackListViewController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackListViewController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
        ])
        
        trackListViewController.didMove(toParent: self)
    }
}


extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchWithDebounce(query: searchText) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.trackListViewController.update(with: self.viewModel.tracks)
            case .failure(let error):
                print("Search failed: \(error.localizedDescription)")
            }
        }
    }
}
