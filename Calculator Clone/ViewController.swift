//
//  ViewController.swift
//  Calculator Clone
//
//  Created by John Nimis on 3/31/20.
//  Copyright © 2020 One Man Band Productions. All rights reserved.
//

import UIKit

enum MathFunction : Int {
  case None = 0,
  Add,
  Subtract,
  Multiply,
  Divide
}

class ViewController: UIViewController {

  var textDisplay = UITextField()
  var clearButton = UIButton()
  var additionButton = UIButton()
  var subtractButton = UIButton()
  var multiplyButton = UIButton()
  var divideButton = UIButton()
  
  var pendingFunction : MathFunction = .None
  var firstValue = Decimal.zero
  var hasActiveAction = false
  var isDisplayingCalculatedResult = false
  var digitShouldResetDisplay = false
  
  let PADDING : CGFloat = 8
  let ROW_PADDING : CGFloat = 8
  var CALC_FONT_SIZE : CGFloat = 90
  var TEXT_HEIGHT : CGFloat = 90
  var BUTTON_FONT_SIZE : CGFloat = 36
  var IMAGE_SIZE : CGFloat = 14
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
      
    self.view.backgroundColor = UIColor.black
    addTextDisplay()
  
    buildCalculator()
  }
  
  // MARK: - UI setup
  
  func addAndFormatFunctionButton(_ b : UIButton) {
    self.view.addSubview(b)
    b.backgroundColor = UIColor.orange
    b.tintColor = UIColor.white
  }
  
  func digitButton(_ digit : String) -> UIButton {
    let b = buttonWithText(text: digit)
    b.addTarget(self, action: Selector(("digitAction:")), for: .touchUpInside)
    self.view.addSubview(b)
    b.backgroundColor = UIColor.darkGray // 505050 == UIColor.init(red: 80/255, green: 80/255, blue: 80/255, alpha: 1.0)
    b.tintColor = UIColor.white
    return b
  }
  
  func buttonWithText(text : String) -> UIButton {
    let b = UIButton.init(type: .roundedRect)
    b.setTitle(text, for: .normal)
    b.titleLabel?.font = UIFont.systemFont(ofSize: BUTTON_FONT_SIZE)
    return b
  }
  
  func buttonWithImage(imageName : String) -> UIButton {
    let b = UIButton.init(type: .roundedRect)
    let img = UIImage(systemName: imageName)
    b.setImage(img, for: .normal)
    b.imageView?.contentMode = .scaleAspectFill
    return b
  }

  // MARK: shared layout constraint methods
  
  func addAspectRatioConstraint(_ b : UIView) {
    let aspectRatioConstraint = NSLayoutConstraint.init(item: b,
                                                   attribute: .width,
                                                   relatedBy: .equal,
                                                   toItem: b,
                                                   attribute: .height,
                                                   multiplier: 1,
                                                   constant: 0)
    b.addConstraint(aspectRatioConstraint)
  }
  
  func horizontalConstraint(views : [UIView]) -> [NSLayoutConstraint] {
    
    if views.count < 4 {
      // error condition
      print("OOPS - too many views passed to horizontal constraint method")
      
    } else if (views.count > 4) {
      // warn
      print("OOPS - not enough views passed to generic horizontal constraint method")
    }

    for v in views {
      
      roundCornersEtc(v)
      addAspectRatioConstraint(v)
      
      if v != views[0] {
        self.view.addConstraint(NSLayoutConstraint.init(item: v,
                                                        attribute: .width,
                                                        relatedBy: .equal,
                                                        toItem: views[0],
                                                        attribute: .width,
                                                        multiplier: 1,
                                                        constant: 0))
      }
    }

    let vDict = ["first" : views[0],
    "second" : views[1],
    "third" : views[2],
    "fourth" : views[3]
    ]
    
    let rowFormat = "H:|-[first]-[second]-[third]-[fourth]-|"
    let c = NSLayoutConstraint.constraints(withVisualFormat: rowFormat,
                                           options: [.alignAllCenterY],
                                          metrics: nil,
                                          views: vDict)
    return c
  }
  
  func roundCornersEtc(_ v : UIView) {
    v.translatesAutoresizingMaskIntoConstraints = false
    v.layer.masksToBounds = true
    let screenWidth = self.view.frame.width
    let buttonWidth = (screenWidth - (PADDING * 5)) / 4
    v.layer.cornerRadius = buttonWidth / 2
  }
  
  // MARK: main UI builders
  
  func buildCalculator() {
    
    // top row
    clearButton = buttonWithText(text: "AC")
    clearButton.addTarget(self, action: Selector(("clearAction:")), for: .touchUpInside)
    self.view.addSubview(clearButton)
    clearButton.backgroundColor = UIColor.gray
    clearButton.tintColor = UIColor.black
    self.view.addConstraint(NSLayoutConstraint.init(item: clearButton,
                                                    attribute: .top,
                                                    relatedBy: .equal,
                                                    toItem: self.textDisplay,
                                                    attribute: .bottom,
                                                    multiplier: 1,
                                                    constant: ROW_PADDING))
      
    let signButton = buttonWithImage(imageName: "plus.slash.minus")
    signButton.addTarget(self, action: Selector(("changeSignAction:")), for: .touchUpInside)
    self.view.addSubview(signButton)
    signButton.backgroundColor = UIColor.gray
    signButton.tintColor = UIColor.black

    let pctButton = buttonWithImage(imageName: "percent")
    pctButton.addTarget(self, action: Selector(("percentAction:")), for: .touchUpInside)
    self.view.addSubview(pctButton)
    pctButton.backgroundColor = UIColor.gray
    pctButton.tintColor = UIColor.black

    divideButton = buttonWithImage(imageName: "divide")
    divideButton.addTarget(self, action: Selector(("divideAction:")), for: .touchUpInside)
    self.view.addSubview(divideButton)
    divideButton.backgroundColor = UIColor.orange
    divideButton.tintColor = UIColor.white
    
    self.view.addConstraints(horizontalConstraint(views: [clearButton, signButton, pctButton, divideButton]))

    
    // second row
    let sevenButton = digitButton("7")
    let eightButton = digitButton("8")
    let nineButton = digitButton("9")
    
    multiplyButton = buttonWithImage(imageName: "multiply")
    multiplyButton.addTarget(self, action: Selector(("multiplyAction:")), for: .touchUpInside)
    self.view.addSubview(multiplyButton)
    multiplyButton.backgroundColor = UIColor.orange
    multiplyButton.tintColor = UIColor.white
    
    self.view.addConstraints(horizontalConstraint(views: [sevenButton, eightButton, nineButton, multiplyButton]))

    self.view.addConstraint(NSLayoutConstraint.init(item: sevenButton,
                                                    attribute: .top,
                                                    relatedBy: .equal,
                                                    toItem: clearButton,
                                                    attribute: .bottom,
                                                    multiplier: 1,
                                                    constant: ROW_PADDING))

    // third row
    let four = digitButton("4")
    let five = digitButton("5")
    let six = digitButton("6")

    subtractButton = buttonWithImage(imageName: "minus")
    subtractButton.addTarget(self, action: Selector(("subtractAction:")), for: .touchUpInside)
    self.view.addSubview(subtractButton)
    subtractButton.backgroundColor = UIColor.orange
    subtractButton.tintColor = UIColor.white
    
    self.view.addConstraints(horizontalConstraint(views: [four, five, six, subtractButton]))

    self.view.addConstraint(NSLayoutConstraint.init(item: four,
                                                attribute: .top,
                                                relatedBy: .equal,
                                                toItem: sevenButton,
                                                attribute: .bottom,
                                                multiplier: 1,
                                                constant: ROW_PADDING))
    
    // fourth row
    let one = digitButton("1")
    let two = digitButton("2")
    let three = digitButton("3")

    additionButton = buttonWithText(text: "+")
    additionButton.addTarget(self, action: Selector(("additionAction:")), for: .touchUpInside)
    addAndFormatFunctionButton(additionButton)
    
    self.view.addConstraints(horizontalConstraint(views: [one, two, three, additionButton]))

    self.view.addConstraint(NSLayoutConstraint.init(item: one,
                                                attribute: .top,
                                                relatedBy: .equal,
                                                toItem: four,
                                                attribute: .bottom,
                                                multiplier: 1,
                                                constant: 8))
    
    // bottom row

    let zero = digitButton("0")
    roundCornersEtc(zero)
    zero.contentHorizontalAlignment = .left
    let screenWidth = self.view.frame.width
    let buttonWidth = (screenWidth - (PADDING * 5)) / 4
    let leftInset = (buttonWidth / 2) - (BUTTON_FONT_SIZE * 0.35) // this is a "pretty close" estimate
                                                                  // otherwise, I think I have to wait for layout and calculate it
    zero.contentEdgeInsets = UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: 0);

    
    self.view.addConstraint(NSLayoutConstraint.init(item: zero,
                                                    attribute: .leading,
                                                    relatedBy: .equal,
                                                    toItem: one,
                                                    attribute: .leading,
                                                    multiplier: 1,
                                                    constant: 0))
    self.view.addConstraint(NSLayoutConstraint.init(item: zero,
                                                  attribute: .trailing,
                                                  relatedBy: .equal,
                                                  toItem: two,
                                                  attribute: .trailing,
                                                  multiplier: 1,
                                                  constant: 0))
    
    
    let decimalPoint = digitButton(".")
    addAspectRatioConstraint(decimalPoint)
    roundCornersEtc(decimalPoint)
    self.view.addConstraint(NSLayoutConstraint.init(item: decimalPoint,
                                                    attribute: .leading,
                                                    relatedBy: .equal,
                                                    toItem: three,
                                                    attribute: .leading,
                                                    multiplier: 1,
                                                    constant: 0))
    self.view.addConstraint(NSLayoutConstraint.init(item: decimalPoint,
                                                  attribute: .trailing,
                                                  relatedBy: .equal,
                                                  toItem: three,
                                                  attribute: .trailing,
                                                  multiplier: 1,
                                                  constant: 0))
    
    
    let equalButton = buttonWithImage(imageName: "equal")
    equalButton.addTarget(self, action: Selector(("equalsAction:")), for: .touchUpInside)
    addAndFormatFunctionButton(equalButton)
      roundCornersEtc(equalButton)
    addAspectRatioConstraint(equalButton)
    
    self.view.addConstraint(NSLayoutConstraint.init(item: equalButton,
                                                attribute: .leading,
                                                relatedBy: .equal,
                                                toItem: additionButton,
                                                attribute: .leading,
                                                multiplier: 1,
                                                constant: 0))
    self.view.addConstraint(NSLayoutConstraint.init(item: equalButton,
                                                attribute: .trailing,
                                                relatedBy: .equal,
                                                toItem: additionButton,
                                                attribute: .trailing,
                                                multiplier: 1,
                                                constant: 0))
    
      
    // vertical constraints
    self.view.addConstraint(NSLayoutConstraint.init(item: zero,
    attribute: .top,
    relatedBy: .equal,
    toItem: one,
    attribute: .bottom,
    multiplier: 1,
    constant: ROW_PADDING))
    
    self.view.addConstraint(NSLayoutConstraint.init(item: zero,
    attribute: .centerY,
    relatedBy: .equal,
    toItem: decimalPoint,
    attribute: .centerY,
    multiplier: 1,
    constant: 0))
    
    self.view.addConstraint(NSLayoutConstraint.init(item: zero,
    attribute: .centerY,
    relatedBy: .equal,
    toItem: equalButton,
    attribute: .centerY,
    multiplier: 1,
    constant: 0))
    
    
    self.view.addConstraint(NSLayoutConstraint.init(item: self.view!,
    attribute: .bottomMargin,
    relatedBy: .equal,
    toItem: zero,
    attribute: .bottom,
    multiplier: 1,
    constant: ROW_PADDING))
      
    self.view.addConstraint(NSLayoutConstraint.init(item: zero,
    attribute: .height,
    relatedBy: .equal,
    toItem: decimalPoint,
    attribute: .height,
    multiplier: 1,
    constant: 0))
      
  }
  
  func addTextDisplay() {
    textDisplay = UITextField(frame: CGRect.init(x: 0, y: 0, width: 200, height: 200)) // dummy rect, will be overriden by Auto Layout
    textDisplay.text = "0"
    textDisplay.backgroundColor = UIColor.black
    textDisplay.textColor = UIColor.white
    textDisplay.textAlignment = .right
    textDisplay.translatesAutoresizingMaskIntoConstraints = false
    textDisplay.font? = UIFont.systemFont(ofSize: CALC_FONT_SIZE, weight: .thin)
    textDisplay.adjustsFontSizeToFitWidth = true
    
    self.view.addSubview(textDisplay)
    self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[text]-|",
                                                            options: .alignAllBottom,
                                                            metrics: nil,
                                                            views: ["text" : textDisplay]))
    self.view.addConstraint(NSLayoutConstraint.init(item: textDisplay,
                                                    attribute: .height,
                                                    relatedBy: .equal,
                                                    toItem: nil,
                                                    attribute: .notAnAttribute,
                                                    multiplier: 1,
                                                    constant: TEXT_HEIGHT))
  }
  
  // MARK: - helpers
  
  func updateDisplay() {
    if textDisplay.text == "0" {
      clearButton.setTitle("AC", for: .normal)
    } else {
      clearButton.setTitle("C", for: .normal)
    }
    
    // adjust font size of text window
    var formattedText = "0"
    let nf = NumberFormatter()
    nf.usesGroupingSeparator = true
    nf.numberStyle = .decimal
    let endsInDecimal = textDisplay.text != nil && textDisplay.text!.suffix(1) == "."
    if let t = textDisplay.text, let num = nf.number(from: t.replacingOccurrences(of: ",", with: "")) {
      if let text = nf.string(from: num) {
        formattedText = endsInDecimal ? "\(text)." : text
      }
    } else {
      print("OOPS couldn't format number as text")
    }

    textDisplay.text = formattedText
  }
  
  func numberFromTextField() -> Decimal {
    if let t = textDisplay.text, let val = Decimal(string: t.replacingOccurrences(of: ",", with: "")) {
      return val
    }
    return Decimal.zero
  }
  
  func unselectActionButtonsExcept(_ selectedButton : UIButton?) {
    let actionButtons = [additionButton, subtractButton, multiplyButton, divideButton]
    for b in actionButtons {
      if b != selectedButton {
        b.backgroundColor = UIColor.orange
        b.tintColor = UIColor.white
      }
    }
  }
  
  // MARK: - actions
  
  @objc func equalsAction(_ sender : UIButton) {
    
    let secondValue = numberFromTextField()
    var result = Decimal.zero
    switch pendingFunction {
    case .Add:
      result = firstValue + secondValue
      break
    case .Subtract:
      result = firstValue - secondValue
      break
    case .Multiply:
      result = firstValue * secondValue
      break
    case .Divide:
      result = firstValue / secondValue
      break
    case .None:
      break
    }
    
    textDisplay.text = "\(result)"
    unselectActionButtonsExcept(nil)
    hasActiveAction = false
    pendingFunction = .None
    isDisplayingCalculatedResult = true
    
    updateDisplay()
  }
  
  @objc func digitAction(_ sender : UIButton) {
    guard let digit = sender.titleLabel?.text else {
      print("OOPS no digit to add to text, in digitAction")
      return
    }
    if let t = textDisplay.text {
      if t.replacingOccurrences(of: ",", with: "").length > 8 {
        return
      }
      if digitShouldResetDisplay || isDisplayingCalculatedResult || (t == "0" && digit != ".") {
        textDisplay.text = digit
      } else {
        textDisplay.text?.append(digit)
      }
    } else {
      // in case of nil text, replace with digit entered
      textDisplay.text = digit
    }
    digitShouldResetDisplay = false
    isDisplayingCalculatedResult = false
    updateDisplay()
  }
  
  @objc func clearAction(_ sender : UIButton) {
    textDisplay.text = "0"
    // all clear action
    if hasActiveAction && sender.title(for: .normal) == "AC" {
      unselectActionButtonsExcept(nil)
      hasActiveAction = false
      pendingFunction = .None
      firstValue = Decimal.zero
    }
    isDisplayingCalculatedResult = false
    updateDisplay()
  }
  
  @objc func changeSignAction(_ sender : UIButton) {
    if let currentText = textDisplay.text {
      if currentText[0] == "-" {
        textDisplay.text = currentText.substring(fromIndex: 1)
      } else {
        textDisplay.text = "-\(currentText)"
      }
    }
    updateDisplay()
  }
  
  @objc func percentAction(_ sender : UIButton) {
    let number = numberFromTextField()
    let numberNew = number / 100
    textDisplay.text = "\(numberNew)"
    updateDisplay()
  }
  
  @objc func divideAction(_ sender : UIButton) {
    divideButton.backgroundColor = UIColor.white
    divideButton.tintColor = UIColor.orange
    unselectActionButtonsExcept(sender)
    pendingFunction = .Divide
    firstValue = numberFromTextField()
    hasActiveAction = true
    digitShouldResetDisplay = true
  }
  
  @objc func multiplyAction(_ sender : UIButton) {
    multiplyButton.backgroundColor = UIColor.white
    multiplyButton.tintColor = UIColor.orange
    unselectActionButtonsExcept(sender)
    pendingFunction = .Multiply
    firstValue = numberFromTextField()
    hasActiveAction = true
    digitShouldResetDisplay = true
  }

  @objc func subtractAction(_ sender : UIButton) {
    subtractButton.backgroundColor = UIColor.white
    subtractButton.tintColor = UIColor.orange
    unselectActionButtonsExcept(sender)
    pendingFunction = .Subtract
    firstValue = numberFromTextField()
    hasActiveAction = true
    digitShouldResetDisplay = true
  }
  
  @objc func additionAction(_ sender : UIButton) {
    additionButton.backgroundColor = UIColor.white
    additionButton.tintColor = UIColor.orange
    unselectActionButtonsExcept(sender)
    pendingFunction = .Add
    firstValue = numberFromTextField()
    hasActiveAction = true
    digitShouldResetDisplay = true
  }

}

// https://stackoverflow.com/questions/24092884/get-nth-character-of-a-string-in-swift-programming-language/38215613#38215613
// why doesn't Apple make up their mind about strings?!
extension String {

    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}
