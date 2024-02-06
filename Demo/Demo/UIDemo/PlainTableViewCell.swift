//
//  PlainTableViewCell.swift
//  Demo
//
//  Created by Коноплёв Андрей Андреевич on 06.02.2024.
//

import UIKit
import SnapKit

final class PlainTableViewCell<View: PlainConfigurableView>: UITableViewCell {
    private let payloadView = View()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder _: NSCoder) {
        nil
    }
}

// MARK: - PlainConfigurableView

extension PlainTableViewCell: PlainConfigurableView {
    func configure(_ viewModel: View.ViewModel) {
        payloadView.configure(viewModel)
    }
}

// MARK: - Setup

extension PlainTableViewCell {
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(payloadView)
        payloadView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

