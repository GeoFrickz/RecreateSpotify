//
//  TrackTableViewCell.swift
//  RecreateSpotify
//
//  Created by George Maximillian Theodore on 03/09/26.
//

import UIKit

enum TrackCellAccessory {
    case addButton
    case duration
    case none
}

class TrackTableViewCell: UITableViewCell {
    static let identifier = "SearchResultTableViewCell"
    
    var onAddButtonTapped: (() -> Void)?
    
    private let artworkImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        
        iv.layer.cornerRadius = 4
        iv.clipsToBounds = true
        
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        
        return label
    }()
    
    private let artistLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryText
        label.textAlignment = .right
        
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let image = UIImage(named: "plus.circle")
        button.setImage(image, for: .normal)
        button.tintColor = .accent
        
        return button
    }()
    
    private let textStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        
        sv.axis = .vertical
        sv.spacing = 2
        
        return sv
    }()
    
    private let subStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        
        sv.axis = .horizontal
        sv.distribution = .equalSpacing
        
        return sv
    }()
    
    private let mainStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        
        sv.axis = .horizontal
        sv.spacing = 10
        sv.alignment = .center
        
        return sv
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupView() {
        contentView.addSubview(mainStackView)
        mainStackView.addArrangedSubview(artworkImageView)
        mainStackView.addArrangedSubview(subStackView)
        subStackView.addArrangedSubview(textStackView)
        subStackView.addArrangedSubview(durationLabel)
        subStackView.addArrangedSubview(addButton)
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(artistLabel)
        
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            artworkImageView.widthAnchor.constraint(equalToConstant: 56),
            artworkImageView.heightAnchor.constraint(equalTo: artworkImageView.widthAnchor),
            
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }
    
    @objc private func addButtonTapped() {
        onAddButtonTapped?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        artworkImageView.image = nil
        artworkImageView.isHidden = false
        onAddButtonTapped = nil
        addButton.setImage(UIImage(named: "plus.circle"), for: .normal)
    }
    
    func setSavedState(_ isSaved: Bool) {
        let imageName = isSaved ? "checkmark.circle.fill" : "plus.circle"
        addButton.setImage(UIImage(named: imageName), for: .normal)
    }
    
    func configure(with track: Track, showArtwork: Bool, accessory: TrackCellAccessory, isSaved: Bool = false) {
        titleLabel.text = track.title
        artistLabel.text = track.artist
        durationLabel.text = track.duration
        
        artworkImageView.isHidden = !showArtwork
        if showArtwork {
            artworkImageView.load(from: track.imageUrl)
        }
        
        setSavedState(isSaved)
        
        switch accessory {
        case .addButton:
            addButton.isHidden = false
            durationLabel.isHidden = true
        case .duration:
            addButton.isHidden = true
            durationLabel.isHidden = false
        case .none:
            addButton.isHidden = true
            durationLabel.isHidden = true
        }
    }
}
