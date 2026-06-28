//+------------------------------------------------------------------+
//|                    K线形态识别指标 v1.0                           |
//|                        Pattern Recognition                       |
//|                                                                  |
//|  功能：识别15种经典K线形态                                        |
//|  - 三只乌鸦、早晨之星、黄昏之星                                   |
//|  - 锤子线、上吊线、射击之星、倒锤子线                              |
//|  - 看涨吞没、看跌吞没、刺透形态、乌云盖顶                          |
//|  - 孕线、十字孕线、上升三法、下降三法                              |
//|                                                                  |
//|  警报方式：                                                       |
//|  - 图表箭头标记                                                   |
//|  - 声音警报                                                       |
//|  - 弹框通知                                                       |
//|  - 日志记录                                                       |
//|  - EA接口                                                         |
//+------------------------------------------------------------------+
#property copyright "Pattern Recognition"
#property link      ""
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| 形态类型枚举                                                       |
//+------------------------------------------------------------------+
enum PatternType
{
    PATTERN_NONE = 0,
    PATTERN_HAMMER,              // 锤子线
    PATTERN_HANGING_MAN,         // 上吊线
    PATTERN_SHOOTING_STAR,       // 射击之星
    PATTERN_INVERTED_HAMMER,     // 倒锤子线
    PATTERN_BULLISH_ENGULFING,   // 看涨吞没
    PATTERN_BEARISH_ENGULFING,   // 看跌吞没
    PATTERN_PIERCE,              // 刺透形态
    PATTERN_DARK_CLOUD,          // 乌云盖顶
    PATTERN_HARAMI,              // 孕线
    PATTERN_HARAMI_CROSS,        // 十字孕线
    PATTERN_MORNING_STAR,        // 早晨之星
    PATTERN_EVENING_STAR,        // 黄昏之星
    PATTERN_THREE_CROWS,         // 三只乌鸦
    PATTERN_RISING_THREE,        // 上升三法
    PATTERN_FALLING_THREE        // 下降三法
};

//+------------------------------------------------------------------+
//| 信号方向枚举                                                       |
//+------------------------------------------------------------------+
enum SignalDirection
{
    SIGNAL_NONE = 0,
    SIGNAL_BUY,                  // 看涨信号
    SIGNAL_SELL                  // 看跌信号
};

//+------------------------------------------------------------------+
//| 外部参数配置                                                       |
//+------------------------------------------------------------------+
input bool EnableAlertSound = true;    // 启用声音警报
input bool EnableAlertPopup = true;    // 启用弹框警报
input bool EnableAlertLog = true;      // 启用日志记录
input bool EnableArrowUp = true;       // 启用看涨箭头
input bool EnableArrowDown = true;     // 启用看跌箭头

input color ColorArrowUp = clrLime;    // 看涨箭头颜色
input color ColorArrowDown = clrRed;   // 看跌箭头颜色
input int ArrowSize = 10;              // 箭头大小

input string SoundFile = "alert.wav";  // 声音文件路径
input int AlertInterval = 60;          // 警报间隔(秒)

input bool FilterHammer = true;        // 启用锤子线识别
input bool FilterHangingMan = true;    // 启用上吊线识别
input bool FilterShootingStar = true;  // 启用射击之星识别
input bool FilterInvertedHammer = true;// 启用倒锤子线识别
input bool FilterEngulfing = true;     // 启用吞没形态识别
input bool FilterPierce = true;        // 启用刺透形态识别
input bool FilterDarkCloud = true;     // 启用乌云盖顶识别
input bool FilterHarami = true;        // 启用孕线识别
input bool FilterMorningStar = true;   // 启用早晨之星识别
input bool FilterEveningStar = true;   // 启用黄昏之星识别
input bool FilterThreeCrows = true;    // 启用三只乌鸦识别
input bool FilterThreeMethods = true;  // 启用三法形态识别

//+------------------------------------------------------------------+
//| 全局变量                                                          |
//+------------------------------------------------------------------+
int lastAlertTime = 0;                 // 上次警报时间
int lastSignalBar = -1;                // 上次信号K线位置
PatternType lastPatternType = PATTERN_NONE;

//+------------------------------------------------------------------+
//| 信号结构体                                                        |
//+------------------------------------------------------------------+
struct PatternSignal
{
    PatternType type;
    SignalDirection direction;
    datetime time;
    double price;
    int barIndex;
};

PatternSignal currentSignal;

//+------------------------------------------------------------------+
//| K线数据结构体                                                      |
//+------------------------------------------------------------------+
struct CandleData
{
    double open;
    double high;
    double low;
    double close;
    double body;
    double upperShadow;
    double lowerShadow;
    bool isBullish;
    bool isBearish;
    bool isDoji;
};

//+------------------------------------------------------------------+
//| 初始化指标                                                        |
//+------------------------------------------------------------------+
int OnInit()
{
    IndicatorShortName("K线形态识别");
    SetIndexStyle(0, DRAW_ARROW);
    SetIndexArrow(0, 233);
    SetIndexColor(0, ColorArrowUp);
    SetIndexBuffer(0, signalBufferUp);
    
    SetIndexStyle(1, DRAW_ARROW);
    SetIndexArrow(1, 234);
    SetIndexColor(1, ColorArrowDown);
    SetIndexBuffer(1, signalBufferDown);
    
    ArrayInitialize(signalBufferUp, EMPTY_VALUE);
    ArrayInitialize(signalBufferDown, EMPTY_VALUE);
    
    currentSignal.type = PATTERN_NONE;
    currentSignal.direction = SIGNAL_NONE;
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| 指标缓冲区                                                         |
//+------------------------------------------------------------------+
double signalBufferUp[];
double signalBufferDown[];

//+------------------------------------------------------------------+
//| 获取K线数据                                                        |
//+------------------------------------------------------------------+
CandleData GetCandleData(int index)
{
    CandleData candle;
    candle.open = Open[index];
    candle.high = High[index];
    candle.low = Low[index];
    candle.close = Close[index];
    
    candle.body = MathAbs(candle.close - candle.open);
    candle.upperShadow = candle.high - MathMax(candle.open, candle.close);
    candle.lowerShadow = MathMin(candle.open, candle.close) - candle.low;
    
    double bodyPct = candle.body / (candle.high - candle.low + 0.000001) * 100;
    candle.isBullish = candle.close > candle.open;
    candle.isBearish = candle.close < candle.open;
    candle.isDoji = bodyPct < 10;
    
    return candle;
}

//+------------------------------------------------------------------+
//| 判断是否为锤子线/上吊线                                              |
//+------------------------------------------------------------------+
bool IsHammerOrHangingMan(CandleData candle, bool isHammer)
{
    double totalRange = candle.high - candle.low;
    if(totalRange == 0) return false;
    
    double bodyRatio = candle.body / totalRange;
    double lowerShadowRatio = candle.lowerShadow / totalRange;
    double upperShadowRatio = candle.upperShadow / totalRange;
    
    if(isHammer)
        return bodyRatio < 0.3 && lowerShadowRatio > 0.5 && upperShadowRatio < 0.1;
    else
        return bodyRatio < 0.3 && lowerShadowRatio < 0.1 && upperShadowRatio > 0.5;
}

//+------------------------------------------------------------------+
//| 判断是否为射击之星/倒锤子线                                           |
//+------------------------------------------------------------------+
bool IsShootingStarOrInvertedHammer(CandleData candle, bool isShooting)
{
    double totalRange = candle.high - candle.low;
    if(totalRange == 0) return false;
    
    double bodyRatio = candle.body / totalRange;
    double upperShadowRatio = candle.upperShadow / totalRange;
    double lowerShadowRatio = candle.lowerShadow / totalRange;
    
    if(isShooting)
        return bodyRatio < 0.3 && upperShadowRatio > 0.5 && lowerShadowRatio < 0.1;
    else
        return bodyRatio < 0.3 && upperShadowRatio < 0.1 && lowerShadowRatio > 0.5;
}

//+------------------------------------------------------------------+
//| 判断是否为吞没形态                                                   |
//+------------------------------------------------------------------+
bool IsEngulfing(CandleData prev, CandleData curr, bool isBullish)
{
    if(isBullish)
    {
        return prev.isBearish && curr.isBullish &&
               curr.body > prev.body &&
               curr.open < prev.close &&
               curr.close > prev.open;
    }
    else
    {
        return prev.isBullish && curr.isBearish &&
               curr.body > prev.body &&
               curr.open > prev.close &&
               curr.close < prev.open;
    }
}

//+------------------------------------------------------------------+
//| 判断是否为刺透形态                                                   |
//+------------------------------------------------------------------+
bool IsPiercing(CandleData prev, CandleData curr)
{
    return prev.isBearish && curr.isBullish &&
           curr.close > (prev.open + prev.close) / 2 &&
           curr.close < prev.open &&
           curr.open < prev.low;
}

//+------------------------------------------------------------------+
//| 判断是否为乌云盖顶                                                   |
//+------------------------------------------------------------------+
bool IsDarkCloudCover(CandleData prev, CandleData curr)
{
    return prev.isBullish && curr.isBearish &&
           curr.close < (prev.open + prev.close) / 2 &&
           curr.close > prev.open &&
           curr.open > prev.high;
}

//+------------------------------------------------------------------+
//| 判断是否为孕线形态                                                   |
//+------------------------------------------------------------------+
bool IsHarami(CandleData prev, CandleData curr, bool isCross)
{
    bool isBullishHarami = prev.isBearish && curr.isBullish &&
                           curr.body < prev.body &&
                           curr.open > prev.close &&
                           curr.close < prev.open;
    bool isBearishHarami = prev.isBullish && curr.isBearish &&
                           curr.body < prev.body &&
                           curr.open < prev.close &&
                           curr.close > prev.open;
    
    if(isCross)
        return (isBullishHarami || isBearishHarami) && curr.isDoji;
    else
        return isBullishHarami || isBearishHarami;
}

//+------------------------------------------------------------------+
//| 判断是否为早晨之星                                                   |
//+------------------------------------------------------------------+
bool IsMorningStar(CandleData prev2, CandleData prev1, CandleData curr)
{
    return prev2.isBearish && prev1.isDoji && curr.isBullish &&
           prev1.open > prev2.close && prev1.close > prev2.close &&
           curr.close > (prev2.open + prev2.close) / 2;
}

//+------------------------------------------------------------------+
//| 判断是否为黄昏之星                                                   |
//+------------------------------------------------------------------+
bool IsEveningStar(CandleData prev2, CandleData prev1, CandleData curr)
{
    return prev2.isBullish && prev1.isDoji && curr.isBearish &&
           prev1.open < prev2.close && prev1.close < prev2.close &&
           curr.close < (prev2.open + prev2.close) / 2;
}

//+------------------------------------------------------------------+
//| 判断是否为三只乌鸦                                                   |
//+------------------------------------------------------------------+
bool IsThreeCrows(CandleData c1, CandleData c2, CandleData c3)
{
    return c1.isBearish && c2.isBearish && c3.isBearish &&
           c2.close < c1.close && c3.close < c2.close &&
           c2.open > c1.open && c3.open > c2.open;
}

//+------------------------------------------------------------------+
//| 判断是否为上升三法                                                   |
//+------------------------------------------------------------------+
bool IsRisingThree(CandleData c1, CandleData c2, CandleData c3, CandleData c4, CandleData c5)
{
    if(!c1.isBullish || !c5.isBullish) return false;
    
    bool middleBearish = c2.isBearish && c3.isBearish && c4.isBearish;
    bool withinRange = c2.high < c1.high && c4.low > c1.low;
    bool breakout = c5.close > c1.close;
    
    return middleBearish && withinRange && breakout;
}

//+------------------------------------------------------------------+
//| 判断是否为下降三法                                                   |
//+------------------------------------------------------------------+
bool IsFallingThree(CandleData c1, CandleData c2, CandleData c3, CandleData c4, CandleData c5)
{
    if(!c1.isBearish || !c5.isBearish) return false;
    
    bool middleBullish = c2.isBullish && c3.isBullish && c4.isBullish;
    bool withinRange = c2.low > c1.low && c4.high < c1.high;
    bool breakdown = c5.close < c1.close;
    
    return middleBullish && withinRange && breakdown;
}

//+------------------------------------------------------------------+
//| 获取形态名称                                                        |
//+------------------------------------------------------------------+
string GetPatternName(PatternType type)
{
    switch(type)
    {
        case PATTERN_HAMMER: return "锤子线";
        case PATTERN_HANGING_MAN: return "上吊线";
        case PATTERN_SHOOTING_STAR: return "射击之星";
        case PATTERN_INVERTED_HAMMER: return "倒锤子线";
        case PATTERN_BULLISH_ENGULFING: return "看涨吞没";
        case PATTERN_BEARISH_ENGULFING: return "看跌吞没";
        case PATTERN_PIERCE: return "刺透形态";
        case PATTERN_DARK_CLOUD: return "乌云盖顶";
        case PATTERN_HARAMI: return "孕线";
        case PATTERN_HARAMI_CROSS: return "十字孕线";
        case PATTERN_MORNING_STAR: return "早晨之星";
        case PATTERN_EVENING_STAR: return "黄昏之星";
        case PATTERN_THREE_CROWS: return "三只乌鸦";
        case PATTERN_RISING_THREE: return "上升三法";
        case PATTERN_FALLING_THREE: return "下降三法";
        default: return "未知形态";
    }
}

//+------------------------------------------------------------------+
//| 获取信号方向名称                                                     |
//+------------------------------------------------------------------+
string GetDirectionName(SignalDirection dir)
{
    return dir == SIGNAL_BUY ? "看涨" : "看跌";
}

//+------------------------------------------------------------------+
//| 播放声音警报                                                        |
//+------------------------------------------------------------------+
void PlayAlertSound()
{
    if(EnableAlertSound && FileExists(SoundFile))
    {
        PlaySound(SoundFile);
    }
}

//+------------------------------------------------------------------+
//| 弹出警告窗口                                                        |
//+------------------------------------------------------------------+
void ShowAlertPopup(string patternName, string direction, datetime time, double price)
{
    if(EnableAlertPopup)
    {
        string alertMsg = StringFormat("[K线形态识别] %s - %s\n时间: %s\n价格: %.5f",
                                       patternName, direction,
                                       TimeToString(time, TIME_DATE|TIME_SECONDS),
                                       price);
        Alert(alertMsg);
    }
}

//+------------------------------------------------------------------+
//| 记录日志                                                            |
//+------------------------------------------------------------------+
void WriteLog(string patternName, string direction, datetime time, double price)
{
    if(!EnableAlertLog) return;
    
    string fileName = "PatternRecognition_" + Symbol() + ".log";
    int fileHandle = FileOpen(fileName, FILE_WRITE|FILE_APPEND|FILE_TXT);
    
    if(fileHandle != INVALID_HANDLE)
    {
        string logLine = StringFormat("[%s] %s - %s | 品种: %s | 时间: %s | 价格: %.5f\n",
                                      TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS),
                                      patternName, direction,
                                      Symbol(),
                                      TimeToString(time, TIME_DATE|TIME_SECONDS),
                                      price);
        FileWriteString(fileHandle, logLine);
        FileClose(fileHandle);
    }
}

//+------------------------------------------------------------------+
//| 触发警报                                                            |
//+------------------------------------------------------------------+
void TriggerAlert(PatternType type, SignalDirection dir, datetime time, double price, int barIndex)
{
    int currentTime = TimeCurrent();
    if(currentTime - lastAlertTime < AlertInterval) return;
    if(barIndex == lastSignalBar && type == lastPatternType) return;
    
    lastAlertTime = currentTime;
    lastSignalBar = barIndex;
    lastPatternType = type;
    
    string patternName = GetPatternName(type);
    string direction = GetDirectionName(dir);
    
    PlayAlertSound();
    ShowAlertPopup(patternName, direction, time, price);
    WriteLog(patternName, direction, time, price);
    
    currentSignal.type = type;
    currentSignal.direction = dir;
    currentSignal.time = time;
    currentSignal.price = price;
    currentSignal.barIndex = barIndex;
}

//+------------------------------------------------------------------+
//| 绘制箭头标记                                                        |
//+------------------------------------------------------------------+
void DrawArrow(int index, SignalDirection dir, double price)
{
    if(dir == SIGNAL_BUY && EnableArrowUp)
    {
        signalBufferUp[index] = price;
        signalBufferDown[index] = EMPTY_VALUE;
    }
    else if(dir == SIGNAL_SELL && EnableArrowDown)
    {
        signalBufferDown[index] = price;
        signalBufferUp[index] = EMPTY_VALUE;
    }
}

//+------------------------------------------------------------------+
//| 识别所有形态                                                        |
//+------------------------------------------------------------------+
void RecognizePatterns(int index)
{
    if(index < 5) return;
    
    CandleData c0 = GetCandleData(index);
    CandleData c1 = GetCandleData(index-1);
    CandleData c2 = GetCandleData(index-2);
    CandleData c3 = GetCandleData(index-3);
    CandleData c4 = GetCandleData(index-4);
    CandleData c5 = GetCandleData(index-5);
    
    // 单根K线形态
    if(FilterHammer && IsHammerOrHangingMan(c0, true))
    {
        TriggerAlert(PATTERN_HAMMER, SIGNAL_BUY, Time[index], c0.low, index);
        DrawArrow(index, SIGNAL_BUY, c0.low - Point * ArrowSize);
        return;
    }
    
    if(FilterHangingMan && IsHammerOrHangingMan(c0, false))
    {
        TriggerAlert(PATTERN_HANGING_MAN, SIGNAL_SELL, Time[index], c0.high, index);
        DrawArrow(index, SIGNAL_SELL, c0.high + Point * ArrowSize);
        return;
    }
    
    if(FilterShootingStar && IsShootingStarOrInvertedHammer(c0, true))
    {
        TriggerAlert(PATTERN_SHOOTING_STAR, SIGNAL_SELL, Time[index], c0.high, index);
        DrawArrow(index, SIGNAL_SELL, c0.high + Point * ArrowSize);
        return;
    }
    
    if(FilterInvertedHammer && IsShootingStarOrInvertedHammer(c0, false))
    {
        TriggerAlert(PATTERN_INVERTED_HAMMER, SIGNAL_BUY, Time[index], c0.low, index);
        DrawArrow(index, SIGNAL_BUY, c0.low - Point * ArrowSize);
        return;
    }
    
    // 两根K线形态
    if(FilterEngulfing && IsEngulfing(c1, c0, true))
    {
        TriggerAlert(PATTERN_BULLISH_ENGULFING, SIGNAL_BUY, Time[index], c0.close, index);
        DrawArrow(index, SIGNAL_BUY, c0.low - Point * ArrowSize);
        return;
    }
    
    if(FilterEngulfing && IsEngulfing(c1, c0, false))
    {
        TriggerAlert(PATTERN_BEARISH_ENGULFING, SIGNAL_SELL, Time[index], c0.close, index);
        DrawArrow(index, SIGNAL_SELL, c0.high + Point * ArrowSize);
        return;
    }
    
    if(FilterPierce && IsPiercing(c1, c0))
    {
        TriggerAlert(PATTERN_PIERCE, SIGNAL_BUY, Time[index], c0.close, index);
        DrawArrow(index, SIGNAL_BUY, c0.low - Point * ArrowSize);
        return;
    }
    
    if(FilterDarkCloud && IsDarkCloudCover(c1, c0))
    {
        TriggerAlert(PATTERN_DARK_CLOUD, SIGNAL_SELL, Time[index], c0.close, index);
        DrawArrow(index, SIGNAL_SELL, c0.high + Point * ArrowSize);
        return;
    }
    
    if(FilterHarami && IsHarami(c1, c0, false))
    {
        SignalDirection dir = c0.isBullish ? SIGNAL_BUY : SIGNAL_SELL;
        TriggerAlert(PATTERN_HARAMI, dir, Time[index], c0.close, index);
        DrawArrow(index, dir, c0.isBullish ? c0.low - Point * ArrowSize : c0.high + Point * ArrowSize);
        return;
    }
    
    if(FilterHarami && IsHarami(c1, c0, true))
    {
        SignalDirection dir = c0.isBullish ? SIGNAL_BUY : SIGNAL_SELL;
        TriggerAlert(PATTERN_HARAMI_CROSS, dir, Time[index], c0.close, index);
        DrawArrow(index, dir, c0.isBullish ? c0.low - Point * ArrowSize : c0.high + Point * ArrowSize);
        return;
    }
    
    // 三根K线形态
    if(FilterMorningStar && IsMorningStar(c2, c1, c0))
    {
        TriggerAlert(PATTERN_MORNING_STAR, SIGNAL_BUY, Time[index], c0.close, index);
        DrawArrow(index, SIGNAL_BUY, c2.low - Point * ArrowSize);
        return;
    }
    
    if(FilterEveningStar && IsEveningStar(c2, c1, c0))
    {
        TriggerAlert(PATTERN_EVENING_STAR, SIGNAL_SELL, Time[index], c0.close, index);
        DrawArrow(index, SIGNAL_SELL, c2.high + Point * ArrowSize);
        return;
    }
    
    if(FilterThreeCrows && IsThreeCrows(c2, c1, c0))
    {
        TriggerAlert(PATTERN_THREE_CROWS, SIGNAL_SELL, Time[index], c0.close, index);
        DrawArrow(index, SIGNAL_SELL, c0.high + Point * ArrowSize);
        return;
    }
    
    // 五根K线形态
    if(FilterThreeMethods && IsRisingThree(c4, c3, c2, c1, c0))
    {
        TriggerAlert(PATTERN_RISING_THREE, SIGNAL_BUY, Time[index], c0.close, index);
        DrawArrow(index, SIGNAL_BUY, c4.low - Point * ArrowSize);
        return;
    }
    
    if(FilterThreeMethods && IsFallingThree(c4, c3, c2, c1, c0))
    {
        TriggerAlert(PATTERN_FALLING_THREE, SIGNAL_SELL, Time[index], c0.close, index);
        DrawArrow(index, SIGNAL_SELL, c4.high + Point * ArrowSize);
        return;
    }
}

//+------------------------------------------------------------------+
//| 指标主函数                                                         |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
    int start = prev_calculated > 0 ? prev_calculated - 1 : 0;
    
    for(int i = start; i < rates_total; i++)
    {
        signalBufferUp[i] = EMPTY_VALUE;
        signalBufferDown[i] = EMPTY_VALUE;
        
        RecognizePatterns(i);
    }
    
    return(rates_total);
}

//+------------------------------------------------------------------+
//| EA接口函数 - 获取最新信号                                            |
//+------------------------------------------------------------------+
PatternSignal GetPatternSignal()
{
    return currentSignal;
}

//+------------------------------------------------------------------+
//| EA接口函数 - 获取信号类型                                            |
//+------------------------------------------------------------------+
int GetPatternType()
{
    return (int)currentSignal.type;
}

//+------------------------------------------------------------------+
//| EA接口函数 - 获取信号方向                                            |
//+------------------------------------------------------------------+
int GetSignalDirection()
{
    return (int)currentSignal.direction;
}

//+------------------------------------------------------------------+
//| EA接口函数 - 获取信号时间                                            |
//+------------------------------------------------------------------+
datetime GetSignalTime()
{
    return currentSignal.time;
}

//+------------------------------------------------------------------+
//| EA接口函数 - 获取信号价格                                            |
//+------------------------------------------------------------------+
double GetSignalPrice()
{
    return currentSignal.price;
}
