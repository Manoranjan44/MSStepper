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
    var stprPriceId = 0
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    /// Current value of the stepper. Default is 0.
    @objc @IBInspectable public var value: Double = 0 {
        didSet {
            value = min(maxValue, max(minValue, value))
            
            valueLabel.text = formattedValue
            
            if oldValue != value {
                sendActions(for: .valueChanged)
            }
            
            if value == minValue {
                leftButton.isUserInteractionEnabled = false
            } else {
                leftButton.isUserInteractionEnabled = true
            }
            
            if value == maxValue {
                rightButton.isUserInteractionEnabled = false
            } else {
                rightButton.isUserInteractionEnabled = true
            }
        }
    }
    
    private var formattedValue: String? {
        let isInteger = Decimal(value).exponent >= 0
        
        // If we have items, we will display them as steps
        if isInteger && stepValue == 1.0 && items.count > 0 {
            return items[Int(value)]
        }
        else {
            return formatter.string(from: NSNumber(value: value))
        }
    }
    
    /// Minimum value. Must be less than maxValue. Default is 0.
    @objc @IBInspectable public var minValue: Double = 1 {
        didSet {
            value = min(maxValue, max(minValue, value))
        }
    }
    
    /// Maximum value. Must be more than minValue. Default is 50.
    @objc @IBInspectable public var maxValue: Double = 50 {
        didSet {
            value = min(maxValue, max(minValue, value))
        }
    }
    
    /// Step value like UIStepper. Default is 1.
    @objc @IBInspectable public var stepValue: Double = 1 {
        didSet {
            setupNumberFormatter()
        }
    }
    
    /// If the value is integer, it is shown without floating point.
    @objc @IBInspectable public var showIntegerIfDoubleIsInteger: Bool = true {
        didSet {
            setupNumberFormatter()
        }
    }
    
    /// Text on the left button. Be sure that it fits in the button. Default is "−".
    @objc @IBInspectable public var leftButtonText: String = "−" {
        didSet {
            leftButton.setTitle(leftButtonText, for: .normal)
        }
    }
    
    /// Text on the right button. Be sure that it fits in the button. Default is "+".
    @objc @IBInspectable public var rightButtonText: String = "+" {
        didSet {
            rightButton.setTitle(rightButtonText, for: .normal)
        }
    }
    
    /// Text color of the buttons. Default is black.
    @objc @IBInspectable public var buttonsTextColor: UIColor = UIColor.black {
        didSet {
            leftButton.setTitleColor(buttonsTextColor, for: .normal)
            rightButton.setTitleColor(buttonsTextColor, for: .normal)
        }
    }
    
    /// Background color of the buttons. Default is lightGray.
    @objc @IBInspectable public var buttonsBackgroundColor: UIColor = UIColor.lightGray {
        didSet {
            leftButton.backgroundColor = buttonsBackgroundColor
            rightButton.backgroundColor = buttonsBackgroundColor
        }
    }
    
    /// Font of the buttons. Default is AvenirNext-Bold, 20.0 points in size.
    @objc public var buttonsFont = UIFont(name: "AvenirNext-Bold", size: 20.0)! {
        didSet {
            leftButton.titleLabel?.font = buttonsFont
            rightButton.titleLabel?.font = buttonsFont
        }
    }
    
    /// Text color of the middle label. Default is darkGray.
    @objc @IBInspectable public var labelTextColor: UIColor = UIColor.darkGray {
        didSet {
            valueLabel.textColor = labelTextColor
        }
    }
    
    /// Text color of the value label. Default is white.
    @objc @IBInspectable public var labelBackgroundColor: UIColor = UIColor.white {
        didSet {
            valueLabel.backgroundColor = labelBackgroundColor
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
    
    lazy var leftButton: UIButton = {
        let button = UIButton()
        button.setTitle(self.leftButtonText, for: .normal)
        button.setTitleColor(self.buttonsTextColor, for: .normal)
        button.backgroundColor = self.buttonsBackgroundColor
        button.titleLabel?.font = self.buttonsFont
        button.addTarget(self, action: #selector(leftButtonTouchDown(button:)), for: .touchDown)
        button.addTarget(self, action: #selector(decreaseStepValue(sender:)), for: .touchUpInside)
        return button
    }()
    
    lazy var rightButton: UIButton = {
        let button = UIButton()
        button.setTitle(self.rightButtonText, for: .normal)
        button.setTitleColor(self.buttonsTextColor, for: .normal)
        button.backgroundColor = self.buttonsBackgroundColor
        button.titleLabel?.font = self.buttonsFont
        button.addTarget(self, action: #selector(rightButtonTouchDown(button:)), for: .touchDown)
        button.addTarget(self, action: #selector(increaseStepValue(sender:)), for: .touchUpInside)
        return button
    }()
    
    lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = formattedValue
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
    
    @objc public var items : [String] = [] {
        didSet {
            valueLabel.text = formattedValue
        }
    }
    
    @objc required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    fileprivate func setup() {
        addSubview(leftButton)
        addSubview(rightButton)
        addSubview(valueLabel)
        
        backgroundColor = buttonsBackgroundColor
        clipsToBounds = true
        
        setupNumberFormatter()
    }
    
    func setupNumberFormatter() {
        let decValue = Decimal(stepValue)
        let digits = decValue.significantFractionalDecimalDigits
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = showIntegerIfDoubleIsInteger ? 0 : digits
        formatter.maximumFractionDigits = digits
    }
    
    public override func layoutSubviews() {
        print("labelWidthWeight == \(labelWidthWeight)")
        let buttonWidth = bounds.size.width * ((1 - labelWidthWeight) / 2)
        let labelWidth = bounds.size.width * labelWidthWeight
        
        leftButton.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: bounds.size.height)
        valueLabel.frame = CGRect(x: buttonWidth, y: 0, width: labelWidth, height: bounds.size.height)
        rightButton.frame = CGRect(x: labelWidth + buttonWidth, y: 0, width: buttonWidth, height: bounds.size.height)
    }
    
    func updateValue() {
        if stepperState == .ShouldIncrease {
            value += stepValue
        } else if stepperState == .ShouldDecrease {
            value -= stepValue
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func leftButtonTouchDown(button: UIButton) {
        
        valueLabel.isUserInteractionEnabled = false
        
        if value >= minValue {
            stepperState = .ShouldDecrease
        }
    }
    
    @objc func rightButtonTouchDown(button: UIButton) {
        
        valueLabel.isUserInteractionEnabled = false
        
        if value <= maxValue {
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
