//
//  PromoBunnerWidgetRouter.swift
//  Created by Андрей Коноплёв on 29.06.2022.
//

import UIKit

final class PromoBannerWidgetRouter: PromoBannerWidgetRoutingLogic {
    var creditHolidaysLauncher: CreditHolidaysLauncherProtocol?
    var insuranceLauncher: InsuranceAggregatorLauncherProtocol?
    let dataStore: PromoBannerWidgetDataStore
    private let errorController: CCErrorControllerProtocol
    private let closeBehaviour: CCWidgetCloseBehaviourProtocol
    private let analytics: CredCardDetailAnalyticsProtocol
    
    init(
        dataStore: PromoBannerWidgetDataStore,
        errorController: CCErrorControllerProtocol,
        closeBehaviour: CCWidgetCloseBehaviourProtocol,
        analytics: CredCardDetailAnalyticsProtocol
    ) {
        self.dataStore = dataStore
        self.errorController = errorController
        self.closeBehaviour = closeBehaviour
        self.analytics = analytics
    }
    
    func routeToActivateScenario() {
        analytics.promoBannerWidgetDidTap()
        guard
            let publicID = dataStore.publicID,
            let cardNumber = dataStore.cardNumber,
            let isCreditHolidays = dataStore.isCreditHolidays
        else {
            return
        }
        if isCreditHolidays {
            creditHolidaysLauncher?.launchCreditHolidays(publicID: publicID)
        } else {
            insuranceLauncher?.launchInsuranceAggregator(cardNumber: cardNumber)
        }
    }

    func routeHideWidget() {
        closeBehaviour.requestClose()
    }
}
