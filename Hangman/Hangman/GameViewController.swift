//
//  GameViewController.swift
//  Hangman
//
//  Created by Shawn D'Souza on 3/3/16.
//  Copyright © 2016 Shawn D'Souza. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var hangmanTracker: UIImageView!
    @IBOutlet weak var phraseDisplay: UILabel!
    @IBOutlet weak var guessedCharacters: UILabel!
    @IBOutlet weak var triesRemaining: UILabel!
    
    @IBOutlet weak var hangmanStateImage: UIImageView!
    
    let legalCharacters = [
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
        "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"
    ]
    
    let hangmanStates = [#imageLiteral(resourceName: "hangmanState1"), #imageLiteral(resourceName: "hangmanState2"), #imageLiteral(resourceName: "hangmanState3"), #imageLiteral(resourceName: "hangmanState4"), #imageLiteral(resourceName: "hangmanState5")]

    
    // Keep track of the user's guesses
    var userGuesses = [Character]()
    
    // Dictionary that keeps track of each character's index in the current character display.
    var phraseLetters = [Character : [Int]]()
    
    // Current characters that are on display
    var currentCharacters = [Character]()
    var answer = ""
    
    // Number of characters that need to be guessed correctly before a WIN
    var lettersRemaining = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let hangmanPhrases = HangmanPhrases()
        var phrase = hangmanPhrases.getRandomPhrase()
        answer = phrase!
        self.userGuesses.removeAll()
        self.phraseLetters.removeAll()
        self.currentCharacters.removeAll()
        triesRemaining.text = "5"
        triesRemaining.textColor = UIColor.black
        hangmanStateImage.image = hangmanStates[0]
        
        
        // Put all the letters in the phrase into an array
        if let characters = phrase?.characters {
            for i in 0..<Int(characters.count) {
                let charAtIndex = characters[characters.index(characters.startIndex, offsetBy: i)]
                
                if (charAtIndex == " ") {
                    currentCharacters.append(" ")
                    currentCharacters.append(" ")
                    continue
                }
                
                // Create array with all the characters
                currentCharacters.append("_")
                currentCharacters.append(" ")
                
                // Maps each character to their respective indices in the phrase
                if phraseLetters[charAtIndex] != nil {
                    phraseLetters[charAtIndex]!.append(i)
                } else {
                    phraseLetters[charAtIndex] = [i]
                }
            }
            lettersRemaining = phraseLetters.count
        }
        
        phraseDisplay.text = String(currentCharacters)
        guessedCharacters.text = ""
        print(phrase)
        
        // Initialize new hangman
        
        
    }
    
    // User is only allowed to input ONE alphabetic character
    @IBOutlet weak var userInput: UITextField!
    
    var limitLength = 1
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.length + range.location > (userInput.text?.characters.count)! {
            return false
        }
        
        let newLength = (userInput.text?.characters.count)! + string.characters.count - range.length
        return newLength <= limitLength
    }
    
    @IBAction func userGuessedLetter(_ sender: UIButton) {
        if let guess = userInput.text {
            
            // Only allow legal inputs, in this case alphabetic characters
            let inputChar = guess
            if (!legalCharacters.contains(inputChar) || inputChar == "") {
                let alert = UIAlertController(title: "Bad input!", message: "Please enter an alphabetic character (a-z)", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "I gotcha", style: UIAlertActionStyle.default))
                self.present(alert, animated: true, completion: nil)
                self.userInput.text = ""
                return
            }
            
            let ch = Character(guess.uppercased())
            
            // Already guessed the character
            if (userGuesses.contains(ch)) {
                userInput.text = ""
                return
            }
            userGuesses.append(ch)
            userGuesses.append(" ")
            guessedCharacters.text = String(userGuesses)
            
            // Guessed correctly
            if let indices = phraseLetters[ch] {
                for i in indices {
                    currentCharacters[2 * i] = ch
                }
                
                lettersRemaining -= 1

                // YAY YOU WON! Show user an alert, and then an option to play again. Clear the state of the game
                if (lettersRemaining == 0) {
                    let alert = UIAlertController(title: "feelsgoodman", message: "pepe lives! another day, another meme xD", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Play again!", style: UIAlertActionStyle.default) {
                        UIAlertAction in
                        self.viewDidLoad()
                    })
                    self.present(alert, animated: true, completion: nil)
                }
                
            // Guessed incorrectly
            } else {
                var num = Int(triesRemaining.text!)
                num! -= 1
                
                switch num! {
                case 4:
                    hangmanStateImage.image = hangmanStates[1]
                case 3:
                    hangmanStateImage.image = hangmanStates[2]
                case 2:
                    hangmanStateImage.image = hangmanStates[3]
                case 1:
                    hangmanStateImage.image = hangmanStates[4]
                default:
                    hangmanStateImage.image = hangmanStates[4]
                }
                
                // If triesRemaining is 0, then the game is lost
                if (num == 0) {
                    let alert = UIAlertController(title: "GG", message: "feelsbadman, you lost :( the answer was \(answer)", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "I was just getting warmed up, hmu", style: UIAlertActionStyle.default) {
                        UIAlertAction in
                        self.viewDidLoad()
                    })
                    self.present(alert, animated: true, completion: nil)
                }
                
                if (num! <= 2) {
                    triesRemaining.textColor = UIColor.red
                }
                triesRemaining.text = String(num!)
            }
            userInput.text = ""
            phraseDisplay.text = String(currentCharacters)
            
        }
    }

    @IBAction func restartGame(_ sender: Any) {
       
            let alert = UIAlertController(title: "smh", message: "come on bro, u can't give up so ez...", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "feelsbadman", style: UIAlertActionStyle.default) {
                UIAlertAction in
                self.viewDidLoad()
            })
            self.present(alert, animated: true, completion: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
