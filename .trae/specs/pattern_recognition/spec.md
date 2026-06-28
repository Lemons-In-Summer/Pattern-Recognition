# 顶底分型与形态识别指标 - Product Requirement Document

## Overview
- **Summary**: 创建一个MT4平台的综合K线形态识别指标，包含顶底分型、Pinbar、孕线、2B战法四种核心形态识别，以及支撑阻力位自动绘制功能。
- **Purpose**: 帮助交易者识别关键反转形态和支撑阻力位置，提高交易决策的准确性和效率。
- **Target Users**: 外汇/期货交易者、技术分析爱好者、日内交易者

## Goals
- 实现顶分型和底分型识别（含优等条件判断）
- 实现上Pinbar和下Pinbar识别
- 实现孕线形态识别（含第三根K方向判断）
- 实现2B战法形态识别（阴包阳/阳包阴）
- 实现支撑阻力位自动绘制（整数位、半数位、长K起涨点、趋势线）
- 在图表上标记形态位置和止损止盈位
- 提供声音警报、弹框通知、日志记录功能
- 提供EA接口供外部调用

## Non-Goals (Out of Scope)
- 不包含自动交易下单功能
- 不实现复杂图表形态（头肩顶、双底等）
- 不支持MT5平台
- 不包含机器学习或AI识别

## Background & Context
- 基于用户提供的详细技术分析规则，包含4种核心K线形态和支撑阻力位计算方法
- 每种形态都有明确的识别标准、止损止盈建议
- 参考Pattern Recognition Master的设计思路

## Functional Requirements
- **FR-1**: 顶分型识别 - 中间K最高价高于左右两边最高价
- **FR-2**: 底分型识别 - 中间K最低价低于左右两边最低价
- **FR-3**: 顶/底分型优等条件判断 - 第三根K突破等条件
- **FR-4**: 上Pinbar识别 - 下影线占整根K长度2/3
- **FR-5**: 下Pinbar识别 - 上影线占整根K长度2/3
- **FR-6**: 孕线识别 - 母线实体和影线包裹子线
- **FR-7**: 孕线方向判断 - 第三根K突破方向
- **FR-8**: 2B战法识别 - 阴包阳/阳包阴反转形态
- **FR-9**: 整数位/半数位支撑阻力绘制
- **FR-10**: 长K线起涨点支撑阻力标记
- **FR-11**: 图表标记 - 箭头、文字、止损止盈线
- **FR-12**: 声音警报功能
- **FR-13**: 弹框通知功能
- **FR-14**: 日志记录功能
- **FR-15**: EA接口功能

## Non-Functional Requirements
- **NFR-1**: 指标运行高效，不影响图表刷新
- **NFR-2**: 代码结构清晰，易于扩展
- **NFR-3**: 支持自定义参数配置
- **NFR-4**: 错误处理完善

## Constraints
- **Technical**: MQL4语言，MT4平台
- **Dependencies**: MT4内置函数库

## Assumptions
- 用户已安装MT4交易平台
- 用户熟悉MQL4编译和指标安装
- 图表使用标准蜡烛图显示

## Acceptance Criteria

### AC-1: 顶分型识别
- **Given**: 图表上存在3根K线，中间K最高价高于左右两边最高价
- **When**: 指标计算完成
- **Then**: 在顶分型位置标记向下箭头和文字
- **Verification**: `programmatic`

### AC-2: 底分型识别
- **Given**: 图表上存在3根K线，中间K最低价低于左右两边最低价
- **When**: 指标计算完成
- **Then**: 在底分型位置标记向上箭头和文字
- **Verification**: `programmatic`

### AC-3: 上Pinbar识别
- **Given**: 图表上存在下影线占2/3的K线
- **When**: 指标计算完成
- **Then**: 在Pinbar位置标记和文字说明
- **Verification**: `programmatic`

### AC-4: 下Pinbar识别
- **Given**: 图表上存在上影线占2/3的K线
- **When**: 指标计算完成
- **Then**: 在Pinbar位置标记和文字说明
- **Verification**: `programmatic`

### AC-5: 孕线识别
- **Given**: 图表上存在母线包裹子线的形态
- **When**: 指标计算完成
- **Then**: 在孕线位置标记，第三根K确认方向
- **Verification**: `programmatic`

### AC-6: 2B战法识别
- **Given**: 图表上存在阴包阳或阳包阴形态
- **When**: 指标计算完成
- **Then**: 在2B位置标记反转信号
- **Verification**: `programmatic`

### AC-7: 支撑阻力位绘制
- **Given**: 图表加载完成
- **When**: 指标计算完成
- **Then**: 绘制整数位、半数位、长K起涨点支撑阻力线
- **Verification**: `human-judgment`

### AC-8: 警报功能
- **Given**: 识别到有效形态且对应警报已启用
- **When**: 形态确认
- **Then**: 触发声音、弹框、日志记录
- **Verification**: `human-judgment`

### AC-9: EA接口
- **Given**: 外部EA调用接口函数
- **When**: 请求信号
- **Then**: 返回最新形态信号信息
- **Verification**: `programmatic`

## Open Questions
- [ ] 指标文件的具体名称是什么？
- [ ] 止损±0.3是指点还是美元？
