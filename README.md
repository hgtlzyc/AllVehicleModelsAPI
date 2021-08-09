# Quiz App based on data from NHTSA API 
[Go To My Resume](https://github.com/hgtlzyc/Resume#quiz-app-based-on-data-from-nhtsa-api-github-repo)
<br />

![](https://github.com/hgtlzyc/AllVehicleModelsAPI/blob/7ff7611ec3cbc466874f06001e136fab7018f015/screenCapture.gif)
<br/>
- MVVM
- NHTSA (National Highway Traffic Safety Administration) API [Link](https://vpic.nhtsa.dot.gov/api/)
- URLSession
- Animation

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

//In The ViewController Extension
//MARK: -AnmationHelper
func animateStatusLabelBasedOn(_ isCorrect: Bool,
                               colorForCorrect: UIColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1),
                               colorForWrong:UIColor = #colorLiteral(red: 1, green: 0.2897925377, blue: 0.2962183654, alpha: 0.6548947704),
                               duration: Double = 0.5) {
    let baseColor = statusLabel.layer.backgroundColor
    var tempColor: UIColor
    var affineTransform: CGAffineTransform?

    switch isCorrect {
    case true:
        tempColor = colorForCorrect
        affineTransform = CGAffineTransform(scaleX: 1.05, y: 1.05)

    case false:
        tempColor = colorForWrong
        affineTransform = nil
        ///extension in CALayer, keyframeAnimation using keypath
        statusLabel.layer.shake(withDuration: duration)
    }

    UIView.animate(withDuration: duration) {
        UIView.modifyAnimations(withRepeatCount: 1, autoreverses: true) {
            self.statusLabel.layer.backgroundColor = tempColor.cgColor
            if let trans = affineTransform {
                self.statusLabel.transform = trans
            }
        }

    } completion: { [weak self] _ in
        self?.statusLabel.layer.backgroundColor = baseColor
        self?.statusLabel.transform = CGAffineTransform.identity
        self?.statusLabel.layer.removeAllAnimations()
    }

}//End Of animateStatusLabel
    
```
 
