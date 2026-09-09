//
//  TrackListViewController.swift
//  RecreateSpotify
//
//  Created by George Maximillian Theodore on 03/09/26.
//

import UIKit

class TrackListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var viewModel: TrackListViewModelProtocol?
    private var tracks: [Track] = []
    
    var showArtwork: Bool = true
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.register(TrackTableViewCell.self, forCellReuseIdentifier: TrackTableViewCell.identifier)
        
        tableView.separatorStyle = .none
        
        return tableView
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .center
        label.textColor = .secondaryText
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        updateState(for: .idle)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSavedTracksChanged),
            name: .didUpdateSavedTracks,
            object: nil
        )
    }
    
    @objc private func handleSavedTracksChanged() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    private func setupView() {
        view.backgroundColor = .background
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
     func updateState(for state: ListState) {
        switch state {
        case .idle:
            messageLabel.text = "Search for your favorite songs or artists"
            tableView.backgroundView = messageLabel
            messageLabel.textColor = .secondaryText
            
        case .loading:
            messageLabel.text = "Loading..."
            tableView.backgroundView = messageLabel
            messageLabel.textColor = .secondaryText
            
        case .populated:
            tableView.backgroundView = nil
            messageLabel.textColor = .secondaryText
            tableView.reloadData()
            
        case .empty:
            messageLabel.text = "No results found."
            messageLabel.textColor = .secondaryText
            tableView.backgroundView = messageLabel
            tableView.reloadData()
            
        case .error(let message):
            messageLabel.text = "Failed to load: \(message)"
            messageLabel.textColor = .systemRed
            tableView.backgroundView = messageLabel
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackTableViewCell.identifier, for: indexPath) as? TrackTableViewCell else {
            return UITableViewCell()
        }
        
        let track = tracks[indexPath.row]
        
        let isSaved = CoreDataManager.shared.isSavedTrack(id: track.id)
        cell.configure(with: track, showArtwork: showArtwork, accessory: .addButton, isSaved: isSaved)
        
        cell.onAddButtonTapped = { [weak self, weak cell] in
            guard let self = self else { return }
            
            self.didTapAddButton(forTrackAtIndex: indexPath.row)
            
            let nowSaved = CoreDataManager.shared.isSavedTrack(id: track.id)
            cell?.setSavedState(nowSaved)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }
        
        if indexPath.row == tracks.count - 1 {
            viewModel.fetchNextPage { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success:
                    self.tracks = viewModel.tracks
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                case .failure(let error):
                    print("Pagination error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func update(with tracks: [Track]) {
        self.tracks = tracks
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func didTapAddButton(forTrackAtIndex index: Int) {
        viewModel?.saveTrack(at: index)
    }
}
