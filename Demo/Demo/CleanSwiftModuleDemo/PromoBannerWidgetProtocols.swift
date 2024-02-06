//
//  PromoBunnerWidgetProtocols.swift
//
//  Created by Андрей Коноплёв on 29.06.2022.
//

protocol PromoBannerWidgetBusinessLogic {
    func requestBanner(_ request: PromoBannerWidgetModels.ShowBanner.Request)
    func requestHideBanner(_ request: PromoBannerWidgetModels.HideBanner.Request)
}

protocol PromoBunnerWidgetPresentationLogic {
    func presentBanner(_ response: PromoBannerWidgetModels.ShowBanner.Response)
    func presentHideBanner(_ response: PromoBannerWidgetModels.HideBanner.Response)
}

protocol PromoBunnerWidgetDisplayLogic: AnyObject {
    func displayBanner(_ viewModel: PromoBannerWidgetModels.ShowBanner.ViewModel)
    func displayHideBanner(_ viewModel: PromoBannerWidgetModels.HideBanner.ViewModel)
}

protocol PromoBannerWidgetRoutingLogic {
    func routeToActivateScenario()
    func routeHideWidget()
}

protocol PromoBannerWidgetDataStore {
    var isCreditHolidays: Bool? { get }
    var publicID: String? { get }
    var cardNumber: String? { get }
}
