//
//  ChangeLimitViewModel.swift
//  Demo
//
//  Created by Коноплёв Андрей Андреевич on 06.02.2024.
//

final class ChangeLimitViewModel: ChangeLimitViewModelling {
    private enum Constants {
        static let totalIncomeChips = ["60 000", "90 000", "120 000", "150 000"]
            .map { AmountModel(amount: $0).formatted(.full) }
    }

    private let router: ChangeCreditLimitRouting
    private let cardModel: UserCardModel
    private let analyticsManager: ChangeCreditLimitAnalyticsManager

    init(router: ChangeCreditLimitRouting,
         cardModel: UserCardModel,
         analyticsManager: ChangeCreditLimitAnalyticsManager) {
        self.router = router
        self.cardModel = cardModel
        self.analyticsManager = analyticsManager
        let inOut = Self.make(router: router, cardModel: cardModel, analyticsManager: analyticsManager)
        super.init(input: inOut.input, output: inOut.output)
    }

    override func trackShow() {
        analyticsManager.trackScreenNewCreditLimit()
    }
}

// MARK: - Work

extension ChangeCreditLimitViewModel {
    fileprivate static func make(router: ChangeCreditLimitRouting,
                                 cardModel: UserCardModel,
                                 analyticsManager: ChangeCreditLimitAnalyticsManager)
    -> IO {
        let input = ChangeCreditLimitInput(
            requestDesireLimitTrigger: PublishSubject<Void>(),
            totalIncomeText: BehaviorRelay<String>(value: ""),
            desireText: BehaviorRelay<String>(value: "")
        )
        let outputTotalIncomeText = BehaviorRelay<String>(value: "")
        let outputTotalIncomeChips = Constants.totalIncomeChips.map { chip in
            ActionChipViewModel(title: chip) { [weak analyticsManager] in
                analyticsManager?.trackEventNewCreditTotalIncomeHint(hint: chip)
                outputTotalIncomeText.accept(chip)
            }
        }
        let output = ChangeCreditLimitOutput(
            connect: makeDesireLimitCallback(input: input, router: router, cardModel: cardModel, analyticsManager: analyticsManager),
            totalIncomeChips: outputTotalIncomeChips,
            totalIncomeText: outputTotalIncomeText,
            cardModel: cardModel
        )
        return InOut(input, output)
    }

    fileprivate static func makeConnectOutput(input: ChangeCreditLimitInput,
                                              router: ChangeCreditLimitRouting,
                                              cardModel: UserCardModel,
                                              analyticsManager: ChangeCreditLimitAnalyticsManager) -> Observable<Void> {
        Observable.merge(makeDesireLimitCallback(input: input, router: router, cardModel: cardModel, analyticsManager: analyticsManager))
    }

    fileprivate static func makeDesireLimitCallback(input: ChangeCreditLimitInput,
                                                    router: ChangeCreditLimitRouting,
                                                    cardModel: UserCardModel,
                                                    analyticsManager: ChangeCreditLimitAnalyticsManager) -> Observable<Void> {
        input.requestDesireLimitTrigger.flatMap { _ -> Observable<Void> in
            CreditCardLimitChangeNewClaimRequest(
                agreementNumber: cardModel.agreementNumber.getValueOrDefault(),
                newCreditLimit: AmountModel(amountWithSpacesAndRUB: input.desireText.value).formatted(.networkRequest),
                totalIncome: AmountModel(amountWithSpacesAndRUB: input.totalIncomeText.value).formatted(.networkRequest)
            )
            .newFetch()
            .observe(on: MainScheduler.instance)
            .trackActivity(router.activityIndicator)
            .map { response in
                switch response.status {
                case .created:
                    analyticsManager.trackScreenNewCreditLimitFailed()
                    router.open(step: .result(.changeCreditLimitFail))
                case .new:
                    let resultModel = ResultModel(
                        capitalIcon: .success,
                        title: response.title,
                        text: response.text,
                        next: .mainScreen,
                        cancel: .none
                    )
                    analyticsManager.trackScreenNewCreditLimitSuccess()
                    router.open(step: .result(resultModel))
                case .none:
                    analyticsManager.trackScreenNewCreditLimitFailed()
                    router.open(step: .result(.changeCreditLimitFail))
                }
            }
            .catch { error in
                guard let error = (error as? NetworkErrorDTO) else {
                    analyticsManager.trackScreenNewCreditLimitFailed()
                    router.open(step: .result(.changeCreditLimitFail))
                    return .just(())
                }
                let resultModel = ResultModel(
                    capitalIcon: .fail,
                    title: error.shortDescription,
                    text: error.description,
                    next: .mainScreen,
                    cancel: .none
                )
                analyticsManager.trackScreenNewCreditLimitFailed()
                router.open(step: .result(resultModel))
                return .just(())
            }
        }
    }
}

// MARK: - Helpers

extension ChangeCreditLimitViewModel {
    @discardableResult
    func validationSources() -> Bool {
        !(input.totalIncomeText.value.isEmpty || AmountModel(amountWithSpacesAndRUB: input.totalIncomeText.value).isZero)
    }

    @discardableResult
    func validationDesire() -> Bool {
        AmountModel(amountWithSpacesAndRUB: input.desireText.value) > (cardModel.initialLimit.toAmountModel() ?? .zero(currency: .default))
    }
}

