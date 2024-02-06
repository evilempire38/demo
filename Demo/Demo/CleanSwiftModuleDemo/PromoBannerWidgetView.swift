//
//  PromoBunnerWidgetView.swift
//
//
//  Created by Андрей Коноплёв on 30.06.2022.
//

import UIKit

final class PromoBannerWidgetView: UIView {
    typealias ViewModel = PromoBannerWidgetModels.ShowBanner.ViewModel
    
    private enum Constants {
        static let topDescriptionSpacing: CGFloat = 8
        static let horizontalLeftSpacing: CGFloat = 16
        static let verticalSpacing: CGFloat = 16
        static let imageViewHeight: CGFloat = 140
        static let imageViewWidth: CGFloat = 140
        static let activateButtonOffset: CGFloat = 10
        static let headerOffset: CGFloat = 20
        static let closeButtonSideSize: CGFloat = 20
        static let closeButtonOffset: CGFloat = 8
        static let activateLabelText: String = "promoBannerWidgetActivateButton".resourceOrEmpty
        static let closedKey: String = "promoBunnerClosedDateKey" 
    }
    
    private enum Styles: String {
        case promoBannerwidgetView
        case promoBannerActivateButton
        case titleMainText
        case caCalendarEventStepperHeader
        case blockUnblockWidgetHeader
        case ccDescriptionBannerLabel
    }
    
    private let shimmerView = PromoBannerWidgetShimmer().prepareForAutoLayout()
    
    private let headerLabel: UILabel = {
        let label = UILabel().prepareForAutoLayout()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label.prepareForAutoLayout()
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel().prepareForAutoLayout()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label.prepareForAutoLayout()
    }()
    
    private let activateButton: UIButton = {
        let button = UIButton().prepareForAutoLayout()
        button.contentVerticalAlignment = .center
        return button.prepareForAutoLayout()
    }()
    
    private let closeButton: UIButton = UIButton().prepareForAutoLayout()
    
    private let bannerImageView: UIImageView = UIImageView().prepareForAutoLayout()
    var actionTap: (() -> Void)?
    var actionCloseBunner: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    convenience init() {
        self.init(frame: .zero)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(bannerImageView)
        bannerImageView.heightAnchor ~= Constants.imageViewHeight
        bannerImageView.widthAnchor ~= Constants.imageViewWidth
        bannerImageView.bottomAnchor ~= bottomAnchor
        bannerImageView.rightAnchor ~= rightAnchor
        
        addSubview(headerLabel)
        headerLabel.topAnchor ~= topAnchor + Constants.headerOffset
        headerLabel.leftAnchor ~= leftAnchor + Constants.horizontalLeftSpacing
        headerLabel.rightAnchor ~= bannerImageView.leftAnchor
        headerLabel.applyStyle(style: Styles.titleMainText.rawValue)
        
        addSubview(descriptionLabel)
        descriptionLabel.topAnchor ~= headerLabel.bottomAnchor + Constants.topDescriptionSpacing
        descriptionLabel.leftAnchor ~= leftAnchor + Constants.horizontalLeftSpacing
        descriptionLabel.rightAnchor ~= bannerImageView.leftAnchor
        descriptionLabel.applyStyle(style: Styles.ccDescriptionBannerLabel.rawValue)
        
        addSubview(activateButton)
        activateButton.leftAnchor ~= leftAnchor + Constants.horizontalLeftSpacing
        activateButton.bottomAnchor ~= bottomAnchor - Constants.activateButtonOffset
        activateButton.addTarget(self, action: #selector(didTapAction), for: .touchUpInside)
        
        setupStyles()
        startShimmer()
        createGestureRecognizer()
    }
    
    private func setupStyles() {
        activateButton.applyStyle(style: Styles.promoBannerActivateButton.rawValue)
        applyStyle(style: Styles.promoBannerwidgetView.rawValue)
    }
    
    private func startShimmer() {
        addSubview(shimmerView)
        shimmerView.pinEdgesToSuperviewEdges()
        shimmerView.start()
    }
    
    private func removeShimmer() {
        shimmerView.stop()
        shimmerView.removeFromSuperview()
    }
    
    private func setupCloseButton(){
        addSubview(closeButton)
        closeButton.rightAnchor ~= rightAnchor - Constants.closeButtonOffset
        closeButton.topAnchor ~= topAnchor + Constants.closeButtonOffset
        closeButton.widthAnchor ~= Constants.closeButtonSideSize
        closeButton.heightAnchor ~= Constants.closeButtonSideSize
        closeButton.setImage(Asset.Icons.deleteInInput24.image, for: .normal)
        closeButton.addTarget(self, action: #selector(closeBunnerAction), for: .touchUpInside)
    }
    
    func configure(with model: ViewModel) {
        headerLabel.text = model.header
        descriptionLabel.text = model.description
        bannerImageView.lightImage = model.image
        bannerImageView.darkImage = model.darkImage
        activateButton.setTitle(Constants.activateLabelText, for: .normal)
        setupCloseButton()
        removeShimmer()
    }
    
    @objc private func didTapAction() {
        actionTap?()
    }
    
    @objc private func closeBunnerAction() {
        let closeDate = Date()
        let userDefaultsManager = UserDefaults.standard
        userDefaultsManager.set(closeDate, forKey: Constants.closedKey)
        actionCloseBunner?()
    }
    
    private func createGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAction))
        addGestureRecognizer(tapGesture)
    }
}
