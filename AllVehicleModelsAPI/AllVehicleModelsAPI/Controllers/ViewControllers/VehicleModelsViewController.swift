//
//  VehicleModelsViewController.swift
//  AllVehicleModelsAPI
//
//  Created by lijia xu on 8/4/21.
//

import UIKit

class VehicleModelsViewController: UIViewController {
    enum ModelsDisplayType {
        case userCorrectAnswers
        case allTargetAnswers
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var answerInputTF: UITextField!
    @IBOutlet weak var showAllButton: UIButton!
    @IBOutlet weak var nextQuestionButton: UIButton!
    @IBOutlet weak var checkUserAnswerButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    let viewModel = VehicleModelsViewModel()
    
    var models: [(String,Bool)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        answerInputTF.delegate = self
        
        setupInitialViews()
        loadNewViewModel()
        
        //Dismiss kb
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
        
    }//End Of ViewDidLoad
    
    
    // MARK: - Initial Setups
    
    func setupInitialViews() {
        tableView.layer.cornerRadius = 10
        questionLabel.text = ""
        statusLabel.text = ""
        checkUserAnswerButton.layer.cornerRadius = 15
        showAllButton.layer.cornerRadius = 15
        nextQuestionButton.layer.cornerRadius = 15
    }

    
    // MARK: - IBActions
    @IBAction func checkUserAnswerTapped(_ sender: UIButton) {
        guard let text = answerInputTF.text, !text.isEmpty else { return }
        
        putTextFieldTextInViewModel(text)
    }
 
    @IBAction func showAllButonTapped(_ sender: Any) {
        models = viewModel.sortedAllCorrectAndWrongAnswers
        pullDataFromViewModel(.allTargetAnswers)
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        resetTableViewEmpty()
        loadNewViewModel()
    }//
    
    
}//End Of class

// MARK: - TextField Related
extension VehicleModelsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, !text.isEmpty else { return true }
        
        putTextFieldTextInViewModel(text)
        
        return true
    }
    
}//End Of Extension


// MARK: - Table View Related
extension VehicleModelsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "modelCell", for: indexPath)
        
        cell.textLabel?.text = models[indexPath.row].0
        cell.detailTextLabel?.text =  models[indexPath.row].1 ? "✅" : "😱"
        
        let backgroundColor = models[indexPath.row].1 ? #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1) : #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
        
        cell.contentView.backgroundColor = backgroundColor
                
        return cell
    }
        
    
}

// MARK: - Helper Functions
extension VehicleModelsViewController {
    
    ///there are 9746 makes available from the NHTSA, only generate random ids based on the well known brands
    func generateRandomIDInRange() -> Int{
        let targetSet: Set<Int> = [440,441,442,444,448,449,452,460,469,474,475,480,483,485,515,523,582,584,]
        guard let id = targetSet.randomElement() else { return 1 }
        return id
        
    }
    
    // MARK: - Load New ViewModel Related
    func loadNewViewModel(){
        viewModel.resetForNextQuestion()
        VehicleModelsControler.cancelAllPendingTasks()
        
        let nextID = generateRandomIDInRange()
        VehicleModelsControler.fetchModelsFor(nextID) { [weak self] result in
            switch result {
            case .success(let models):
                DispatchQueue.main.async {
                    self?.viewModel.makeName = models.first?.makeName
                    let targetAnswers = self?.generateTargetAnswersBasedOn(models)
                    self?.viewModel.setCorrectAnswers(targetAnswers ?? [""])
                    self?.pullDataFromViewModel(.userCorrectAnswers)
                }
                
            case .failure(let err):
                self?.presentAlert(title: "Error", message: err.localizedDescription)
            }
            
        }//
        
    }//End Of function
    
    //TextField Related
    func putTextFieldTextInViewModel(_ text: String) {
        let userAnswerText = generateFilteredString(text)
        viewModel.newUserAnswered(userAnswerText)
        pullDataFromViewModel(.userCorrectAnswers)
        
        answerInputTF.text = ""
        answerInputTF.resignFirstResponder()
    }
    
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
    }
    
    
    // MARK: - VM helpers
    func resetTableViewEmpty(){
        models = []
        tableView.reloadData()
    }
    
    func pullDataFromViewModel(_ type: ModelsDisplayType) {
        switch type {
        case .allTargetAnswers:
            models = viewModel.sortedAllCorrectAndWrongAnswers
        case .userCorrectAnswers:
            models = viewModel.sortedCurrentlyCorrectAnswers
        }
        questionLabel.text = (viewModel.makeName ?? "") + " models?"
        statusLabel.text = viewModel.statusString
        tableView.reloadData()
    }
    
    //KeyBoard Related
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        answerInputTF.resignFirstResponder()
    }

    @objc func kbWillShow(notifaction: NSNotification) {
        guard let kbSize = (notifaction.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              self.view.frame.origin.y == 0 else { return }
        
        self.view.frame.origin.y -= (kbSize.height - 50)
    }
    
    @objc func kbWillHide(notifaction: NSNotification) {
        guard self.view.frame.origin.y != 0 else { return }
        self.view.frame.origin.y = 0
    }
}
