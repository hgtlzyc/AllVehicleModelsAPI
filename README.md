# Quiz App based on data from NHTSA API 
![](https://github.com/hgtlzyc/AllVehicleModelsAPI/blob/c4d9fea06c1b46a759db85939296e5dd5a1e39c4/nhtsaAPIScreenCapture.gif)
<br/>
- UIKit 
- NHTSA (National Highway Traffic Safety Administration) API [Link](https://vpic.nhtsa.dot.gov/api/)
- URLSession
- MVVM

#### Code snippet:

```swift

  ////there are 9746 makes available from the NHTSA, 
  ///only generate random ids based on the well known brands, some brands are just too hard, 
  ///Using idPool to avoid repeated elements unitl whole target set finished
  
  func generateRandomIDInRange(idPool: inout Set<Int>) -> Int {
      let targetSet: Set<Int> = [440,441,442,444,448,449,452,460,469,474,475,480,483,485,515,523,582,584]

      if idPool.isEmpty {idPool = targetSet}

      guard let id = idPool.randomElement(), let _ = idPool.remove(id) else {
          print("Unexpected case in \(#function), line \(#line)")
          return 440
      }

      return id
  }
    
  
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
    
}//End Of ViewModel

//in the ViewController
// MARK: - String related
func generateTargetAnswersBasedOn(_ models: [VehicleModel]) -> [String]{
    return models.map{ model in
        generateFilteredString(model.modelName)
    }
}

func generateFilteredString(_ baseString: String) -> String {
    return baseString
            .uppercased()
            .filter{
                String($0).range(of: "[A-Z0-9]", options: .regularExpression) != nil
            }
}//
    
```
 
