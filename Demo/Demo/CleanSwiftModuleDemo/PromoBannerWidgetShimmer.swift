//
//  PromoBannerWidgetShimmer.swift
//
//
//  Created by Андрей Коноплёв on 05.07.2022.
//

import Foundationd
import UIKit

final class PromoBannerWidgetShimmer: ShimmingView {
    private enum Constants {
        static let horizontalLeftSpacing: CGFloat = 16
        static let horizontalSpacing: CGFloat = 20
        static let buttonBottomSpacing: CGFloat = 10
        static let headerShimmerWidth: CGFloat = 300
        static let headerShimmerHeight: CGFloat = 150
        static let buttonShimmerWeight: CGFloat = 140
        static let buttonShimmerHeight: CGFloat = 20
    }
    
    private enum Styles: String {
        case basicBackground
        case shimmerStyle
    }
    
    private let mainShimmer: SubtitleTitleMainShimmingView = SubtitleTitleMainShimmingView().prepareForAutoLayout()
    private let activateButtonShimmer: LeftTextShimmingView = LeftTextShimmingView().prepareForAutoLayout()
    private let scheduler: PeriodicLinearScheduler = PeriodicLinearScheduler()
    
    init() {
        super.init(frame: .zero)
        configureShimmerView()
        self.schedule(on: scheduler)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureShimmerView() {
        addSubview(mainShimmer)
        mainShimmer.widthAnchor ~= Constants.headerShimmerWidth
        mainShimmer.heightAnchor ~= Constants.headerShimmerHeight
        mainShimmer.topAnchor ~= topAnchor + Constants.horizontalSpacing
        mainShimmer.leftAnchor ~= leftAnchor + Constants.horizontalLeftSpacing
        
        addSubview(activateButtonShimmer)
        activateButtonShimmer.leftAnchor ~= leftAnchor
        activateButtonShimmer.bottomAnchor ~= bottomAnchor
        activateButtonShimmer.widthAnchor ~= Constants.buttonShimmerWeight
        activateButtonShimmer.heightAnchor ~= Constants.buttonShimmerHeight
        
        applyStyle(style: Styles.shimmerStyle.rawValue)
    }
    
    func schedule(on scheduler: PeriodicLinearScheduler) {
        mainShimmer.schedule(on: scheduler)
        activateButtonShimmer.schedule(on: scheduler)
    }
    
    func start() {
        scheduler.start()
    }
    
    func stop() {
        scheduler.stop()
    }
}
