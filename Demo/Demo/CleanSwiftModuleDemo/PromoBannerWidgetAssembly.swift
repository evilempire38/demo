//
//  PromoBunnerWidgetAssembly.swift
//
//  Created by Андрей Коноплёв on 29.06.2022.
//

import Foundation
import ContainerModule
import ContainerPlugins
import UIKit

final class PromoBannerWidgetAssembly: AbstractWidgetFactory,
                                       CCWidgetFactoryProtocol,
                                       CCWidgetMetatypeHavingProtocol {
    func create() -> CCWidget? {
        let presenter = PromoBannerWidgetPresenter()
        let cmsWidgetHelper = CMSWidgetHelper()
        let insuranceChecker = InsuranceCCardAvailableChecker(
            healthCheckManager: dependency.healthCheckManager,
            coreInfoRepository: dependency.ccCoreInfoRepo
        )
        let creditHolidaysChecker = CreditHolidaysAvailableChecker(
            healthCheckManager: dependency.healthCheckManager,
            coreInfoRepository: dependency.ccCoreInfoRepo
        )
        let dataFetcher = DataFetcher()
        let dataFetcherWorker = DataPackageWorker(dataFetcher: dataFetcher)
        let interactor = PromoBannerWidgetInteractor(
            presenter: presenter,
            worker: dependency.cmsWorker,
            ccServicesWorker: dependency.servicesProvider,
            cmsHelper: cmsWidgetHelper,
            insuranceChecker: insuranceChecker,
            creditHolidaysChecker: creditHolidaysChecker,
            dataFetcherWorker: dataFetcherWorker,
            payloadRepo: payloadRepo,
            ccDetailsWorker: CCAccountWorker(
                detailsService: dependency.detailProvider,
                accountInfoRepo: payloadRepo
            )
        )
        let closeBehaviour = CCWidgetCloseBehaviour(
            eventPublisher: dependency.eventPublisher,
            payloadBuilderFactory: CCPayloadBuilderFactory()
        )
        let router = PromoBannerWidgetRouter(
            dataStore: interactor,
            errorController: dependency.errorController,
            closeBehaviour: closeBehaviour,
            analytics: dependency.analytics
        )
        let widget = PromoBannerWidget(
            interactor: interactor,
            router: router
        )
        let creditHolidaysLauncher = CreditHolidaysLauncher(
            eventPublisher: dependency.eventPublisher,
            viewControllerProvider: widget
        )
        let insuranceLauncher = InsuranceAggregatorLauncher(
            eventPublisher: dependency.eventPublisher,
            viewControllerProvider: widget
        )
        
        closeBehaviour.widget = widget
        presenter.view = widget
        router.creditHolidaysLauncher = creditHolidaysLauncher
        router.insuranceLauncher = insuranceLauncher
        closeBehaviour.widget = widget
        return widget
    }
    
    private func extractProductType() -> Bool {
        guard let productType = dependency.payloadRepo.productType else { return false }
        switch productType {
            case .creditCardAccount:
                return true
            case .creditCard, .undefined, .creditLine:
                return false
        }
    }
    
    func createWidget() -> CCWidget? {
        guard extractProductType() else { return nil }
        return create()
    }
    
    var type: Widget.Type {
        return PromoBannerWidget.self
    }
}

