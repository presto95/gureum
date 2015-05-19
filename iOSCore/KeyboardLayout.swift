//
//  KeyboardLayout.swift
//  iOS
//
//  Created by Jeong YunWon on 2014. 6. 6..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

let MINIMAL_COUNT = 30

class KeyboardViewEventView: UIView {
    var touchingDate: NSDate = NSDate()
    var touchingCount: Int = 0
    var touchingTimer: NSTimer = NSTimer()
    var touchingButtons: NSArray = NSArray()

    //var untouchingTimer: NSTimer = NSTimer()

    var touchedButtons: NSMutableArray = NSMutableArray()
    func addButton(button: GRInputButton) {
        if !self.touchedButtons.containsObject(button) {
            self.touchedButtons.addObject(button)
        }
    }
//    var touchedSpots: [UIView] = {
//        var spots: [UIView] = []
//        for i in 0...10 {
//            let view = UIView(frame: CGRectMake(0, 0, 40, 40))
//            view.backgroundColor = UIColor.redColor()
//            view.layer.cornerRadius = 20
//            view.clipsToBounds = true
//            view.layer.borderWidth = 4
//            view.layer.borderColor = UIColor.blueColor().CGColor
//            view.hidden = true
//            spots.append(view)
//        }
//        return spots
//    }()

    var keyboardView: KeyboardView {
        get {
            return self.superview! as! KeyboardView
        }
    }

    func resetTouching() {
        self.stopTouching()
        //self.untouchingTimer.invalidate()
        self.touchingButtons = self.touchedButtons.copy() as! NSArray
        self.touchingTimer = NSTimer.scheduledTimerWithTimeInterval(0.014, target: self, selector: "checkTouchingTimer:", userInfo: nil, repeats: true)
    }

    func stopTouching() {
        self.touchingDate = NSDate()
        self.touchingCount = 0
        self.touchingTimer.invalidate()
    }

    func checkTouchingTimer(timer: NSTimer) {
        if self.touchedButtons.count != 1 {
            self.stopTouching()
            return
        }

        if !self.touchedButtons.isEqual(self.touchedButtons) {
            self.resetTouching()
            return
        }

        self.touchingCount += 1

        if self.touchingCount >= MINIMAL_COUNT && self.touchingCount % 10 == 0 || self.touchingCount >= MINIMAL_COUNT * 4 && self.touchingCount % 5 == 0 {
            let button = self.touchedButtons[0] as! GRInputButton
            button.sendActionsForControlEvents(.TouchUpInside)
        }
        //println("touching \(self.touchingCount)")
    }

//    func checkUntouchingTimer(timer: NSTimer) {
//        self.keyboardView.untouchButton.sendActionsForControlEvents(.TouchUpInside)
//    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        //println("touch began?")
        if touches.count == 1 {
            self.resetTouching()
        } else {
            self.stopTouching()
        }
        self.touchesMoved(touches, withEvent: event)
    }

    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        var buttons: [GRInputButton: Bool] = [:]
        var orphans: [GRInputButton] = []

        for touch in event.allTouches()! as! Set<UITouch> {
            let prevPoint = touch.previousLocationInView(self)
            let prevButton = self.keyboardView.layout.correspondingButtonForPoint(prevPoint, size: self.frame.size)
            let point = touch.locationInView(self)
            let button = self.keyboardView.layout.correspondingButtonForPoint(point, size: self.frame.size)
            if prevButton != button {
                buttons[prevButton] = nil
                prevButton.hideEffect()
                self.resetTouching()
                //println("--touch moved point: \(point) \(button.captionLabel.text)")
            } else {
                //println("--touch point: \(point) \(button.captionLabel.text)")
            }
            button.showEffect()
            buttons[button] = true
        }

        for raw in self.touchedButtons {
            let button = raw as! GRInputButton
            if buttons[button] == nil {
                button.hideEffect()
                orphans.append(button)
            }
        }
        
        for button in orphans {
            self.touchedButtons.removeObject(button)
        }
        for button in buttons.keys {
            self.addButton(button)
        }
//        for spot in self.touchedSpots {
//            spot.hidden = true
//        }
//        for (i, rawTouch) in enumerate(event.allTouches()!) {
//            let touch = rawTouch as UITouch
//            let point = touch.locationInView(self)
//            let spot = self.touchedSpots[i]
//            spot.center = point
//            spot.hidden = false
//            self.addSubview(spot)
//        }
    }

    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch in event.allTouches()! as! Set<UITouch> {
            if touch.phase != .Ended {
                continue
            }
            let point = touch.locationInView(self)
            var button = self.keyboardView.layout.correspondingButtonForPoint(point, size: self.frame.size)
            if !self.touchedButtons.containsObject(button) {
                let point = touch.previousLocationInView(self)
                button = self.keyboardView.layout.correspondingButtonForPoint(point, size: self.frame.size)
            }
            if self.touchedButtons.containsObject(button) {
                while self.touchedButtons.count > 0 {
                    let poppedButton = self.touchedButtons[0] as! GRInputButton
                    self.touchedButtons.removeObjectAtIndex(0)
                    if (self.touchingButtons.count != 1 || self.touchingCount < MINIMAL_COUNT) && poppedButton.enabled {
                        poppedButton.sendActionsForControlEvents(.TouchUpInside)
                    }
                    poppedButton.hideEffect()
                    //println("--touch ended: \(poppedButton.captionLabel.text)")
                    if button == poppedButton {
                        break
                    }
                }
            } else {
                //println("already popped? \(button.captionLabel.text)")
            }
        }

//        self.stopTouching()
//        if self.touchedButtons.count == 0 {
//            self.touchingTimer = NSTimer.scheduledTimerWithTimeInterval(0.36, target: self, selector: "checkUntouchingTimer:", userInfo: nil, repeats: false)
//        }
//
//        for spot in self.touchedSpots {
//            spot.hidden = true
//        }
    }

    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        for touch in event.allTouches()! as! Set<UITouch> {
            if touch.phase != .Cancelled {
                continue
            }
            let point = touch.locationInView(self)
            let button = self.keyboardView.layout.correspondingButtonForPoint(point, size: self.frame.size)
            button.hideEffect()
            //println("touch cancelled: \(button.captionLabel.text)")
        }

        self.stopTouching()
//        for spot in self.touchedSpots {
//            spot.hidden = true
//        }
    }
}

class KeyboardView: UIView {
    var layout: KeyboardLayout! = nil

    @IBOutlet var nextKeyboardButton: GRInputButton! = nil
    @IBOutlet var deleteButton: GRInputButton! = nil
    @IBOutlet var spaceButton: GRInputButton! = nil
    @IBOutlet var doneButton: GRInputButton! = nil

    @IBOutlet var toggleKeyboardButton: GRInputButton! = nil
    @IBOutlet var shiftButton: GRInputButton! = nil

    var URLButtons: [GRInputButton] {
        get { return [] }
    }

    var emailButtons: [GRInputButton] {
        get { return [] }
    }

    var twitterButtons: [GRInputButton] {
        get { return [] }
    }


    let errorButton = GRInputButton(frame: CGRectMake(-1000, -1000, 0, 0))
    let untouchButton = GRInputButton(frame: CGRectMake(-1000, -1000, 0, 0))

    func needsMargin() -> Bool {
        return true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.nextKeyboardButton = GRInputButton()
        self.nextKeyboardButton.captionLabel.text = "🌐"
        self.deleteButton = GRInputButton()
        self.deleteButton.captionLabel.text = "⌫"
        self.deleteButton.tag = 0x7f
        self.doneButton = GRInputButton()
        self.doneButton.tag = 13
        self.toggleKeyboardButton = GRInputButton()
        self.toggleKeyboardButton.captionLabel.text = "123"
        self.shiftButton = GRInputButton()
        self.shiftButton.captionLabel.text = "⬆︎"
        self.spaceButton = GRInputButton()
        self.spaceButton.captionLabel.text = "간격"
        self.spaceButton.tag = 32

    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clearColor()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundImageView.removeFromSuperview()
        self.insertSubview(self.backgroundImageView, atIndex: 0)
        self.foregroundImageView.removeFromSuperview()
        self.addSubview(self.foregroundImageView)
        self.foregroundEventView.removeFromSuperview()
        self.addSubview(self.foregroundEventView)
    }

    lazy var backgroundImageView: UIImageView = {
        let view = UIImageView(frame: self.bounds)
        view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        return view
    }()

    lazy var foregroundImageView: UIImageView = {
        let view = UIImageView(frame: self.bounds)
        view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        return view
    }()

    lazy var foregroundEventView: KeyboardViewEventView = {
        let view = KeyboardViewEventView(frame: self.bounds)
        view.multipleTouchEnabled = true
        view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        view.userInteractionEnabled = true
        return view
    }()
}

class NoKeyboardView: KeyboardView {
}

class KeyboardLayout: GRKeyboardLayoutHelperDelegate {
    enum ShiftState {
        case Off
        case On
        case Auto
    }

    var context: UnsafeMutablePointer<()> = nil
    var capitalizable: Bool {
        get { return false }
    }
    var togglable = true {
        didSet {
            self.view.toggleKeyboardButton.enabled = togglable
            self.view.toggleKeyboardButton.alpha = togglable ? 1.0 : 0.0
        }
    }
    var autounshift: Bool {
        get { return false }
    }
    var autocapitalized = false

    lazy var helper: GRKeyboardLayoutHelper = GRKeyboardLayoutHelper(delegate: self)

    lazy var view: KeyboardView = {
        let view = self.dynamicType.loadView()
        view.layout = self

        assert(view.deleteButton != nil)
        //view.nextKeyboardButton.addTarget(nil, action: "mode:", forControlEvents: .TouchUpInside)
        view.deleteButton.addTarget(nil, action: "inputDelete:", forControlEvents: .TouchUpInside)
        view.shiftButton.addTarget(nil, action: "shift:", forControlEvents: .TouchUpInside)
        view.doneButton.addTarget(nil, action: "done:", forControlEvents: .TouchUpInside)
        view.toggleKeyboardButton.addTarget(nil, action: "toggleLayout:", forControlEvents: .TouchUpInside)

        view.insertSubview(view.errorButton, atIndex: 0)
        view.insertSubview(view.untouchButton, atIndex: 0)
        view.errorButton.addTarget(nil, action: "error:", forControlEvents: .TouchUpInside)
        view.untouchButton.addTarget(nil, action: "untouch:", forControlEvents: .TouchUpInside)

        self.context = self.dynamicType.loadContext()

        return view
    }()

    var shift: ShiftState {
        get {
            switch (self.view.shiftButton.selected, self.autocapitalized) {
            case (true, true): return .Auto
            case (true, false): return .On
            default: return .Off
            }
        }
        set {
            self.view.shiftButton.selected = newValue != .Off
            self.autocapitalized = newValue == .Auto
            self.helper.updateCaptionLabel()
        }
    }

    class func loadView() -> KeyboardView {
        assert(false)
        return KeyboardView()
    }

    class func loadContext() -> UnsafeMutablePointer<()> {
        assert(false)
        return nil
    }

    init() {
        let view = self.view
        self.helper.createButtonsInView(view)
    }

    func transitionViewToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator!) {
        var rect = self.view.bounds
        rect.size = size
        self.helper.layoutButtonsInRect(rect)
    }

    func correspondingButtonForPoint(point: CGPoint, size: CGSize) -> GRInputButton {
        var newPoint = point
        if point.x < 0 {
            newPoint.x = 0
        }
        if point.x >= self.view.frame.size.width {
            newPoint.x = self.view.frame.size.width - 1
        }
        if point.y < 0 {
            newPoint.y = 0
        }
        if point.y >= self.view.frame.size.height {
            newPoint.y = self.view.frame.size.height - 1
        }
        for view in self.view.subviews {
            if !(view is GRInputButton) {
                continue
            }
            let button = view as! GRInputButton
            if button.alpha == 0.0 {
                continue
            }
            if CGRectContainsPoint(button.frame, newPoint) {
                return button
            }
        }

        self.view.errorButton.tag = Int(newPoint.x) * 10000 + Int(newPoint.y)
        return self.view.errorButton
    }

    func layoutWillLoadForHelper(helper: GRKeyboardLayoutHelper) {
        assert(false)
    }

    func layoutDidLoadForHelper(helper: GRKeyboardLayoutHelper) {
        assert(false)
    }

    func layoutWillLayoutForHelper(helper: GRKeyboardLayoutHelper, forRect: CGRect) {
        assert(false)
    }

    func layoutDidLayoutForHelper(helper: GRKeyboardLayoutHelper, forRect: CGRect) {
        assert(false)
    }

    func insetsForHelper(helper: GRKeyboardLayoutHelper) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }

    func numberOfRowsForHelper(helper: GRKeyboardLayoutHelper) -> Int {
        assert(false)
        return 0
    }

    func helper(helper: GRKeyboardLayoutHelper, numberOfColumnsInRow row: Int) -> Int {
        assert(false)
        return 0
    }

    func helper(helper: GRKeyboardLayoutHelper, heightOfRow: Int, forSize: CGSize) -> CGFloat {
        assert(false)
        return 0
    }

    func helper(helper: GRKeyboardLayoutHelper, columnWidthInRow: Int, forSize: CGSize) -> CGFloat {
        assert(false)
        return 0
    }

    func helper(helper: GRKeyboardLayoutHelper, leftButtonsForRow row: Int) -> Array<UIButton> {
        assert(false)
        return []
    }

    func helper(helper: GRKeyboardLayoutHelper, rightButtonsForRow row: Int) -> Array<UIButton> {
        assert(false)
        return []
    }

    func helper(helper: GRKeyboardLayoutHelper, buttonForPosition position: GRKeyboardLayoutHelper.Position) -> GRInputButton {
        assert(false)
        return GRInputButton()
    }

    func helper(helper: GRKeyboardLayoutHelper, titleForPosition position: GRKeyboardLayoutHelper.Position) -> String {
        assert(false)
        return ""
    }

    func themeForHelper(helper: GRKeyboardLayoutHelper) -> Theme {
        if let inputViewController = globalInputViewController {
            return inputViewController.inputMethodView.theme
        } else {
            return PreferencedTheme()
        }
    }

    func adjustTraits(traits: UITextInputTraits) {
        //
    }
}

class NoKeyboardLayout: KeyboardLayout {

    override class func loadView() -> KeyboardView {
        let view = KeyboardView(frame: CGRectMake(0, 0, 320, 216))

        view.nextKeyboardButton = GRInputButton()
        view.deleteButton = GRInputButton()
        view.doneButton = GRInputButton()
        view.toggleKeyboardButton = GRInputButton()
        view.shiftButton = GRInputButton()

        for subview in [view.nextKeyboardButton, view.deleteButton, view.doneButton, view.toggleKeyboardButton, view.shiftButton] {
            view.addSubview(subview)
        }
        return view
    }

    override class func loadContext() -> UnsafeMutablePointer<()> {
        return nil
    }

    override func layoutWillLoadForHelper(helper: GRKeyboardLayoutHelper) {
    }

    override func layoutDidLoadForHelper(helper: GRKeyboardLayoutHelper) {
    }

    override func layoutWillLayoutForHelper(helper: GRKeyboardLayoutHelper, forRect: CGRect) {
    }

    override func layoutDidLayoutForHelper(helper: GRKeyboardLayoutHelper, forRect: CGRect) {
    }

    override func insetsForHelper(helper: GRKeyboardLayoutHelper) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }

    override func numberOfRowsForHelper(helper: GRKeyboardLayoutHelper) -> Int {
        return 1
    }

    override func helper(helper: GRKeyboardLayoutHelper, numberOfColumnsInRow row: Int) -> Int {
        return 1
    }

    override func helper(helper: GRKeyboardLayoutHelper, heightOfRow: Int, forSize: CGSize) -> CGFloat {
        return 216
    }

    override func helper(helper: GRKeyboardLayoutHelper, columnWidthInRow row: Int, forSize: CGSize) -> CGFloat {
        return 320
    }

    override func helper(helper: GRKeyboardLayoutHelper, leftButtonsForRow row: Int) -> Array<UIButton> {
        return []
    }

    override func helper(helper: GRKeyboardLayoutHelper, rightButtonsForRow row: Int) -> Array<UIButton> {
        return []
    }

    override func helper(helper: GRKeyboardLayoutHelper, buttonForPosition position: GRKeyboardLayoutHelper.Position) -> GRInputButton {
        let button = GRInputButton.buttonWithType(.System) as! GRInputButton
        button.tag = Int(UnicodeScalar(" ").value)
        button.sizeToFit()
        //button.backgroundColor = UIColor(white: 1.0 - 72.0/255.0, alpha: 1.0)
        return button
    }

    override func helper(helper: GRKeyboardLayoutHelper, titleForPosition position: GRKeyboardLayoutHelper.Position) -> String {
        return "ERROR: This is a bug."
    }
}

class KeyboardLayoutCollection {
    let layouts: [KeyboardLayout]
    var selectedLayoutIndex = 0
    var selectedLayout: KeyboardLayout {
        get {
            return self.layouts[self.selectedLayoutIndex]
        }
    }

    init(layouts: [KeyboardLayout]) {
        self.layouts = layouts
    }

    func selectLayoutIndex(index: Int) {
        if self.selectedLayoutIndex == index {
            return
        }
        let oldLayout = self.selectedLayout
        self.selectedLayoutIndex = index
        let newLayout = self.selectedLayout
        newLayout.view.frame = oldLayout.view.frame
        oldLayout.view.superview!.addSubview(newLayout.view)
        oldLayout.view.removeFromSuperview()
    }

    func switchLayout() {
        var layoutIndex = self.selectedLayoutIndex + 1
        if layoutIndex >= self.layouts.count {
            layoutIndex = 0
        }
        self.selectLayoutIndex(layoutIndex)
    }
}
