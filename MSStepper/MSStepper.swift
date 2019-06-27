//
//  MSStepper.swift
//  MSStepper
//
//  Created by blet-mac on 27/06/19.
//  Copyright © 2019 BLET. All rights reserved.
//

import UIKit

class MSStepper: UIControl {

    weak open var delegate: MSStepperDelegate? // default nil. weak reference
    var stepperId = 0
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    /// Current value of the stepper. Default is 0.
    @objc @IBInspectable public var currentValue: Int = 0 {
        didSet {
            currentValue = min(maxValue, max(minValue, currentValue))
            
            currentValueLabel.text = "\(currentValue)"
            
            if oldValue != currentValue {
                sendActions(for: .valueChanged)
            }
            
            if currentValue == minValue {
                decreaseButton.isUserInteractionEnabled = false
            } else {
                decreaseButton.isUserInteractionEnabled = true
            }
            
            if currentValue == maxValue {
                increaseButton.isUserInteractionEnabled = false
            } else {
                increaseButton.isUserInteractionEnabled = true
            }
        }
    }
    
    /// Minimum value. Must be less than maxValue. Default is 0.
    @objc @IBInspectable public var minValue: Int = 0 {
        didSet {
            currentValue = min(maxValue, max(minValue, currentValue))
        }
    }
    
    /// Maximum value. Must be more than minValue. Default is 10.
    @objc @IBInspectable public var maxValue: Int = 10 {
        didSet {
            currentValue = min(maxValue, max(minValue, currentValue))
        }
    }
    
    /// Step value like UIStepper. Default is 1.
    @objc @IBInspectable public var stepValue: Int = 1 {
        didSet {
        }
    }
    
    /// If the value is integer, it is shown without floating point.
    @objc @IBInspectable public var showIntegerIfDoubleIsInteger: Bool = true {
        didSet {
        }
    }
    
    /// Text on the left button. Be sure that it fits in the button. Default is "−".
    @objc @IBInspectable public var decreaseButtonText: String = "−" {
        didSet {
            decreaseButton.setTitle(decreaseButtonText, for: .normal)
        }
    }
    
    /// Text on the right button. Be sure that it fits in the button. Default is "+".
    @objc @IBInspectable public var increaseButtonText: String = "+" {
        didSet {
            increaseButton.setTitle(increaseButtonText, for: .normal)
        }
    }
    
    /// Text color of the buttons. Default is black.
    @objc @IBInspectable public var buttonsTextColor: UIColor = UIColor.black {
        didSet {
            decreaseButton.setTitleColor(buttonsTextColor, for: .normal)
            increaseButton.setTitleColor(buttonsTextColor, for: .normal)
        }
    }
    
    /// Background color of the buttons. Default is lightGray.
    @objc @IBInspectable public var buttonsBackgroundColor: UIColor = UIColor.lightGray {
        didSet {
            decreaseButton.backgroundColor = buttonsBackgroundColor
            increaseButton.backgroundColor = buttonsBackgroundColor
        }
    }
    
    /// Font of the buttons. Default is AvenirNext-Bold, 20.0 points in size.
    @objc public var buttonsFont = UIFont(name: "AvenirNext-Bold", size: 20.0)! {
        didSet {
            decreaseButton.titleLabel?.font = buttonsFont
            increaseButton.titleLabel?.font = buttonsFont
        }
    }
    
    /// Text color of the middle label. Default is darkGray.
    @objc @IBInspectable public var labelTextColor: UIColor = UIColor.darkGray {
        didSet {
            currentValueLabel.textColor = labelTextColor
        }
    }
    
    /// Text color of the value label. Default is white.
    @objc @IBInspectable public var labelBackgroundColor: UIColor = UIColor.white {
        didSet {
            currentValueLabel.backgroundColor = labelBackgroundColor
        }
    }
    
    /// Percentage of the middle label's width. Must be between 0 and 1. Default is 0.5.
    @objc @IBInspectable public var labelWidthWeight: CGFloat = 0.5 {
        didSet {
            labelWidthWeight = min(1, max(0, labelWidthWeight))
            setNeedsLayout()
        }
    }
    
    /// Formatter for displaying the current value
    let formatter = NumberFormatter()
    
    lazy var decreaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(self.decreaseButtonText, for: .normal)
        button.setTitleColor(self.buttonsTextColor, for: .normal)
        button.backgroundColor = self.buttonsBackgroundColor
        button.titleLabel?.font = self.buttonsFont
        button.addTarget(self, action: #selector(decreaseButtonTouchDown(button:)), for: .touchDown)
        button.addTarget(self, action: #selector(decreaseStepValue(sender:)), for: .touchUpInside)
        return button
    }()
    
    lazy var increaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(self.increaseButtonText, for: .normal)
        button.setTitleColor(self.buttonsTextColor, for: .normal)
        button.backgroundColor = self.buttonsBackgroundColor
        button.titleLabel?.font = self.buttonsFont
        button.addTarget(self, action: #selector(increaseButtonTouchDown(button:)), for: .touchDown)
        button.addTarget(self, action: #selector(increaseStepValue(sender:)), for: .touchUpInside)
        return button
    }()
    
    lazy var currentValueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "\(currentValue)"
        label.textColor = self.labelTextColor
        label.backgroundColor = self.labelBackgroundColor
        label.layer.masksToBounds = true
        return label
    }()
    
    
    enum StepperState {
        case Stable, ShouldIncrease, ShouldDecrease
    }
    var stepperState = StepperState.Stable {
        didSet {
            if stepperState != .Stable {
                updateValue()
            }
        }
    }
    
    @objc required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupComponent()
    }
    
    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        setupComponent()
    }
    
    fileprivate func setupComponent() {
        
        addSubview(decreaseButton)
        addSubview(increaseButton)
        addSubview(currentValueLabel)
        
        backgroundColor = buttonsBackgroundColor
        clipsToBounds = true
        
    }
  
    
    public override func layoutSubviews() {
        print("labelWidthWeight == \(labelWidthWeight)")
        let buttonWidth = bounds.size.width * ((1 - labelWidthWeight) / 2)
        let labelWidth = bounds.size.width * labelWidthWeight
        
        decreaseButton.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: bounds.size.height)
        currentValueLabel.frame = CGRect(x: buttonWidth, y: 0, width: labelWidth, height: bounds.size.height)
        increaseButton.frame = CGRect(x: labelWidth + buttonWidth, y: 0, width: buttonWidth, height: bounds.size.height)
    }
    
    func updateValue() {
        if stepperState == .ShouldIncrease {
            currentValue += stepValue
        } else if stepperState == .ShouldDecrease {
            currentValue -= stepValue
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func decreaseButtonTouchDown(button: UIButton) {
        
        currentValueLabel.isUserInteractionEnabled = false
        
        if currentValue >= minValue {
            stepperState = .ShouldDecrease
        }
    }
    
    @objc func increaseButtonTouchDown(button: UIButton) {
        
        currentValueLabel.isUserInteractionEnabled = false
        
        if currentValue <= maxValue {
            stepperState = .ShouldIncrease
        }
    }
    
    @objc func decreaseStepValue(sender: UIButton) {
        if self.delegate != nil
        {
            self.delegate?.didDecreaseStepValue(self)
        }
    }
    @objc func increaseStepValue(sender: UIButton) {
        if self.delegate != nil
        {
            self.delegate?.didIncreaseStepValue(self)
        }
    }
}

extension Decimal {
    var significantFractionalDecimalDigits: Int {
        return max(-exponent, 0)
    }
}

protocol MSStepperDelegate : NSObjectProtocol {
    func didIncreaseStepValue(_ stepper: MSStepper)
    func didDecreaseStepValue(_ stepper: MSStepper)
}
