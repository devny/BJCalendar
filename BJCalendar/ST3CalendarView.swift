//
//  BJCalendarView.swift
//  DabangSwift
//
//  Created by ybj on 24/10/2018.
//  Copyright © 2018 young-soo park. All rights reserved.
//

import UIKit

private let kPanGestureThreshdoler: CGFloat = 100

@objc
protocol BJCalendarViewDeleagte : class {
    func calendar(calendar : BJCalendarView, currentShow range: [Date])
    func calendar(calendar : BJCalendarView, selectDate date: Date)
    func calendar(calendar: BJCalendarView, isMinMax min: Bool, max: Bool)
}

class BJCalendarView: UIView {
    
    let panGesture      : UIPanGestureRecognizer    = UIPanGestureRecognizer()
    
    var leftView        : BJCalendarWeekView               = BJCalendarWeekView()
    var middleView      : BJCalendarWeekView               = BJCalendarWeekView()
    var rightView       : BJCalendarWeekView               = BJCalendarWeekView()
    
    var selectedDate    : Date? = nil
    
    var todayDate       : Date = Date() { didSet { return self.reloadViews() }}
    var currentDate     : Date = Date() { didSet { return self.reloadViews() }}
    private var prevDate     : Date { return minDate >= currentDate.beforeWeek.startOfWeek ? minDate.startOfWeek : currentDate.beforeWeek.startOfWeek }
    private var nextDate     : Date { return maxDate <= currentDate.endOfWeek ? maxDate.startOfWeek : currentDate.nextWeek.startOfWeek }
    
    var minDate         : Date = Date().beforeWeek.beforeWeek
    var maxDate         : Date = Date().nextWeek.nextWeek
    
    var isMinDate       : Bool { return currentDate.startOfWeek == minDate.startOfWeek }
    var isMaxDate       : Bool { return currentDate.startOfWeek == maxDate.startOfWeek }

    @IBOutlet weak var delegate   : BJCalendarViewDeleagte?      = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.resetPosition()
    }
    
    func setupViews() {
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.sv(self.leftView)
        self.leftView.fillContainer()
        self.sv(self.middleView)
        self.middleView.fillContainer()
        self.sv(self.rightView)
        self.rightView.fillContainer()
        
        self.leftView.addTarget(self, action: #selector(BJCalendarView.valueChangedCalendarWeekView(sender:)), for: .valueChanged)
        self.middleView.addTarget(self, action: #selector(BJCalendarView.valueChangedCalendarWeekView(sender:)), for: .valueChanged)
        self.rightView.addTarget(self, action: #selector(BJCalendarView.valueChangedCalendarWeekView(sender:)), for: .valueChanged)
        
        self.leftView.clipsToBounds     = true
        self.middleView.clipsToBounds   = true
        self.rightView.clipsToBounds    = true
        
        self.panGesture.addTarget(self, action: #selector(BJCalendarView.panHandle(_:)))
        self.addGestureRecognizer(panGesture)
        self.panGesture.delegate = self
        self.resetPosition()
        self.reloadViews()
        self.selectedDate = self.currentDate
    }
    
    func resetPosition() {
        self.leftView.transform = transform.translatedBy(x: -self.leftView.frame.width, y: 0)
        self.middleView.transform = CGAffineTransform.identity
        self.rightView.transform = transform.translatedBy(x: self.rightView.frame.width, y: 0)
    }
    
    func setupCenterCalendarWeekView() {
        self.middleView.todayDate = self.todayDate
        self.middleView.date   = nil
        
        self.middleView.date = currentDate
        self.getCurrentDates()
    }
    
    func setupSideCalendarWeekViews() {
        self.leftView.todayDate = self.todayDate
        self.rightView.todayDate = self.todayDate

        self.leftView.date     = nil
        self.rightView.date    = nil
        
        self.leftView.date = prevDate
        self.rightView.date = nextDate
    }
    
    func reloadViews() {
        self.setupCenterCalendarWeekView()
        self.setupSideCalendarWeekViews()
        delegate?.calendar(calendar: self, isMinMax: isMinDate, max: isMaxDate)
    }
    
    func clearSideCalendarWeekViews() {
        self.leftView.date     = nil
        self.rightView.date    = nil
    }
    
    @objc func valueChangedCalendarWeekView(sender: Any?) {
        guard let weekView = sender as? BJCalendarWeekView else { return }
        guard weekView == self.middleView else { return }
        self.selectedDate = self.middleView.selectedDate
        guard let selectedDate = self.selectedDate else { return }
        weekView.calendarItemViews.forEach { $0.date.isEqualDate(date: selectedDate) ? $0.setupSelected(true) : $0.setupSelected(false) }
        delegate?.calendar(calendar: self, selectDate: selectedDate)
    }
    
    func setDateIsSelected(date: Date) {
        self.middleView.calendarItemViews.forEach { $0.date.isEqualDate(date: date) ? $0.setupSelected(true) : $0.setupSelected(false) }
    }
    
    func scrollToNext() {
        let duration = 0.3 * ( (frame.width + self.middleView.transform.tx) / frame.width )
        UIView.animate(withDuration: Double(duration), animations: { [weak self] in
            guard let self = self else { return }
            self.leftView.transform     = self.transform.translatedBy(x: -2 * self.leftView.frame.width, y: 0)
            self.middleView.transform   = self.transform.translatedBy(x: -self.middleView.frame.width, y: 0)
            self.rightView.transform    = CGAffineTransform.identity
        }, completion: { (_) in
            self.leftView.deselectDate()
            self.rightView.deselectDate()
            self.middleView.deselectDate()
            let leftView = self.leftView
            self.leftView = self.middleView
            self.middleView = self.rightView
            self.rightView = leftView
            self.currentDate = self.nextDate
            self.setupSideCalendarWeekViews()
            self.resetPosition()
        })
    }
    
    func scrollToPrev() {
        let duration = 0.3 * ( (frame.width + self.middleView.transform.tx) / frame.width )
        UIView.animate(withDuration: Double(duration), animations: { [weak self] in
            guard let self = self else { return }
            self.leftView.transform     = CGAffineTransform.identity
            self.middleView.transform   = self.transform.translatedBy(x: self.middleView.frame.width, y: 0)
            self.rightView.transform    = self.transform.translatedBy(x: 2 * self.leftView.frame.width, y: 0)
            }, completion: { (_) in
                self.leftView.deselectDate()
                self.rightView.deselectDate()
                self.middleView.deselectDate()
                let rightView = self.rightView
                self.rightView = self.middleView
                self.middleView = self.leftView
                self.leftView = rightView
                self.currentDate = self.prevDate
                self.setupSideCalendarWeekViews()
                self.resetPosition()
        })
    }
    
    func scrollToCurrent() {
        UIView.animate(withDuration: 0.3, animations: {
            self.resetPosition()
        })
    }
    
    @objc func panHandle(_ panGesture: UIPanGestureRecognizer) {
        let offset = panGesture.translation(in: panGesture.view)
        let velocity = panGesture.velocity(in: panGesture.view)
        if isMinDate, offset.x > 0 && velocity.x > 0 { return }
        if isMaxDate, offset.x < 0 && velocity.x < 0 { return }

        switch panGesture.state {
        case .changed:
            self.leftView.transform     = self.transform.translatedBy(x: -self.leftView.frame.width + offset.x, y: 0)
            self.middleView.transform   = self.transform.translatedBy(x: offset.x, y: 0)
            self.rightView.transform    = self.transform.translatedBy(x: self.rightView.frame.width + offset.x, y: 0)
        case .ended, .cancelled:
            if offset.x > 0 && velocity.x > 0 {
                self.scrollToPrev()
            } else if offset.x < 0 && velocity.x < 0 {
                self.scrollToNext()
            } else {
                self.scrollToCurrent()
            }
        default:
            break
        }
    }
    
    func selectDate(at date: Date) {
        self.currentDate = date
        self.middleView.selectedDate = date
        self.middleView.sendActions(for: .valueChanged)
    }
    
    func getCurrentDates() {
        delegate?.calendar(calendar: self, currentShow: middleView.dates)
    }
}

extension BJCalendarView: UIGestureRecognizerDelegate {
    override public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else { return false }
        let velocity = panGestureRecognizer.velocity(in: self)
        
        return abs(velocity.x) > kPanGestureThreshdoler
    }
}
