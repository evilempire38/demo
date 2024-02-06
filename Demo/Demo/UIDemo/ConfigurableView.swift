//
//  ConfigurableView.swift
//  Demo
//
//  Created by Коноплёв Андрей Андреевич on 06.02.2024.
//

import UIKit

public protocol ConfigurableView: PlainConfigurableView {
    var reactionStyle: ReactionStyle { get }
    var isProcessing: Bool { get }
    var processingColor: UIColor { get }
    var isReactionEnabled: Bool { get }
    var edgesInsets: UIEdgeInsets { get }
    func prepareForReuse()
}

public protocol PlainConfigurableView: UIView {
    associatedtype ViewModel

    func configure(_: ViewModel)
}
