# 顶底分型与形态识别指标 - Implementation Plan

## [x] Task 1: 创建指标基础框架和配置参数
- **Priority**: high
- **Depends On**: None
- **Description**: 
  - 创建MQL4指标文件基础结构
  - 定义外部参数（各形态开关、颜色、警报设置等）
  - 初始化全局变量和数组
  - 实现指标初始化和去初始化函数
- **Acceptance Criteria Addressed**: NFR-3, NFR-4
- **Test Requirements**:
  - `programmatic` TR-1.1: 指标编译成功无错误
  - `programmatic` TR-1.2: 指标参数在MT4中显示正确
  - `human-judgment` TR-1.3: 代码结构清晰，变量命名规范

## [x] Task 2: 实现K线数据结构和辅助函数
- **Priority**: high
- **Depends On**: Task 1
- **Description**: 
  - 创建K线数据结构存储OHLC和属性
  - 实现K线类型判断（阳线/阴线）
  - 实现实体、影线长度计算
  - 实现相对位置判断函数
- **Acceptance Criteria Addressed**: FR-1 to FR-8 (基础支撑)
- **Test Requirements**:
  - `programmatic` TR-2.1: K线类型判断准确
  - `programmatic` TR-2.2: 实体和影线长度计算正确
  - `human-judgment` TR-2.3: 辅助函数命名清晰

## [x] Task 3: 实现顶底分型识别
- **Priority**: high
- **Depends On**: Task 2
- **Description**: 
  - 实现顶分型识别逻辑（中间K最高价高于左右）
  - 实现底分型识别逻辑（中间K最低价低于左右）
  - 实现优等条件判断（第三根K突破等）
  - 标记止损位（中间K最高/最低±0.3）
- **Acceptance Criteria Addressed**: FR-1, FR-2, FR-3
- **Test Requirements**:
  - `programmatic` TR-3.1: 顶分型识别正确
  - `programmatic` TR-3.2: 底分型识别正确
  - `programmatic` TR-3.3: 优等条件判断正确
  - `programmatic` TR-3.4: 止损位计算正确

## [x] Task 4: 实现Pinbar识别
- **Priority**: high
- **Depends On**: Task 2
- **Description**: 
  - 实现上Pinbar识别（下影线占2/3）
  - 实现下Pinbar识别（上影线占2/3）
  - 标记止损止盈位
- **Acceptance Criteria Addressed**: FR-4, FR-5
- **Test Requirements**:
  - `programmatic` TR-4.1: 上Pinbar识别正确
  - `programmatic` TR-4.2: 下Pinbar识别正确
  - `programmatic` TR-4.3: 止损止盈位计算正确

## [x] Task 5: 实现孕线识别
- **Priority**: high
- **Depends On**: Task 2
- **Description**: 
  - 实现孕线基础识别（母线包子线实体和影线）
  - 实现优等条件判断（不持平为优等）
  - 实现第三根K方向判断
  - 标记止损位（母线最高最低±0.3）
- **Acceptance Criteria Addressed**: FR-6, FR-7
- **Test Requirements**:
  - `programmatic` TR-5.1: 孕线基础识别正确
  - `programmatic` TR-5.2: 优等条件判断正确
  - `programmatic` TR-5.3: 第三根K方向判断正确

## [x] Task 6: 实现2B战法识别
- **Priority**: high
- **Depends On**: Task 2
- **Description**: 
  - 实现阴包阳识别（顶部反转）
  - 实现阳包阴识别（底部反转）
  - 支持3根K比较
  - 优品判断（第二根实体包住第一根实体）
- **Acceptance Criteria Addressed**: FR-8
- **Test Requirements**:
  - `programmatic` TR-6.1: 阴包阳识别正确
  - `programmatic` TR-6.2: 阳包阴识别正确
  - `programmatic` TR-6.3: 优品判断正确

## [x] Task 7: 实现支撑阻力位绘制
- **Priority**: medium
- **Depends On**: Task 1
- **Description**: 
  - 实现整数位/半数位支撑阻力线
  - 实现长K线起涨点标记
  - 实现支阻区间标记
  - 支持颜色和样式配置
- **Acceptance Criteria Addressed**: FR-9, FR-10
- **Test Requirements**:
  - `human-judgment` TR-7.1: 整数位半数位线绘制正确
  - `human-judgment` TR-7.2: 长K起涨点标记正确
  - `human-judgment` TR-7.3: 支阻区间标记正确

## [x] Task 8: 实现图表标记功能
- **Priority**: high
- **Depends On**: Task 1, Task 3-6
- **Description**: 
  - 绘制形态箭头标记
  - 绘制文字标签（形态名称）
  - 绘制止损止盈线
  - 避免重复标记
- **Acceptance Criteria Addressed**: FR-11
- **Test Requirements**:
  - `human-judgment` TR-8.1: 箭头在正确位置显示
  - `human-judgment` TR-8.2: 文字标签清晰可读
  - `human-judgment` TR-8.3: 止损止盈线绘制正确

## [x] Task 9: 实现警报功能（声音、弹框、日志）
- **Priority**: medium
- **Depends On**: Task 1
- **Description**: 
  - 使用PlaySound()播放声音
  - 使用Alert()弹出警告
  - 使用FileWrite()记录日志
  - 实现警报频率限制
- **Acceptance Criteria Addressed**: FR-12, FR-13, FR-14
- **Test Requirements**:
  - `human-judgment` TR-9.1: 声音警报正常
  - `human-judgment` TR-9.2: 弹框警报正常
  - `programmatic` TR-9.3: 日志记录正确
  - `human-judgment` TR-9.4: 频率限制有效

## [x] Task 10: 实现EA接口功能
- **Priority**: high
- **Depends On**: Task 1, Task 3-6
- **Description**: 
  - 实现GetSignal()函数获取最新信号
  - 返回形态类型、方向、时间、价格、止损止盈
  - 实现信号有效期管理
- **Acceptance Criteria Addressed**: FR-15
- **Test Requirements**:
  - `programmatic` TR-10.1: EA接口返回正确信号
  - `programmatic` TR-10.2: 信号信息完整
  - `programmatic` TR-10.3: 无效信号返回正确状态

## [x] Task 11: 整合所有功能并优化代码
- **Priority**: medium
- **Depends On**: Task 1-10
- **Description**: 
  - 整合所有模块
  - 优化计算效率
  - 添加详细注释
  - 测试整体功能
- **Acceptance Criteria Addressed**: NFR-1, NFR-2
- **Test Requirements**:
  - `programmatic` TR-11.1: 指标整体编译成功
  - `human-judgment` TR-11.2: 代码结构清晰，注释完善
  - `human-judgment` TR-11.3: 指标运行流畅
