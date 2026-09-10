//
//  HorizontalSectionView.swift
//  RecreateSpotify
//
//  Created by George Maximillian Theodore on 06/09/26.
//

import UIKit

class HorizontalSectionView: UIView {
    
    var onAlbumSelected: ((String) -> Void)?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title2)
        
        if let boldDescriptor = descriptor.withSymbolicTraits(.traitBold) {
            label.font = UIFont(descriptor: boldDescriptor, size: descriptor.pointSize)
        }
        
        return label
    }()
    
    private let horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .horizontal
        stackView.spacing = 16
        
        return stackView
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.showsHorizontalScrollIndicator = false
        
        return scrollView
    }()
    
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .vertical
        stackView.spacing = 12
        
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    private func setupView() {
        addSubview(mainStackView)
        
        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(scrollView)
        
        scrollView.addSubview(horizontalStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            horizontalStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            horizontalStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            horizontalStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            horizontalStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            horizontalStackView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor),
            
            scrollView.heightAnchor.constraint(equalToConstant: 210)
        ])
    }
    
    func configure(title: String, items: [Album]) {
        titleLabel.text = title
        
        horizontalStackView.arrangedSubviews.forEach {
            horizontalStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        items.forEach { item in
            let card = AlbumCardView()
            card.configure(with: item)
            
            card.onCardTapped = { [weak self] in
                self?.onAlbumSelected?(item.id)
            }
            
            horizontalStackView.addArrangedSubview(card)
        }
    }
}
