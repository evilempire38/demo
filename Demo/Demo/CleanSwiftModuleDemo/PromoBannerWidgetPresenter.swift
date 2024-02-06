//
//  PromoBunnerWidgetPresenter.swift
//
//  Created by Андрей Коноплёв on 29.06.2022.
//

import UIKit

final class PromoBannerWidgetPresenter: PromoBunnerWidgetPresentationLogic {
    private typealias ShowViewModel = PromoBannerWidgetModels.ShowBanner.ViewModel
    typealias ShowResponse = PromoBannerWidgetModels.ShowBanner.Response
    typealias HideResponse = PromoBannerWidgetModels.HideBanner.Response
    private typealias HideViewModel = PromoBannerWidgetModels.HideBanner.ViewModel
    weak var view: PromoBunnerWidgetDisplayLogic?

    func presentBanner(_ response: ShowResponse) {
        if
            let dataImage = response.dataImage,
            let dataDarkImage = response.dataDarkImage {
            let viewModel = ShowViewModel(
                header: response.header,
                description: response.description,
                image: UIImage(data: dataImage),
                darkImage: UIImage(data: dataDarkImage)
            )
            view?.displayBanner(viewModel)
        } else {
            let viewModel = ShowViewModel(
                header: response.header,
                description: response.description,
                image: nil,
                darkImage: nil
            )
            view?.displayBanner(viewModel)
        }
    }
    func presentHideBanner(_ response: HideResponse) {
        let viewModel: HideViewModel = HideViewModel()
        view?.displayHideBanner(viewModel)
    }
}
