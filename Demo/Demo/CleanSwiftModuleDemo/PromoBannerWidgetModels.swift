//
//  PromoBunnerWidgetModels.swift
//
//  Created by Андрей Коноплёв on 29.06.2022.
//

import UIKit

enum PromoBannerWidgetModels {
    enum ShowBanner {
        struct Request {}
        struct Response {
            let header: String?
            let description: String?
            let dataImage: Data?
            let dataDarkImage: Data?
        }
        struct ViewModel {
            let header: String?
            let description: String?
            let image: UIImage?
            let darkImage: UIImage?
        }
    }
    enum HideBanner {
        struct Request {}
        struct Response {}
        struct ViewModel {}
    }
    enum Images {
        struct Request {
            let lightURL: String
            let darkURL: String
        }
        struct Response {
            let lightData: Data?
            let darkData: Data?
        }
        struct ViewModel {}
    }
    struct BannerData {
        let widgetCreditHolidaysHeader: String
        let widgetCreditHolidaysInfo: String
        let widgetInsuranceHeader: String
        let widgetInsuranceInfo: String
        let icons: Icons?
    }
    struct Icons {
        let insurance: String
        let insuranceBlack: String
        let holidays: String
        let holidaysBlack: String
    }
    
    enum BannerType {
        static let creditHolidays = "CreditHolidaysRequest"
        static let creditInsurance = "InsuranceAggregatorRequest"
    }
}
