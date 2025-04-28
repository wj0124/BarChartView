//
//  HorizontalBarChartView.swift
//  ZhongYangQiXiangTai
//
//  Created by 王杰 on 2025/4/27.
//

import UIKit

/// 横向柱状图单条数据模型
struct HorizontalBarData {
    let title: String   // 标题
    let value: CGFloat  // 数值（比如降水量）
}

/// 横向柱状图视图
class HorizontalBarChartView: UIView {

    // MARK: - 输入数据
    var dataList: [HorizontalBarData] = [] {
        didSet { setNeedsDisplay() }
    }

    // MARK: - 布局参数（按照类型、从上到下、从左到右）

    /// 顶部内边距，第一个柱子中心 Y 的偏移量，默认 16
    var topPadding: CGFloat = 16

    /// 整体左侧内边距，控制视图左边预留距离，默认 10
    var leftPadding: CGFloat = 10
    
    /// 最右侧与视图边界的内边距，默认 0
    var rightPadding: CGFloat = 0

    /// 标题区域预留宽度，右对齐绘制标题，默认 60
    var titleWidth: CGFloat = 60

    /// 标题区域和刻度线之间的水平间距，默认 5
    var titleToTickSpacing: CGFloat = 5

    /// 单条刻度线的长度，默认 6
    var tickLength: CGFloat = 6

    /// 刻度线与基线之间的水平间距，默认 0
    var tickToAxisSpacing: CGFloat = 0

    /// 基线与柱子之间的水平间距，默认 0
    var axisToBarSpacing: CGFloat = 0

    /// 单条柱子的高度，默认 16
    var barHeight: CGFloat = 16

    /// 相邻柱子中心点之间的垂直距离，默认 33
    var itemSpacing: CGFloat = 33

    /// 右侧数值背景框的宽度，默认 50
    var valueWidth: CGFloat = 50

    /// 柱子与数值背景之间的水平间距，默认 4
    var valueToBarSpacing: CGFloat = 4

    /// 刻度线和基线的线宽，默认 0.5
    var tickThickness: CGFloat = 0.5

    // MARK: - 样式

    /// 柱子颜色，默认 color69144255
    var barColor: UIColor = UIColor.blue

    /// 数值背景颜色，默认白色
    var valueBackgroundColor: UIColor = .white

    /// 基线和刻度线颜色，默认 color217
    var axisColor: UIColor = UIColor.lightGray

    /// 标题文字和数值文字颜色，默认 color153
    var textColor: UIColor = UIColor.darkGray

    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .white
    }

    // MARK: - 绘制
    override func draw(_ rect: CGRect) {
        guard !dataList.isEmpty,
              let ctx = UIGraphicsGetCurrentContext()
        else { return }

        // 计算关键位置
        let tickStartX = leftPadding + titleWidth + titleToTickSpacing
        let axisX = tickStartX + tickLength + tickToAxisSpacing

        let availableBarWidth = rect.width
            - axisX
            - axisToBarSpacing
            - valueToBarSpacing
            - valueWidth
            - rightPadding

        let maxValue = max(dataList.map { $0.value }.max() ?? 1, 1)

        for (index, data) in dataList.enumerated() {
            let centerY = topPadding + CGFloat(index) * itemSpacing

            // —— 绘制标题区域背景色（调试用，可以注释掉） ——
            let titleBackgroundRect = CGRect(
                x: leftPadding,
                y: centerY - itemSpacing/2,
                width: titleWidth,
                height: itemSpacing
            )
            UIColor.red.withAlphaComponent(0.3).setFill()
            ctx.fill(titleBackgroundRect)

            // —— 绘制柱子 ——
            let barWidth = (data.value / maxValue) * availableBarWidth
            let barRect = CGRect(
                x: axisX + axisToBarSpacing,
                y: centerY - barHeight/2,
                width: barWidth,
                height: barHeight
            )
            barColor.setFill()
            UIBezierPath(roundedRect: barRect,
                         byRoundingCorners: [.topRight, .bottomRight],
                         cornerRadii: CGSize(width: 2, height: 2))
                .fill()

            // —— 绘制标题（右对齐） ——
            let titleAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: textColor
            ]
            let titleSize = data.title.size(withAttributes: titleAttr)
            let titleX = leftPadding + titleWidth - titleSize.width
            let titlePoint = CGPoint(
                x: titleX,
                y: centerY - titleSize.height/2
            )
            data.title.draw(at: titlePoint, withAttributes: titleAttr)

            // —— 绘制右侧数值背景和文字 ——
            let valueText = String(format: "%.0fmm", data.value)
            let valueAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: textColor
            ]
            let valueSize = valueText.size(withAttributes: valueAttr)

            var valueX = axisX + axisToBarSpacing + barWidth + valueToBarSpacing
            let maxValueX = rect.width - valueWidth - rightPadding
            if valueX > maxValueX { valueX = maxValueX }

            let valueRect = CGRect(
                x: valueX,
                y: centerY - valueSize.height/2,
                width: valueWidth,
                height: valueSize.height
            )
            valueBackgroundColor.setFill()
            ctx.fill(valueRect)

            (valueText as NSString).draw(in: valueRect, withAttributes: valueAttr)
        }

        // —— 绘制垂直基线 ——
        axisColor.setStroke()
        let axisPath = UIBezierPath()
        let startY = topPadding - barHeight/2
        let endY = topPadding + CGFloat(dataList.count - 1) * itemSpacing + barHeight/2
        axisPath.move(to: CGPoint(x: axisX, y: startY))
        axisPath.addLine(to: CGPoint(x: axisX, y: endY))
        axisPath.lineWidth = tickThickness
        axisPath.stroke()

        // —— 绘制每一个刻度线 ——
        for idx in dataList.indices {
            let centerY = topPadding + CGFloat(idx) * itemSpacing
            let tickPath = UIBezierPath()
            tickPath.move(to: CGPoint(x: tickStartX, y: centerY))
            tickPath.addLine(to: CGPoint(x: tickStartX + tickLength, y: centerY))
            tickPath.lineWidth = tickThickness
            tickPath.stroke()
        }
    }
}
