//
//  CopyFieldView.swift
//  Demo
//
//  Created by Коноплёв Андрей Андреевич on 06.02.2024.
//

import UIKit

public final class CopyFieldView: UIView {
    private enum Grid {
        static let copyButtonDimension: CGFloat = 24
    }

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let copyButton = TargetedMainButton(.text)

    init() {
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder _: NSCoder) {
        nil
    }
}

// MARK: - ConfigurableView

extension CopyFieldView: ConfigurableView {
    public func configure(_ viewModel: CopyFieldModel) {
        titleLabel.text = viewModel.titleText
        subtitleLabel.text = viewModel.subtitleText
        copyButton.configure(
            TargetedMainButtonModel(
                content: .image(.icon(IconTokens.copy, tintColor: ColorTokens.iconPrimary)),
                action: viewModel.action
            )
        )
    }

    public var edgesInsets: UIEdgeInsets {
        UIEdgeInsets.symmetric(horizontal: AppSize.edgeInset, vertical: AppSize.edgeInset.half)
    }
}

// MARK: - Setup

extension CopyFieldView {
    private func setupUI() {
        backgroundColor = ColorTokens.blockSecondary
        cornerRadius = AppSize.cornerRadiusSmall8
        setupTitleLabel()
        setupSubtitleLabel()
        setupCopyButtonView()
    }

    private func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(AppSize.space6)
            $0.applyWidth(AppSize.edgeInset.half)
        }
    }

    private func setupSubtitleLabel() {
        addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints {
            $0.belowTo(titleLabel).offset(AppSize.space2)
            $0.leading.equalToSuperview().offset(AppSize.edgeInset.half)
            $0.bottom.equalToSuperview().inset(AppSize.space6)
        }
    }

    private func setupCopyButtonView() {
        addSubview(copyButton)
        copyButton.snp.makeConstraints {
            $0.belowTo(titleLabel).offset(AppSize.space2)
            $0.afterTo(subtitleLabel).offset(AppSize.space4)
            $0.trailing.equalToSuperview().inset(AppSize.space8)
            $0.bottom.equalToSuperview().inset(AppSize.space6)
            $0.size.equalTo(Grid.copyButtonDimension)
        }
    }
}

