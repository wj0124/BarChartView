

Horizontal Bar Chart Demo

一个轻量级的 iOS 横向柱状图组件，使用 UIKit + SnapKit 实现。支持横向滚动，支持实时调整布局参数，适合数据可视化展示场景。

功能特点
	•	绘制横向柱状图，支持动态数据列表
	•	滑动条实时调整各项布局参数（如柱子高度、间距、左右边距等）
	•	自动计算最大值比例，柱子宽度自适应缩放
	•	标题右对齐，数值框自动避让
	•	支持柱子圆角、基线、刻度线自定义样式
	•	支持滚动容器，超出屏幕时自动滚动展示
	•	内置假数据生成，方便调试和测试
	•	支持一键恢复所有布局参数到默认值

技术栈
	•	UIKit 原生绘制 (draw(_:))
	•	SnapKit 布局
	•	支持 iOS 13 及以上版本

目录结构
	•	HorizontalBarChartView.swift 单条柱状图绘制
	•	HorizontalScrollableBarChartView.swift 滚动容器封装
	•	ViewController.swift 演示界面，带参数调节功能

![ezgif-2f9da6a62aa86c](https://github.com/user-attachments/assets/00ebebc2-7629-42d8-96c5-6d2163dd41db)
