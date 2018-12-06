//
//  BJCalendarItemView.swift
//  DabangSwift
//
//  Created by ybj on 24/10/2018.
//  Copyright © 2018 young-soo park. All rights reserved.
//

import UIKit
import Stevia

class BJCalendarWeekView: UIControl {

    var stackView: UIStackView = UIStackView()
    var selectedDate: Date? = nil
    
    var todayDate: Date = Date()
    var date: Date? = nil { didSet { self.reloadView() } }
    var dates: [Date] {
        guard let date = self.date else { return [] }
        return date.getThisWeekDates()
    }
    var calendarItemViews : [BJCalendarItemView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    func setupViews() {
        self.sv(self.stackView)
        self.clipsToBounds = true
        self.stackView.fillContainer()
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.clipsToBounds = true
    }
    
    func reloadView() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        calendarItemViews = dates.map { (date) -> BJCalendarItemView in
            let itemView = BJCalendarItemView()
            itemView.date = date
            itemView.todayDate = self.todayDate
            itemView.width(28)
            itemView.height(70)
            itemView.addTarget(self, action: #selector(BJCalendarWeekView.touchUpInsideItemView(sender:)), for: .touchUpInside)
            return itemView
        }
        calendarItemViews.forEach { stackView.addArrangedSubview($0) }
    }
    
    func deselectDate() {
        self.selectedDate = nil
        self.sendActions(for: .valueChanged)
    }
    
    @objc func touchUpInsideItemView(sender: Any?) {
        guard let item = sender as? BJCalendarItemView else { return }
        self.selectedDate = item.date
        self.sendActions(for: .valueChanged)
    }
}

class BJCalendarItemView: UIControl {
    var dateView: UIView = UIView()
    var weekView: UIView = UIView()
    
    var weekLabel   : UILabel   = UILabel()
    var titleButtun : UIButton  = UIButton()
    var selectView  : UIView    = UIView()
    
    var todayDate: Date = Date()
    var date: Date = Date() { didSet { self.reloadView() } }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    func setupViews() {
        sv(weekView)
        sv(dateView)
        
        layout(
            15,
            |-0-weekView-0-|,
            1,
            |-0-dateView-0-|,
            10
        )
        
        setupWeekView()
        setupDateView()
    }
    
    func setupWeekView() {
        weekView.sv(weekLabel)
        weekLabel.fillContainer()
        weekLabel.textAlignment = .center
        weekLabel.textColor = UIColor.fromRed(170, green: 170, blue: 170, alpha: 1.0)
        weekLabel.font = UIFont.systemFont(ofSize: 13)
    }
    
    func setupDateView() {
        dateView.sv(selectView)
        dateView.sv(titleButtun)
        
        titleButtun.fillContainer()
        titleButtun.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        titleButtun.setTitleColor(UIColor.white, for: .selected)
        titleButtun.addTarget(self, action: #selector(BJCalendarItemView.touchupInsideSelectView(sender:)), for: .touchUpInside)
        
        selectView.fillContainer()
        selectView.cornerRadius = 14
        selectView.backgroundColor = UIColor.fromRed(102, green: 102, blue: 102, alpha: 1.0)
        selectView.isHidden = true
    }
    
    func reloadView() {
        weekLabel.text = date.toDate(format: "EEE")
        titleButtun.setTitle(date.toDate(format: "dd"), for: .normal)
        if date.isWeekend {
            titleButtun.setTitleColor(UIColor.fromRed(136, green: 136, blue: 136, alpha: 1.0), for: .normal)
            selectView.backgroundColor = UIColor.fromRed(102, green: 102, blue: 102, alpha: 1.0)
        } else if date.isEqualDate(date: self.todayDate) {
            titleButtun.setTitleColor(UIColor.fromRed(2, green: 108, blue: 255, alpha: 1.0), for: .normal)
            selectView.backgroundColor = UIColor.fromRed(2, green: 108, blue: 255, alpha: 1.0)
        } else {
            titleButtun.setTitleColor(UIColor.fromRed(34, green: 34, blue: 34, alpha: 1.0), for: .normal)
            selectView.backgroundColor = UIColor.fromRed(102, green: 102, blue: 102, alpha: 1.0)
        }
    }
    
    func setupSelected(_ selected: Bool) {
        titleButtun.isSelected = selected
        selectView.isHidden = !selected
    }
    
    @objc func touchupInsideSelectView(sender: Any?) {
        self.sendActions(for: .touchUpInside)
    }
}
