//
//  ContentView.swift
//  WordScramlbe
//
//  Created by Andrey Matviets on 05.12.2022.
//

import SwiftUI

struct ContentView: View {
    @State private var  usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var scoreAmountOfWord = 0
    @State private var scoreAmountOfLetters = 0
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var animationAmount = 1.0
    @State private var animation3DEffect = 0.0
    
    var body: some View {
        NavigationView {
            List {
                VStack (spacing: 30){
                    Section {
                        
                        TextField("Enter your word", text: $newWord)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.default)
                            .textFieldStyle(.roundedBorder)
                            .background(.primary)
                            .foregroundColor(.secondary)
                        
                        
                    }
                    
                    HStack (spacing: 100){
                        VStack (alignment: .center, spacing: 10) {
                            Text("Words")
                            Text("\(scoreAmountOfWord)")
                        }
                        
                        VStack (alignment: .center, spacing: 10){
                            Text("Characters")
                            Text("\(scoreAmountOfLetters)")
                        }
                    }
                    
                    Button("Restart") {
                        startGame()
                        withAnimation(.interpolatingSpring(stiffness: 3, damping: 5)) {
                            animation3DEffect += 360
                        }
                    }
                        .padding(30)
                        .background(.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .rotation3DEffect(.degrees(animation3DEffect), axis: (x: 0, y: 1, z: 0.25))
                        .overlay (
                        Circle()
                            .stroke(.blue)
                            .scaleEffect(animationAmount)
                            .opacity(2 - animationAmount)
                            .animation(
                                .easeInOut(duration: 1)
                                .delay(60)
                                .repeatForever(autoreverses: false),
                                value: animationAmount
                        )
                        )
                        .onAppear {
                            animationAmount = 2
                        }
                    
                }
                           
              
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("Ok", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .safeAreaInset(edge: .bottom) {
                HStack (spacing: 100){
                    VStack (alignment: .center, spacing: 10) {
                        Text("Words")
                        Text("\(scoreAmountOfWord)")
                    }
                
                    VStack (alignment: .center, spacing: 10){
                        Text("Characters")
                        Text("\(scoreAmountOfLetters)")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue)
                .foregroundColor(.white)
                .font(.title)

            }
        }
    }
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 3 else {
            wordError(title: "3 letters words are not allowed", message: "Use the longer one")
            return
        }
        
        guard answer != rootWord else {
            wordError(title: "Your answer is equal to root word", message: "Don't cheat")
            
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "Use the real one")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
        scoreAmountOfWord += 1
        scoreAmountOfLetters += answer.count
    }
    
    func startGame () {
        usedWords = [String]()
        // could be also used: useWords.removeAll()
        newWord = ""
        scoreAmountOfWord = 0
        scoreAmountOfLetters = 0
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: ".txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "impossible"
                
              
                
                return
            }
        }
        fatalError("Couldn't load start.txt from bundle")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

/* checking for misspelling
func test() {
    let word = "swift"
    let checker = UITextChecker()
    let range = NSRange(location: 0, length: word.utf16.count)
    
    let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
    
    let allGood = misspelledRange.location == NSNotFound
}
 */

/* example of code to work with strings
func test() {
    let input = "a b c"
    let letters = input.components(separatedBy: " ")
    let letter = letters.randomElement()
    
    // to remove special characters for example whitespaces we could use
    let trimmed = letter?.trimmingCharacters(in: .whitespacesAndNewlines)
}
*/


/* example of code to load a txt file
func loadFile() {
    if let fileURL = Bundle.main.url(forResource: "start", withExtension: ".txt") {
        if let fileContents = try? String(contentsOf: fileURL) {
            // we loaded the file into the string
    
        }
    }
 }
 */
