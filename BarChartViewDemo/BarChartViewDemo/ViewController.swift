//
//  ViewController.swift
//  BarChartViewDemo
//
//  Created by 王杰 on 2025/4/28.
//

let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height

let STATUSBAR_HEIGHT = UIApplication.shared.statusBarFrame.height



/*
 func getStatusBarHeight() -> CGFloat {
     if #available(iOS 13.0, *) {
         let windowScene = UIApplication.shared.connectedScenes
             .filter { $0.activationState == .foregroundActive }
             .first as? UIWindowScene
         return windowScene?.statusBarManager?.statusBarFrame.height ?? 0
     } else {
         // 由于只兼容 iOS 13 及以上，这段 else 分支实际上不会执行
         return 0
     }
 }

 let statusBarHeight = getStatusBarHeight()
 */


let NAVIGATIONBAR_HEIGHT: CGFloat = 44
let IPHONEX_SAFE_HEIGHT: CGFloat = 34
// navigation高度
let NaviAndStatusHight: CGFloat = STATUSBAR_HEIGHT + NAVIGATIONBAR_HEIGHT
// tabbar高度
let TabBarHeight: CGFloat = STATUSBAR_HEIGHT > 20 ? 83: 49
// 是否是iphone x的屏幕类型
let iPhoneX = ((NaviAndStatusHight > 64) ? true : false)
// 底部安全高度
let BottomSafeHight: CGFloat = ((NaviAndStatusHight > 64) ? 34 : 0)


import UIKit
import SnapKit

class ViewController: UIViewController {

    private var barChartView = HorizontalScrollableBarChartView()
    private var sliders: [UISlider] = []
    private var valueLabels: [UILabel] = []

    /// 所有布局属性的默认值
    private let defaultValues: [CGFloat] = [
        10,  // leftPadding
        0,   // rightPadding
        16,  // topPadding
        60,  // titleWidth
        5,   // titleToTickSpacing
        6,   // tickLength
        0,   // tickToAxisSpacing
        0,   // axisToBarSpacing
        16,  // barHeight
        33,  // itemSpacing
        50,  // valueWidth
        4,   // valueToBarSpacing
        0.5  // tickThickness
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        setupBarChart()
        setupControlPanel()
    }

    // MARK: - 布局柱状图
    private func setupBarChart() {
        barChartView.dataList = generateFakeData()
        view.addSubview(barChartView)
        barChartView.snp.makeConstraints { make in
            make.top.equalTo(NaviAndStatusHight)
            make.left.right.equalToSuperview()
            make.height.equalTo(300)
        }
    }

    // MARK: - 布局控制面板
    private func setupControlPanel() {
        let controlPanel = UIScrollView()
        view.addSubview(controlPanel)
        controlPanel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-TabBarHeight)
            make.height.equalTo(250)
        }

        let contentView = UIView()
        controlPanel.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        let sliderConfigs: [(String, CGFloat, CGFloat, CGFloat)] = [
            ("左边距 leftPadding", 0, 50, 10),
            ("右边距 rightPadding", 0, 50, 0),
            ("顶部间距 topPadding", 0, 50, 16),
            ("标题宽度 titleWidth", 0, 150, 60),
            ("标题到刻度线 titleToTickSpacing", 0, 30, 5),
            ("刻度线长度 tickLength", 0, 20, 6),
            ("刻度到基线 tickToAxisSpacing", 0, 20, 0),
            ("基线到柱子 axisToBarSpacing", 0, 20, 0),
            ("柱子高度 barHeight", 0, 50, 16),
            ("柱子间距 itemSpacing", 20, 80, 33),
            ("数值宽度 valueWidth", 20, 100, 50),
            ("柱子到数值间距 valueToBarSpacing", 0, 20, 4),
            ("刻度线线宽 tickThickness", 0, 5, 0.5),
        ]

        var lastBottom: ConstraintItem = contentView.snp.top
        for (index, config) in sliderConfigs.enumerated() {
            let (title, minValue, maxValue, defaultValue) = config

            let label = UILabel()
            label.text = title
            label.font = .systemFont(ofSize: 12)
            contentView.addSubview(label)

            let slider = UISlider()
            slider.minimumValue = Float(minValue)
            slider.maximumValue = Float(maxValue)
            slider.value = Float(defaultValue)
            slider.tag = index
            contentView.addSubview(slider)
            sliders.append(slider)

            let valueLabel = UILabel()
            valueLabel.text = "\(Int(slider.value))"
            valueLabel.font = .systemFont(ofSize: 12)
            valueLabel.textColor = .black
            valueLabel.textAlignment = .right
            contentView.addSubview(valueLabel)
            valueLabels.append(valueLabel)

            label.snp.makeConstraints { make in
                make.top.equalTo(lastBottom).offset(index == 0 ? 10 : 20)
                make.left.equalToSuperview().offset(16)
                make.width.equalTo(150)
            }

            valueLabel.snp.makeConstraints { make in
                make.centerY.equalTo(label)
                make.right.equalToSuperview().offset(-16)
                make.width.equalTo(40)
            }

            slider.snp.makeConstraints { make in
                make.centerY.equalTo(label)
                make.left.equalTo(label.snp.right).offset(10)
                make.right.equalTo(valueLabel.snp.left).offset(-10)
            }

            lastBottom = label.snp.bottom

            slider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)

            // 初始同步
            updateChartViewProperty(for: index, value: CGFloat(defaultValue))
        }

        // —— 新增重置按钮 ——
        let resetButton = UIButton(type: .system)
        resetButton.setTitle("重置", for: .normal)
        resetButton.titleLabel?.font = .systemFont(ofSize: 14)
        contentView.addSubview(resetButton)

        resetButton.snp.makeConstraints { make in
            make.top.equalTo(lastBottom).offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }

        resetButton.addTarget(self, action: #selector(resetSliders), for: .touchUpInside)

        contentView.snp.makeConstraints { make in
            make.bottom.equalTo(resetButton.snp.bottom).offset(20)
        }
    }

    // MARK: - 滑动条响应
    @objc private func sliderChanged(_ sender: UISlider) {
        let value = CGFloat(sender.value)

        updateChartViewProperty(for: sender.tag, value: value)

        if sender.tag < valueLabels.count {
            if sender.tag == 12 {
                valueLabels[sender.tag].text = String(format: "%.2f", sender.value)
            } else {
                valueLabels[sender.tag].text = "\(Int(sender.value))"
            }
        }

        barChartView.chartView.setNeedsDisplay()
    }

    // MARK: - 更新 barChartView 属性
    private func updateChartViewProperty(for index: Int, value: CGFloat) {
        switch index {
        case 0:
            barChartView.chartView.leftPadding = value
        case 1:
            barChartView.chartView.rightPadding = value
        case 2:
            barChartView.chartView.topPadding = value
        case 3:
            barChartView.chartView.titleWidth = value
        case 4:
            barChartView.chartView.titleToTickSpacing = value
        case 5:
            barChartView.chartView.tickLength = value
        case 6:
            barChartView.chartView.tickToAxisSpacing = value
        case 7:
            barChartView.chartView.axisToBarSpacing = value
        case 8:
            barChartView.chartView.barHeight = value
        case 9:
            barChartView.chartView.itemSpacing = value
        case 10:
            barChartView.chartView.valueWidth = value
        case 11:
            barChartView.chartView.valueToBarSpacing = value
        case 12:
            barChartView.chartView.tickThickness = value
        default:
            break
        }
    }

    // MARK: - 重置所有滑块
    @objc private func resetSliders() {
        for (index, slider) in sliders.enumerated() {
            let defaultValue = defaultValues[index]
            slider.value = Float(defaultValue)

            updateChartViewProperty(for: index, value: defaultValue)

            if index < valueLabels.count {
                if index == 12 {
                    valueLabels[index].text = String(format: "%.2f", defaultValue)
                } else {
                    valueLabels[index].text = "\(Int(defaultValue))"
                }
            }
        }

        barChartView.chartView.setNeedsDisplay()
    }

    // MARK: - 生成假数据
    private func generateFakeData() -> [HorizontalBarData] {
        var dataList: [HorizontalBarData] = []
        let startHour = 2
        var prevDay: Int?
        for i in 0..<10 {
            let totalHour = startHour + i
            let day = 27 + totalHour / 10
            let hour = totalHour % 10
            let hourStr = String(format: "%02d", hour)
            let title: String
            if prevDay == nil || day != prevDay {
                title = "\(day)日\(hourStr)时"
            } else {
                title = "\(hourStr)时"
            }
            prevDay = day
            let random = CGFloat.random(in: 0...400)
            dataList.append(HorizontalBarData(title: title, value: random))
        }
        return dataList
    }
}
