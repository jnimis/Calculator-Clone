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
  var displayValue = Decimal.zero
  var hasActiveAction = false
  var digitShouldResetDisplay = false
  var showTrailingDecimal = false
  
  let PADDING : CGFloat = 8
  let ROW_PADDING : CGFloat = 8
  var CALC_FONT_SIZE : CGFloat = 90
  var TEXT_HEIGHT : CGFloat = 90
  var BUTTON_FONT_SIZE : CGFloat = 36
  var IMAGE_SIZE : CGFloat = 14
  
  let ORANGE_COLOR = UIColor.init(red: 1.0, green: 159/255, blue: 10/255, alpha: 1.0)
  let DARK_GRAY_COLOR = UIColor.init(red: 51 / 255, green: 51 / 255, blue: 51 / 255, alpha: 1.0)
  let LIGHT_GRAY_COLOR = UIColor.init(red: 166 / 255, green: 166 / 255, blue: 166 / 255, alpha: 1.0)
  let ANIMATION_DURATION = 0.3
  
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
    b.backgroundColor = ORANGE_COLOR
    b.tintColor = UIColor.white
  }
  
  func digitButton(_ digit : String) -> UIButton {
    let b = buttonWithText(text: digit)
    b.addTarget(self, action: Selector(("digitAction:")), for: .touchUpInside)
    self.view.addSubview(b)
    b.backgroundColor = DARK_GRAY_COLOR
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
    let buttonWidth : CGFloat = (screenWidth - (PADDING * 5)) / 4
    v.layer.cornerRadius = buttonWidth / 2
  }
  
  // MARK: main UI builders
  
  func buildCalculator() {
    
    // top row
    clearButton = buttonWithText(text: "AC")
    clearButton.addTarget(self, action: Selector(("clearAction:")), for: .touchUpInside)
    self.view.addSubview(clearButton)
    clearButton.backgroundColor = LIGHT_GRAY_COLOR
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
    signButton.backgroundColor = LIGHT_GRAY_COLOR
    signButton.tintColor = UIColor.black

    let pctButton = buttonWithImage(imageName: "percent")
    pctButton.addTarget(self, action: Selector(("percentAction:")), for: .touchUpInside)
    self.view.addSubview(pctButton)
    pctButton.backgroundColor = LIGHT_GRAY_COLOR
    pctButton.tintColor = UIColor.black

    divideButton = buttonWithImage(imageName: "divide")
    divideButton.addTarget(self, action: Selector(("divideAction:")), for: .touchUpInside)
    self.view.addSubview(divideButton)
    divideButton.backgroundColor = ORANGE_COLOR
    divideButton.tintColor = UIColor.white
    
    self.view.addConstraints(horizontalConstraint(views: [clearButton, signButton, pctButton, divideButton]))

    
    // second row
    let sevenButton = digitButton("7")
    let eightButton = digitButton("8")
    let nineButton = digitButton("9")
    
    multiplyButton = buttonWithImage(imageName: "multiply")
    multiplyButton.addTarget(self, action: Selector(("multiplyAction:")), for: .touchUpInside)
    self.view.addSubview(multiplyButton)
    multiplyButton.backgroundColor = ORANGE_COLOR
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
    subtractButton.backgroundColor = ORANGE_COLOR
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
  
  func getNumberFormatter() -> NumberFormatter {
    let nf = NumberFormatter()
    nf.usesGroupingSeparator = true
    nf.numberStyle = .decimal
    nf.maximumSignificantDigits = displayValue < 1 ? 8 : 9
    nf.maximumFractionDigits = 8
    if displayValue > 999999999 {
      nf.numberStyle = .scientific
      nf.exponentSymbol = "e"
      nf.maximumSignificantDigits = 6
    }
    return nf
  }
  
  func updateDisplay() {
    
    if displayValue == 0 {
      clearButton.setTitle("AC", for: .normal)
      return
    } else {
      clearButton.setTitle("C", for: .normal)
    }
    
    let nf = getNumberFormatter()
    let displayDouble = NSDecimalNumber.init(decimal: displayValue).doubleValue
    let valNumber = NSNumber.init(value: displayDouble)
    if var text = nf.string(from: valNumber) {
      if showTrailingDecimal {
        text = "\(text)."
      }
      textDisplay.text = text
    }
  }
  
  func updateDisplayOld() {
    
    if textDisplay.text == "0" || textDisplay.text == "-0" {
      clearButton.setTitle("AC", for: .normal)
      return
    } else {
      clearButton.setTitle("C", for: .normal)
    }
    
    var formattedText = "0"
    
    let nf = getNumberFormatter()
    
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
    if let t = textDisplay.text {
      return numberFromString(t)
    }
    return Decimal.zero
  }
  
  func numberFromString(_ t : String) -> Decimal {
    if let val = Decimal(string: t.replacingOccurrences(of: ",", with: "")) {
      displayValue = val
      return val
    }
    return Decimal.zero
  }
  
  func unselectActionButtonsExcept(_ selectedButton : UIButton?) {
    let actionButtons = [additionButton, subtractButton, multiplyButton, divideButton]
    for b in actionButtons {
      if b != selectedButton {
        animatedDeselect(b)
      }
    }
  }
  
  func animatedDeselect(_ button : UIButton) {
    guard let ti = TimeInterval.init(exactly: ANIMATION_DURATION) else {
      button.backgroundColor = ORANGE_COLOR
      button.tintColor = UIColor.white
      return
    }
    UIView.transition(with: button,
                      duration: ti,
                      options: .curveLinear,
                      animations: {
                        button.backgroundColor = self.ORANGE_COLOR
                        button.tintColor = UIColor.white
    }, completion: nil)
  }
  
  func animatedSelect(_ button : UIButton, isDigit : Bool) {
    let bgColor = isDigit ? DARK_GRAY_COLOR : UIColor.white
    if isDigit {
      button.backgroundColor = UIColor.gray
    }
    guard let ti = TimeInterval.init(exactly: ANIMATION_DURATION) else {
      button.backgroundColor = bgColor
      if !isDigit {
        button.tintColor = ORANGE_COLOR
      }
      return
    }
    UIView.transition(with: button,
                      duration: ti,
                      options: .curveLinear,
                      animations: {
                        button.backgroundColor = bgColor
                        if !isDigit {
                          button.tintColor = self.ORANGE_COLOR
                        }
    }, completion: nil)
  }
  
  // MARK: - actions
  
  @objc func equalsAction(_ sender : UIButton) {
    
    let secondValue = displayValue
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
      unselectActionButtonsExcept(nil)
      return
    }
    
    textDisplay.text = "\(result)"
    displayValue = result

    unselectActionButtonsExcept(nil)
    hasActiveAction = false
    pendingFunction = .None
    digitShouldResetDisplay = true
    
    updateDisplay()
  }
  
  @objc func digitAction(_ sender : UIButton) {
    
    guard let digit = sender.titleLabel?.text else {
      print("ERROR: no digit to add to text, in digitAction")
      return
    }
    
    // check for decimal point "digit"
    // convert current value to string
    var numString = "\(displayValue)"

    if digit == "." {
      // can't add a second decimal point
      if numString.contains(".") {
        return
      } else {
        showTrailingDecimal = true
        updateDisplay()
        return
      }
    }
    
    guard let v = Decimal.init(string: digit) else {
      print("ERROR: received digit that couldn't be parsed to decimal")
      return
    }
    
    // simplest case
    if digitShouldResetDisplay || displayValue == 0 {
      displayValue = v
      textDisplay.text = digit
    } else {
      // otherwise add the digit to the end
      if numString.contains(".") || showTrailingDecimal {
        if numString.length > 9 {
          return
        }
        numString = showTrailingDecimal ? "\(numString).\(digit)" : "\(numString)\(digit)"
        displayValue = numberFromString(numString)
        showTrailingDecimal = false
      } else {
        if numString.length > 8 {
          return
        }
        displayValue = (displayValue * 10) + v
      }
    }
    
    digitShouldResetDisplay = false
    updateDisplay()
    
  }
  
  @objc func digitActionOld(_ sender : UIButton) {
//    animatedSelect(sender, isDigit: true)   // this ended up blocking the UI - there must be another way to apply custom button animations...
    guard let digit = sender.titleLabel?.text else {
      print("OOPS no digit to add to text, in digitAction")
      return
    }
    if let t = textDisplay.text {
      if !digitShouldResetDisplay && t.replacingOccurrences(of: ",", with: "").replacingOccurrences(of: ".", with: "").length > 8 {
        return
      }
      if digitShouldResetDisplay || (t == "0" && digit != ".") {
        textDisplay.text = digit
        unselectActionButtonsExcept(nil)
      } else {
        textDisplay.text?.append(digit)
      }
    } else {
      // in case of nil text, replace with digit entered
      textDisplay.text = digit
    }
    digitShouldResetDisplay = false
    updateDisplay()
  }
  
  @objc func clearAction(_ sender : UIButton) {
    textDisplay.text = "0"
    displayValue = 0
    
    // all clear action
    if hasActiveAction && sender.title(for: .normal) == "AC" {
      unselectActionButtonsExcept(nil)
      hasActiveAction = false
      pendingFunction = .None
      firstValue = Decimal.zero
    } else if !hasActiveAction {
      clearButton.setTitle("AC", for: .normal)
    }
    
    digitShouldResetDisplay = false
  }
  
  @objc func changeSignAction(_ sender : UIButton) {
    displayValue = 0 - displayValue
    if let currentText = textDisplay.text {
      if currentText[0] == "-" {
        textDisplay.text = currentText.substring(fromIndex: 1)
      } else {
        textDisplay.text = "-\(currentText)"
      }
    }
  }
  
  @objc func percentAction(_ sender : UIButton) {
    displayValue = displayValue / 100
//    textDisplay.text = "\(numberNew)"
    updateDisplay()
  }
  
  @objc func divideAction(_ sender : UIButton) {
    animatedSelect(sender, isDigit: false)
    unselectActionButtonsExcept(sender)
    pendingFunction = .Divide
    firstValue = displayValue
    hasActiveAction = true
    digitShouldResetDisplay = true
  }
  
  @objc func multiplyAction(_ sender : UIButton) {
    animatedSelect(sender, isDigit: false)
    unselectActionButtonsExcept(sender)
    pendingFunction = .Multiply
    firstValue = displayValue
    hasActiveAction = true
    digitShouldResetDisplay = true
  }

  @objc func subtractAction(_ sender : UIButton) {
    animatedSelect(sender, isDigit: false)
    unselectActionButtonsExcept(sender)
    pendingFunction = .Subtract
    firstValue = displayValue
    hasActiveAction = true
    digitShouldResetDisplay = true
  }
  
  @objc func additionAction(_ sender : UIButton) {
    animatedSelect(sender, isDigit: false)
    unselectActionButtonsExcept(sender)
    pendingFunction = .Add
    firstValue = displayValue
    hasActiveAction = true
    digitShouldResetDisplay = true
  }

}

// https://stackoverflow.com/questions/24092884/get-nth-character-of-a-string-in-swift-programming-language/38215613#38215613
// why doesn't Apple make up their mind about substrings?!
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
