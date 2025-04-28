//
//  HorizontalScrollableBarChartView.swift
//  ZhongYangQiXiangTai
//
//  Created by 王杰 on 2025/4/27.
//

import UIKit

class HorizontalScrollableBarChartView: UIView {
    
    var dataList: [HorizontalBarData] = [] {
        didSet {
            chartView.dataList = dataList
            chartView.snp.updateConstraints { make in
                make.height.equalTo(40.0 * CGFloat(dataList.count))
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    func setupUI() {
        backgroundColor = .white
        
        addSubview(myScrollView)
        myScrollView.addSubview(contentView)
        contentView.addSubview(chartView)

        let bottomSpace: CGFloat = TabBarHeight
        myScrollView.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(-bottomSpace)
        }
        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(myScrollView.snp.top)
            make.left.right.bottom.equalTo(myScrollView)
            make.width.equalTo(SCREEN_WIDTH)
        }
        
        chartView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(0)
            make.bottom.equalTo(0)
        }
    }
    
    // MARK: 懒加载
    lazy var myScrollView: UIScrollView = {
        let scrollV = UIScrollView()
        scrollV.contentInsetAdjustmentBehavior = .never
        scrollV.alwaysBounceVertical = true
        scrollV.backgroundColor = .clear
        return scrollV
    }()
    
    lazy var contentView: UIView = {
        let customV = UIView()
        customV.backgroundColor = .white
        return customV
    }()
    
    let chartView = HorizontalBarChartView()

    
}
