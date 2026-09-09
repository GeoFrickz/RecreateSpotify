//
//  HomeViewController.swift
//  RecreateSpotify
//
//  Created by George Maximillian Theodore on 04/09/26.
//

import UIKit

class HomeViewController: UIViewController {
    
    private let viewModel = HomeViewModel()
    
    private let homeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = "Home"
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        
        return label
    }()
    
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .vertical
        stackView.spacing = 32
        
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        viewModel.fetchAllSections()
        
        viewModel.onSectionsUpdated = { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.renderData()
            }
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTrackSaved),
            name: .didUpdateSavedTracks,
            object: nil
        )
    }
    
    @objc private func handleTrackSaved() {
        viewModel.fetchAllSections()
    }
    
    private func setupView() {
        view.addSubview(homeLabel)
        view.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            homeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            homeLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            homeLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            mainStackView.topAnchor.constraint(equalTo: homeLabel.bottomAnchor, constant: 16),
            mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
    }
    
    private func renderData() {
        mainStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let section1 = HorizontalSectionView()
        section1.configure(title: viewModel.sections[0].title, items: viewModel.sections[0].albums)
        
        section1.onAlbumSelected = { [weak self] albumId in
            self?.didTapAlbumCard(albumId: albumId)
        }
        
        let section2 = HorizontalSectionView()
        section2.configure(title: viewModel.sections[1].title, items: viewModel.sections[1].albums)
        
        
        section2.onAlbumSelected = { [weak self] albumId in
            self?.didTapAlbumCard(albumId: albumId)
        }
        
        mainStackView.addArrangedSubview(section1)
        mainStackView.addArrangedSubview(section2)
    }
    
    private func didTapAlbumCard(albumId: String) {
        let albumVC = AlbumViewController(albumId: albumId)
        navigationController?.pushViewController(albumVC, animated: true)
    }
}
