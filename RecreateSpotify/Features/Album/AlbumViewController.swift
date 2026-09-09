//
//  AlbumViewController.swift
//  RecreateSpotify
//
//  Created by George Maximillian Theodore on 04/09/26.
//

import UIKit

class AlbumViewController: UIViewController {
    
    private let albumId: String
    private let viewModel = AlbumViewModel()
    private let trackListViewController = TrackListViewController()
    
    init(albumId: String) {
        self.albumId = albumId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let artworkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        viewModel.onStateChange = { [weak self] state in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.trackListViewController.updateState(for: state)
                
                if case .populated = state {
                    self.trackListViewController.update(with: self.viewModel.tracks)
                    self.titleLabel.text = self.viewModel.albumName
                    self.artworkImageView.load(from: self.viewModel.albumArtworkUrl)
                }
            }
        }
        
        viewModel.getAlbumDetail(albumId: albumId)
    }
    
    private func setupView() {
        view.addSubview(artworkImageView)
        view.addSubview(titleLabel)
        addChild(trackListViewController)
        view.addSubview(trackListViewController.view)
        
        trackListViewController.viewModel = self.viewModel
        trackListViewController.showArtwork = false
        trackListViewController.view.translatesAutoresizingMaskIntoConstraints = false
        trackListViewController.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            artworkImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            artworkImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            artworkImageView.heightAnchor.constraint(equalToConstant: 240),
            artworkImageView.widthAnchor.constraint(equalTo: artworkImageView.heightAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: artworkImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            trackListViewController.view.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            trackListViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            trackListViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackListViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}
