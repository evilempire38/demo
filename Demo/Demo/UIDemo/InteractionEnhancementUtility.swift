//
//  InteractionEnhancementUtility.swift
//  Demo
//
//  Created by Коноплёв Андрей Андреевич on 06.02.2024.
//

public enum InteractionEnhancementUtility {
    static func copyToClipboard(text: String?,
                                statusMessageTitle: String) {
        UIPasteboard.general.string = text
        MessageBox.showStatusMessage(StatusMessageViewModel(.success, title: statusMessageTitle.localizedString))
    }
}
