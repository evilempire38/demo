//
//  PromoBunnerWidgetInteractor.swift
//
//  Created by Андрей Коноплёв on 29.06.2022.
//
import Foundation

final class PromoBannerWidgetInteractor: PromoBannerWidgetBusinessLogic,
                                         CCAccountServicesProviderProtocolDelegate,
                                         PromoBannerWidgetDataStore {
    private enum Constants {
        static var closedKey: String { "promoBunnerClosedDateKey" }
        static var tenDays: Int { 10 }
    }
    private typealias ShowResponse = PromoBannerWidgetModels.ShowBanner.Response
    private let payloadRepo: CCPayloadRepoProtocol
    private let presenter: PromoBunnerWidgetPresentationLogic
    private let worker: CMSWidgetWorkerLogic
    private let ccServicesWorker: CCAccountServicesProviderProtocol
    private let dataFetcherWorker: DataPackageWorker
    private let cmsHelper: CMSWidgetHelperLogic
    private let ccDetailsWorker: CCAccountWorkerLogic
    private var cmsInfoProductPage: CmsInfoProductPage?
    private var insuranceChecker: InsuranceBunnerAvailableProtocol
    private var creditHolidaysChecker: CreditHolidaysBunnerAvailableProtocol
    private(set) var isCreditHolidays: Bool?
    private(set) var publicID: String?
    private(set) var cardNumber: String?
    private var localModel: PromoBannerWidgetModels.BannerData {
        cmsHelper.makePromoBannerLocalModel()
    }
    
    init(
        presenter: PromoBunnerWidgetPresentationLogic,
        worker: CMSWidgetWorkerLogic,
        ccServicesWorker: CCAccountServicesProviderProtocol,
        cmsHelper: CMSWidgetHelperLogic,
        insuranceChecker: InsuranceBunnerAvailableProtocol,
        creditHolidaysChecker: CreditHolidaysBunnerAvailableProtocol,
        dataFetcherWorker: DataPackageWorker,
        payloadRepo: CCPayloadRepoProtocol,
        ccDetailsWorker: CCAccountWorkerLogic
    ) {
        self.presenter = presenter
        self.worker = worker
        self.ccServicesWorker = ccServicesWorker
        self.cmsHelper = cmsHelper
        self.insuranceChecker = insuranceChecker
        self.creditHolidaysChecker = creditHolidaysChecker
        self.dataFetcherWorker = dataFetcherWorker
        self.payloadRepo = payloadRepo
        self.ccDetailsWorker = ccDetailsWorker
        ccServicesWorker.addDelegate(self)
    }
    
    func requestBanner(_ request: PromoBannerWidgetModels.ShowBanner.Request) {
        guard isTenDaysPass() else {
            hideBanner()
            return
        }
        publicID = payloadRepo.publicId
        ccServicesWorker.fetch(
            publicId: payloadRepo.publicId ?? "",
            productType: payloadRepo.productType ?? .creditCardAccount
        )
    }
    func requestHideBanner(_ request: PromoBannerWidgetModels.HideBanner.Request) {
        hideBanner()
    }
    
    func onSuccess(model: CCServicesModelList) {
        let creditHolidaysMatching: CCServicesModel? = model.first(where: { $0.service == PromoBannerWidgetModels.BannerType.creditHolidays })
        let insuranceMatching: CCServicesModel? = model.first(where: { $0.service == PromoBannerWidgetModels.BannerType.creditInsurance })
        worker.getCmsInfoProductPage { [weak self] result in
            guard
                let self = self,
                let successCMS: CmsInfoProductPage = try? result.get(),
                let icons = successCMS.icons
            else {
                    guard let self = self else { return }
                    if creditHolidaysMatching != nil {
                        self.substituteLocalModel(localModel: self.localModel, type: .creditHolidays)
                    } else if insuranceMatching != nil {
                        self.substituteLocalModel(localModel: self.localModel, type: .insurance)
                    } else {
                        self.hideBanner()
                    }
                    return
                }
            self.ccDetailsWorker.fetchData { [weak self] result in
                guard
                    let self = self,
                    let success: CCAccount = try? result.get()
                else {
                        guard let self = self else { return }
                        if insuranceMatching != nil {
                            self.substituteLocalModel(localModel: self.localModel, type: .insurance)
                        } else {
                            self.hideBanner()
                        }
                        return
                    }
                self.cardNumber = success.number
                if creditHolidaysMatching != nil,
                   self.creditHolidaysChecker.isCreditHolidaysEnabled(account: success),
                   let iconLightURL = icons.holidays,
                   let iconDarkURL = icons.holidaysBlack {
                    self.isCreditHolidays = true
                    let requestImage: PromoBannerWidgetModels.Images.Request = PromoBannerWidgetModels.Images.Request(
                        lightURL: iconLightURL,
                        darkURL: iconDarkURL
                    )
                    self.presentData(
                        request: requestImage,
                        type: .creditHolidays,
                        cms: successCMS
                    )
                } else if insuranceMatching != nil,
                          self.insuranceChecker.isPromoBunnerEnabled(),
                          let iconLightURL = icons.insurance,
                          let iconDarkURL = icons.insuranceBlack {
                    self.isCreditHolidays = false
                    let requestImage: PromoBannerWidgetModels.Images.Request = PromoBannerWidgetModels.Images.Request(
                        lightURL: iconLightURL,
                        darkURL: iconDarkURL
                    )
                    self.presentData(
                        request: requestImage,
                        type: .insurance,
                        cms: successCMS
                    )
                } else {
                    self.hideBanner()
                }
            }
        }
    }
    
    func onError(_ error: Error) {
        hideBanner()
    }
    
    private func hideBanner() {
        let response: PromoBannerWidgetModels.HideBanner.Response = PromoBannerWidgetModels.HideBanner.Response()
        DispatchQueue.main.async {
            self.presenter.presentHideBanner(response)
        }
    }
    
    private func substituteLocalModel(
        localModel:PromoBannerWidgetModels.BannerData,
        type: LocalModelType
    ) {
        switch type {
            case .creditHolidays:
                let response: ShowResponse = ShowResponse(
                    header: localModel.widgetCreditHolidaysHeader,
                    description: localModel.widgetCreditHolidaysInfo,
                    dataImage: nil,
                    dataDarkImage: nil
                )
                DispatchQueue.main.async {
                    self.presenter.presentBanner(response)
                }
            case .insurance:
                let response: ShowResponse = ShowResponse(
                    header: localModel.widgetInsuranceHeader,
                    description: localModel.widgetInsuranceInfo,
                    dataImage: nil,
                    dataDarkImage: nil
                )
                DispatchQueue.main.async {
                    self.presenter.presentBanner(response)
                }
        }
    }
    
    private func presentData(
        request: PromoBannerWidgetModels.Images.Request,
        type: LocalModelType,
        cms: CmsInfoProductPage
    ) {
        dataFetcherWorker.fetchDataPackage(request: request) { [weak self] response in
            guard let self = self else { return }
            guard let response = response
            else {
                self.substituteLocalModel(localModel: self.localModel, type: type)
                return
            }
            var showResponse: ShowResponse
            switch type {
                case .creditHolidays:
                    showResponse = ShowResponse(
                        header: cms.widgetCreditHolidaysHeader,
                        description: cms.widgetCreditHolidaysInfo,
                        dataImage: response.lightData,
                        dataDarkImage: response.darkData
                    )
                case .insurance:
                    showResponse = ShowResponse(
                        header: cms.widgetInsuranceHeader,
                        description: cms.widgetInsuranceInfo,
                        dataImage: response.lightData,
                        dataDarkImage: response.darkData
                    )
            }
            DispatchQueue.main.async {
                self.presenter.presentBanner(showResponse)
            }
        }
    }
    
    private func isTenDaysPass() -> Bool {
        let userDefaultsManager = UserDefaults.standard
        guard
            let closedDate = userDefaultsManager.object(forKey: Constants.closedKey) as? Date,
            let tenDaysLaterDate = Calendar.current.date(byAdding: .day, value: Constants.tenDays, to: closedDate) else {
                return true
            }
        let currentDate = Date()
        guard currentDate <= tenDaysLaterDate else {
            userDefaultsManager.removeObject(forKey: Constants.closedKey)
            return true
        }
        return false
    }
    
    private enum LocalModelType {
        case creditHolidays
        case insurance
    }
}
