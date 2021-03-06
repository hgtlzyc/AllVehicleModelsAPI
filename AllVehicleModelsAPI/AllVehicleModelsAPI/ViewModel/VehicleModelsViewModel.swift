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
    //Strings
    var statusString: String {
        let correntlyAnsweredCount = targetAnswers.intersection(userAnswered).count
        let totalTriesCount = userAnswered.count
        return "\(targetAnswers.count) models, \(correntlyAnsweredCount) correct, tried \(totalTriesCount) times"
    }
    
    var sortedCurrentlyCorrectAnswers: [(String,Bool)] {
        return baseSetSortAndMap( targetAnswers.intersection(userAnswered) , status: true)
    }
    
    var sortedAllCorrectAndWrongAnswers: [(String,Bool)] {
        let correntlyAnsweredSet = targetAnswers.intersection(userAnswered)
        let currentlyWrongSet = targetAnswers.subtracting(userAnswered)
        
        return baseSetSortAndMap(correntlyAnsweredSet, status: true) + baseSetSortAndMap(currentlyWrongSet, status: false)
    }
    
    //Ints
    var worngAnswersCount: Int {
        return targetAnswers.subtracting(userAnswered).count
    }
    
    // MARK: - write
    func resetForNextQuestion(){
        userAnswered = Set<String>()
        targetAnswers = Set<String>()
        makeName = nil
    }
    
    ///put the string in the user answered set, returns bool indicates if the user answer is correct
    func newUserAnswered(_ string: String) -> Bool {
        userAnswered.insert(string)
        return targetAnswers.contains(string)
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
    
}//End Of ViewModel
