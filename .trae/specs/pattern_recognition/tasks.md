# MT4 K线形态识别指标 - Implementation Plan

## [x] Task 1: 创建指标基础框架和配置参数
- **Priority**: high
- **Depends On**: None
- **Description**: 
  - 创建MQL4指标文件基础结构
  - 定义外部参数（警报开关、箭头颜色、形态过滤等）
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
  - 创建K线数据结构存储OHLC和其他属性
  - 实现K线类型判断函数（阳线/阴线/十字线）
  - 实现实体、影线长度计算函数
  - 实现K线相对位置判断函数
- **Acceptance Criteria Addressed**: FR-1 to FR-15 (基础支撑)
- **Test Requirements**:
  - `programmatic` TR-2.1: K线类型判断准确（阳/阴/十字）
  - `programmatic` TR-2.2: 实体和影线长度计算正确
  - `human-judgment` TR-2.3: 辅助函数命名清晰，易于理解

## [x] Task 3: 实现单根K线形态识别（锤子线、上吊线、射击之星、倒锤子线）
- **Priority**: high
- **Depends On**: Task 2
- **Description**: 
  - 实现锤子线识别逻辑
  - 实现上吊线识别逻辑
  - 实现射击之星识别逻辑
  - 实现倒锤子线识别逻辑
- **Acceptance Criteria Addressed**: FR-4, FR-5, FR-12, FR-13
- **Test Requirements**:
  - `programmatic` TR-3.1: 锤子线形态识别正确
  - `programmatic` TR-3.2: 上吊线形态识别正确
  - `programmatic` TR-3.3: 射击之星形态识别正确
  - `programmatic` TR-3.4: 倒锤子线形态识别正确

## [x] Task 4: 实现两根K线形态识别（吞没、刺透、乌云盖顶、孕线、十字孕线）
- **Priority**: high
- **Depends On**: Task 2
- **Description**: 
  - 实现看涨吞没识别逻辑
  - 实现看跌吞没识别逻辑
  - 实现刺透形态识别逻辑
  - 实现乌云盖顶识别逻辑
  - 实现孕线和十字孕线识别逻辑
- **Acceptance Criteria Addressed**: FR-6, FR-7, FR-8, FR-9, FR-10, FR-11
- **Test Requirements**:
  - `programmatic` TR-4.1: 看涨吞没形态识别正确
  - `programmatic` TR-4.2: 看跌吞没形态识别正确
  - `programmatic` TR-4.3: 刺透形态识别正确
  - `programmatic` TR-4.4: 乌云盖顶形态识别正确
  - `programmatic` TR-4.5: 孕线和十字孕线形态识别正确

## [x] Task 5: 实现多根K线形态识别（早晨之星、黄昏之星、三只乌鸦、上升三法、下降三法）
- **Priority**: high
- **Depends On**: Task 2
- **Description**: 
  - 实现早晨之星识别逻辑
  - 实现黄昏之星识别逻辑
  - 实现三只乌鸦识别逻辑
  - 实现上升三法识别逻辑
  - 实现下降三法识别逻辑
- **Acceptance Criteria Addressed**: FR-1, FR-2, FR-3, FR-14, FR-15
- **Test Requirements**:
  - `programmatic` TR-5.1: 早晨之星形态识别正确
  - `programmatic` TR-5.2: 黄昏之星形态识别正确
  - `programmatic` TR-5.3: 三只乌鸦形态识别正确
  - `programmatic` TR-5.4: 上升三法形态识别正确
  - `programmatic` TR-5.5: 下降三法形态识别正确

## [x] Task 6: 实现图表标记功能（绘制箭头）
- **Priority**: high
- **Depends On**: Task 1, Task 3, Task 4, Task 5
- **Description**: 
  - 实现在识别位置绘制向上/向下箭头
  - 设置箭头颜色（绿色=看涨，红色=看跌）
  - 实现箭头样式和大小配置
  - 避免重复标记同一位置
- **Acceptance Criteria Addressed**: FR-16
- **Test Requirements**:
  - `human-judgment` TR-6.1: 箭头在正确位置显示
  - `human-judgment` TR-6.2: 箭头颜色与形态方向一致
  - `human-judgment` TR-6.3: 无重复标记

## [x] Task 7: 实现声音警报功能
- **Priority**: medium
- **Depends On**: Task 1
- **Description**: 
  - 使用PlaySound()函数播放声音
  - 支持自定义声音文件路径
  - 实现声音警报开关控制
  - 添加声音播放频率限制（避免重复播放）
- **Acceptance Criteria Addressed**: FR-17
- **Test Requirements**:
  - `human-judgment` TR-7.1: 识别到形态时播放声音
  - `human-judgment` TR-7.2: 关闭声音警报后不播放
  - `human-judgment` TR-7.3: 同一形态不重复播放

## [x] Task 8: 实现弹框警报功能
- **Priority**: medium
- **Depends On**: Task 1
- **Description**: 
  - 使用Alert()函数弹出警告窗口
  - 警报内容包含形态名称和时间信息
  - 实现弹框警报开关控制
  - 添加弹框频率限制
- **Acceptance Criteria Addressed**: FR-18
- **Test Requirements**:
  - `human-judgment` TR-8.1: 识别到形态时弹出警告窗口
  - `human-judgment` TR-8.2: 警告信息包含形态名称和时间
  - `human-judgment` TR-8.3: 关闭弹框警报后不弹出

## [x] Task 9: 实现日志记录功能
- **Priority**: medium
- **Depends On**: Task 1
- **Description**: 
  - 使用FileOpen()/FileWrite()函数写入日志
  - 日志格式包含时间、品种、形态名称、方向、价格
  - 实现日志开关控制
  - 自动处理文件大小限制（定期新建日志文件）
- **Acceptance Criteria Addressed**: FR-19
- **Test Requirements**:
  - `programmatic` TR-9.1: 日志文件正确创建
  - `programmatic` TR-9.2: 日志内容格式正确完整
  - `programmatic` TR-9.3: 关闭日志后不写入

## [x] Task 10: 实现EA接口功能
- **Priority**: high
- **Depends On**: Task 1, Task 3, Task 4, Task 5
- **Description**: 
  - 实现GetPatternSignal()函数供外部EA调用
  - 返回最新形态类型、方向、时间、价格
  - 实现信号有效期管理
  - 添加信号确认机制（避免虚假信号）
- **Acceptance Criteria Addressed**: FR-20
- **Test Requirements**:
  - `programmatic` TR-10.1: EA接口函数正确返回信号
  - `programmatic` TR-10.2: 信号包含完整信息（类型、方向、时间、价格）
  - `programmatic` TR-10.3: 无效信号返回正确状态

## [x] Task 11: 整合所有功能并优化代码
- **Priority**: medium
- **Depends On**: Task 1-10
- **Description**: 
  - 整合所有模块到主文件
  - 优化指标计算效率
  - 添加必要的注释说明
  - 测试整体功能流程
- **Acceptance Criteria Addressed**: NFR-1, NFR-2
- **Test Requirements**:
  - `programmatic` TR-11.1: 指标整体编译成功
  - `human-judgment` TR-11.2: 代码结构清晰，注释完善
  - `human-judgment` TR-11.3: 指标运行流畅，无明显卡顿
