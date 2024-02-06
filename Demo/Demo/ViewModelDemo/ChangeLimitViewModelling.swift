//
//  ChangeLimitViewModelling.swift
//  Demo
//
//  Created by Коноплёв Андрей Андреевич on 06.02.2024.
//

typealias ChangeLimitViewModelling = ViewModelType<ChangeCreditLimitInput, ChangeCreditLimitOutput>

struct ChangeCreditLimitInput {
    let requestDesireLimitTrigger: PublishSubject<Void>
    let totalIncomeText: BehaviorRelay<String>
    let desireText: BehaviorRelay<String>
}

struct ChangeCreditLimitOutput {
    let connect: Observable<Void>
    let totalIncomeChips: [ChipsViewModel]
    let totalIncomeText: BehaviorRelay<String>
    let cardModel: UserCardModel
}
