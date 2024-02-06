//
//  PromoBunnerWidget.swift
//  
//
//  Created by Андрей Коноплёв on 30.06.2022.
//

import Foundation
import ContainerModule
import ContainerPlugins
import UIKit

final class PromoBannerWidget: Widget,
                               DetailPageMarker,
                               Unremovable,
                               Undraggable
{
    var position: WidgetStaticPosition = .top(priority: 60)
    
    typealias ShowRequest = PromoBannerWidgetModels.ShowBanner.Request
    typealias ShowViewModel = PromoBannerWidgetModels.ShowBanner.ViewModel
    typealias HideViewModel = PromoBannerWidgetModels.HideBanner.ViewModel
    private let interactor: PromoBannerWidgetInteractor
    private let router: PromoBannerWidgetRoutingLogic
    
    init(
        interactor: PromoBannerWidgetInteractor,
        router: PromoBannerWidgetRoutingLogic
    ) {
        self.interactor = interactor
        self.router = router
        let view = PromoBannerWidgetView()
        super.init(
            id: "CreditHolidaysInsuranceWidget-\(UUID().uuidString)",
            size: .medium,
            contentView: view
        )
        view.actionTap = { [weak self] in
            self?.router.routeToActivateScenario()
        }
        view.actionCloseBunner = { [weak self] in
            self?.interactor.requestHideBanner(PromoBannerWidgetModels.HideBanner.Request())
        }
    }
    
    override func containerDidLoad() {
        interactor.requestBanner(ShowRequest())
    }
}

extension PromoBannerWidget: PromoBunnerWidgetDisplayLogic {
    var view: PromoBannerWidgetView? {
        contentView as? PromoBannerWidgetView
    }
    
    func displayBanner(_ viewModel: ShowViewModel) {
        view?.configure(with: viewModel)
    }
    func displayHideBanner(_ viewModel: HideViewModel) {
        router.routeHideWidget()
    }
}

extension PromoBannerWidget: ViewControllerProvider {
    func getNavigationController() -> UINavigationController? {
        return self.contentView.parentViewController?.navigationController
    }
}
