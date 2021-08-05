//
//  VehicleModelsViewModel.swift
//  AllVehicleModelsAPI
//
//  Created by lijia xu on 8/4/21.
//

import Foundation

class VehicleModelsViewModel {
    private var userAnswered = Set<String>()
    private var targetAnswers = Set<String>()
    
    var makeName: String?
    
    // MARK: - read
    var statusString: String {
        let correntlyAnsweredCount = targetAnswers.intersection(userAnswered).count
        let wrongAnswetsCount = userAnswered.subtracting(targetAnswers).count
        return "\(targetAnswers.count) models, you got \(correntlyAnsweredCount) correct, \(wrongAnswetsCount) wrong"
    }
    
    var sortedCurrentlyCorrectAnswers: [(String,Bool)] {
        return baseSetSortAndMap( targetAnswers.intersection(userAnswered) , status: true)
    }
    
    var sortedAllCorrectAndWrongAnswers: [(String,Bool)] {
        let correntlyAnsweredSet = targetAnswers.intersection(userAnswered)
        let currentlyWrongSet = targetAnswers.subtracting(userAnswered)
        
        return baseSetSortAndMap(correntlyAnsweredSet, status: true) + baseSetSortAndMap(currentlyWrongSet, status: false)
    }
    
    // MARK: - write
    func resetForNextQuestion(){
        userAnswered = Set<String>()
        targetAnswers = Set<String>()
        makeName = nil
    }
    
    func newUserAnswered(_ string: String) {
        userAnswered.insert(string)
    }
    
    func setCorrectAnswers(_ answerArr: [String]) {
        targetAnswers = Set(answerArr)
    }
    
    //Helper
    private func baseSetSortAndMap(_ baseSet: Set<String>, status: Bool) -> [(String,Bool)] {
        Array( baseSet )
            .sorted{ ($0.first ?? "a") < ($1.first ?? "a") }
            .map{($0,status)}
    }
    
}
