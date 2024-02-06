//
//  DemoAnalyticsManager.swift
//  Demo
//
//  Created by Коноплёв Андрей Андреевич on 06.02.2024.
//

final class DemoAnalyticsManager {}

// MARK: - DemoAnalyticsManaging

extension DemoAnalyticsManager: DemoAnalyticsManaging {
    func trackFirstEvent() {
        track(.firstEvent, parameters: [:])
    }
    
    func trackSecondEvent() {
        track(.secondEventm, parameters: [:])
    }
    
    func trackThirdEvent() {
        track(.thirdEvent, parameters: [:])
    }
    
    func trackFourthEvent() {
        track(.fourthEvent, parameters: [:])
    }
}

// MARK: - Work

extension DemoAnalyticsManager {
    private func track(_ name: EventNameEnum, parameters: [String: String]) {
        SomeFacilityForMetrics.send(name.rawValue, parameters: parameters)
    }
}
