//+------------------------------------------------------------------+
//|                   顶底分型与形态识别指标 v1.0                       |
//|                                                                  |
//|  包含形态：顶底分型、Pinbar、孕线、2B战法                           |
//|  附加功能：支撑阻力位自动绘制                                       |
//|  警报方式：图表标记、声音、弹框、日志、EA接口                        |
//+------------------------------------------------------------------+
#property copyright "形态识别指标"
#property link      ""
#property version   "1.00"
#property strict
#property indicator_chart_window

//+------------------------------------------------------------------+
//| 形态类型枚举                                                       |
//+------------------------------------------------------------------+
enum PatternType
{
    PT_NONE = 0,
    PT_TOP_FRACTAL,       // 顶分型
    PT_BOTTOM_FRACTAL,    // 底分型
    PT_UP_PINBAR,         // 上Pinbar
    PT_DOWN_PINBAR,       // 下Pinbar
    PT_HARAMI_BULL,       // 看涨孕线
    PT_HARAMI_BEAR,       // 看跌孕线
    PT_2B_BULL,           // 2B看涨（阳包阴）
    PT_2B_BEAR            // 2B看跌（阴包阳）
};

//+------------------------------------------------------------------+
//| 信号方向枚举                                                       |
//+------------------------------------------------------------------+
enum SignalDir
{
    SD_NONE = 0,
    SD_BUY,               // 看涨
    SD_SELL               // 看跌
};

//+------------------------------------------------------------------+
//| 外部参数 - 形态开关                                                  |
//+------------------------------------------------------------------+
input bool EnableTopFractal = true;         // 启用顶分型
input bool EnableBottomFractal = true;      // 启用底分型
input bool EnableUpPinbar = true;           // 启用上Pinbar
input bool EnableDownPinbar = true;         // 启用下Pinbar
input bool EnableHarami = true;             // 启用孕线
input bool Enable2B = true;                 // 启用2B战法

//+------------------------------------------------------------------+
//| 外部参数 - 支撑阻力                                                  |
//+------------------------------------------------------------------+
input bool EnableSR_Int = true;             // 启用整数位支撑阻力
input bool EnableSR_Half = true;            // 启用半数位支撑阻力
input bool EnableSR_LongK = true;           // 启用长K起涨点
input color ColorSR_Int = clrSilver;        // 整数位颜色
input color ColorSR_Half = clrDodgerBlue;   // 半数位颜色
input color ColorSR_LongK = clrOrange;      // 长K起涨点颜色
input int SR_Style = STYLE_DASH;            // 支撑阻力线样式
input double LongK_Ratio = 2.0;             // 长K判定比例

//+------------------------------------------------------------------+
//| 外部参数 - 图表标记                                                  |
//+------------------------------------------------------------------+
input bool EnableArrow = true;              // 启用箭头标记
input bool EnableText = true;               // 启用文字标记
input bool EnableSLTP = true;               // 启用止损止盈线
input color ColorBuy = clrLime;             // 看涨颜色
input color ColorSell = clrRed;             // 看跌颜色
input int ArrowOffset = 10;                 // 箭头偏移（点）

//+------------------------------------------------------------------+
//| 外部参数 - 警报设置                                                  |
//+------------------------------------------------------------------+
input bool AlertSound = true;               // 声音警报
input bool AlertPopup = true;               // 弹框警报
input bool AlertLog = true;                 // 日志记录
input string SoundFile = "alert.wav";       // 声音文件
input int AlertInterval = 60;               // 警报间隔(秒)

//+------------------------------------------------------------------+
//| 外部参数 - 止损设置                                                  |
//+------------------------------------------------------------------+
input double StopLoss_Buffer = 0.3;         // 止损缓冲（点）

//+------------------------------------------------------------------+
//| 信号结构体                                                          |
//+------------------------------------------------------------------+
struct SignalData
{
    PatternType type;
    SignalDir   dir;
    datetime    time;
    double      price;
    double      stopLoss;
    double      takeProfit;
    bool        isPremium;
    int         barIndex;
};

//+------------------------------------------------------------------+
//| K线数据结构体                                                        |
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
    double totalRange;
    bool   isBull;
    bool   isBear;
};

//+------------------------------------------------------------------+
//| 全局变量                                                           |
//+------------------------------------------------------------------+
SignalData lastSignal;
datetime   lastAlertTime = 0;
int        lastSignalBar = -1;
PatternType lastPattern = PT_NONE;

//+------------------------------------------------------------------+
//| 获取K线数据                                                         |
//+------------------------------------------------------------------+
CandleData GetCandle(int idx)
{
    CandleData c;
    c.open  = Open[idx];
    c.high  = High[idx];
    c.low   = Low[idx];
    c.close = Close[idx];
    c.body  = MathAbs(c.close - c.open);
    c.totalRange = c.high - c.low;
    c.upperShadow = c.high - MathMax(c.open, c.close);
    c.lowerShadow = MathMin(c.open, c.close) - c.low;
    c.isBull = c.close > c.open;
    c.isBear = c.close < c.open;
    return c;
}

//+------------------------------------------------------------------+
//| 顶分型识别                                                          |
//+------------------------------------------------------------------+
bool IsTopFractal(int idx, bool &isPremium)
{
    if(idx < 2) return false;
    
    CandleData c0 = GetCandle(idx);
    CandleData c1 = GetCandle(idx+1);
    CandleData c2 = GetCandle(idx+2);
    
    bool basic = (c1.high > c0.high && c1.high > c2.high);
    if(!basic) return false;
    
    isPremium = false;
    
    if(idx >= 3)
    {
        CandleData c3 = GetCandle(idx+3);
        bool cond1 = c0.low < c1.low && c0.low < c2.low;
        bool cond2 = (c0.close < MathMin(c1.open, c1.close)) || 
                     (c0.close < MathMin(c2.open, c2.close));
        bool cond3 = c0.body < c2.body;
        isPremium = cond1 || cond2 || cond3;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| 底分型识别                                                          |
//+------------------------------------------------------------------+
bool IsBottomFractal(int idx, bool &isPremium)
{
    if(idx < 2) return false;
    
    CandleData c0 = GetCandle(idx);
    CandleData c1 = GetCandle(idx+1);
    CandleData c2 = GetCandle(idx+2);
    
    bool basic = (c1.low < c0.low && c1.low < c2.low);
    if(!basic) return false;
    
    isPremium = false;
    
    if(idx >= 3)
    {
        CandleData c3 = GetCandle(idx+3);
        bool cond1 = c0.high > c1.high && c0.high > c2.high;
        bool cond2 = (c0.close > MathMax(c1.open, c1.close)) || 
                     (c0.close > MathMax(c2.open, c2.close));
        bool cond3 = c0.body < c2.body;
        isPremium = cond1 || cond2 || cond3;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| 上Pinbar识别（下影线长，止跌信号）                                     |
//+------------------------------------------------------------------+
bool IsUpPinbar(int idx)
{
    if(idx < 0) return false;
    CandleData c = GetCandle(idx);
    if(c.totalRange == 0) return false;
    
    double lowerRatio = c.lowerShadow / c.totalRange;
    double bodyRatio = c.body / c.totalRange;
    double upperRatio = c.upperShadow / c.totalRange;
    
    // 下影线占2/3以上，实体小，上影线少
    return (lowerRatio >= 0.66 && bodyRatio <= 0.2 && upperRatio <= 0.14);
}

//+------------------------------------------------------------------+
//| 下Pinbar识别（上影线长，止涨信号）                                     |
//+------------------------------------------------------------------+
bool IsDownPinbar(int idx)
{
    if(idx < 0) return false;
    CandleData c = GetCandle(idx);
    if(c.totalRange == 0) return false;
    
    double upperRatio = c.upperShadow / c.totalRange;
    double bodyRatio = c.body / c.totalRange;
    double lowerRatio = c.lowerShadow / c.totalRange;
    
    // 上影线占2/3以上，实体小，下影线少
    return (upperRatio >= 0.66 && bodyRatio <= 0.2 && lowerRatio <= 0.14);
}

//+------------------------------------------------------------------+
//| 孕线识别                                                            |
//+------------------------------------------------------------------+
bool IsHarami(int idx, SignalDir &dir, bool &isPremium)
{
    if(idx < 2) return false;
    
    CandleData mother = GetCandle(idx+1);
    CandleData child  = GetCandle(idx);
    
    bool bodyEnvelop = (child.body <= mother.body) &&
                       (MathMax(child.open, child.close) <= MathMax(mother.open, mother.close)) &&
                       (MathMin(child.open, child.close) >= MathMin(mother.open, mother.close));
    
    bool shadowEnvelop = (child.high <= mother.high) && (child.low >= mother.low);
    
    if(!bodyEnvelop || !shadowEnvelop) return false;
    
    isPremium = (child.high < mother.high) && (child.low > mother.low);
    
    if(idx >= 1)
    {
        CandleData c0 = GetCandle(idx-1);
        double motherTop = MathMax(mother.open, mother.close);
        double motherBot = MathMin(mother.open, mother.close);
        
        if(c0.close > motherTop)
            dir = SD_BUY;
        else if(c0.close < motherBot)
            dir = SD_SELL;
        else
            dir = child.isBull ? SD_BUY : SD_SELL;
    }
    else
    {
        dir = child.isBull ? SD_BUY : SD_SELL;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| 2B战法识别（阴包阳/阳包阴）                                           |
//+------------------------------------------------------------------+
bool Is2BPattern(int idx, SignalDir &dir, bool &isPremium)
{
    if(idx < 1) return false;
    
    CandleData c0 = GetCandle(idx);
    CandleData c1 = GetCandle(idx+1);
    
    bool bearishEngulf = c1.isBull && c0.isBear &&
                         c0.body >= c1.body &&
                         c0.open > MathMax(c1.open, c1.close) &&
                         c0.close < MathMin(c1.open, c1.close);
    
    bool bullishEngulf = c1.isBear && c0.isBull &&
                         c0.body >= c1.body &&
                         c0.open < MathMin(c1.open, c1.close) &&
                         c0.close > MathMax(c1.open, c1.close);
    
    if(bearishEngulf)
    {
        dir = SD_SELL;
        isPremium = c0.body > c1.body * 1.2;
        return true;
    }
    
    if(bullishEngulf)
    {
        dir = SD_BUY;
        isPremium = c0.body > c1.body * 1.2;
        return true;
    }
    
    if(idx >= 2)
    {
        CandleData c2 = GetCandle(idx+2);
        bool bear3 = c2.isBull && c1.isBull && c0.isBear &&
                     c0.close < MathMin(c2.open, c2.close) &&
                     c0.open > c1.high;
        bool bull3 = c2.isBear && c1.isBear && c0.isBull &&
                     c0.close > MathMax(c2.open, c2.close) &&
                     c0.open < c1.low;
        
        if(bear3)
        {
            dir = SD_SELL;
            isPremium = true;
            return true;
        }
        if(bull3)
        {
            dir = SD_BUY;
            isPremium = true;
            return true;
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| 获取形态名称                                                         |
//+------------------------------------------------------------------+
string GetPatternName(PatternType pt)
{
    switch(pt)
    {
        case PT_TOP_FRACTAL:    return "顶分型";
        case PT_BOTTOM_FRACTAL: return "底分型";
        case PT_UP_PINBAR:      return "上Pinbar";
        case PT_DOWN_PINBAR:    return "下Pinbar";
        case PT_HARAMI_BULL:    return "看涨孕线";
        case PT_HARAMI_BEAR:    return "看跌孕线";
        case PT_2B_BULL:        return "2B看涨";
        case PT_2B_BEAR:        return "2B看跌";
        default: return "未知";
    }
}

//+------------------------------------------------------------------+
//| 获取方向名称                                                         |
//+------------------------------------------------------------------+
string GetDirName(SignalDir d)
{
    return d == SD_BUY ? "看涨" : "看跌";
}

//+------------------------------------------------------------------+
//| 绘制箭头                                                            |
//+------------------------------------------------------------------+
void DrawArrowObj(int idx, SignalDir dir, double price, string name)
{
    if(!EnableArrow) return;
    
    color clr = (dir == SD_BUY) ? ColorBuy : ColorSell;
    int arrowCode = (dir == SD_BUY) ? 233 : 234;
    double offset = Point * ArrowOffset;
    double y = (dir == SD_BUY) ? (price - offset) : (price + offset);
    
    string objName = "Arrow_" + name + "_" + IntegerToString(idx);
    ObjectDelete(0, objName);
    ObjectCreate(0, objName, OBJ_ARROW, 0, Time[idx], y);
    ObjectSetInteger(0, objName, OBJPROP_ARROWCODE, arrowCode);
    ObjectSetInteger(0, objName, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, objName, OBJPROP_WIDTH, 2);
}

//+------------------------------------------------------------------+
//| 绘制文字标签                                                         |
//+------------------------------------------------------------------+
void DrawTextObj(int idx, SignalDir dir, string text, double price, string name)
{
    if(!EnableText) return;
    
    color clr = (dir == SD_BUY) ? ColorBuy : ColorSell;
    double offset = Point * ArrowOffset * 2;
    double y = (dir == SD_BUY) ? (price - offset) : (price + offset);
    
    string objName = "Text_" + name + "_" + IntegerToString(idx);
    ObjectDelete(0, objName);
    ObjectCreate(0, objName, OBJ_TEXT, 0, Time[idx], y);
    ObjectSetString(0, objName, OBJPROP_TEXT, text);
    ObjectSetInteger(0, objName, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 8);
    ObjectSetInteger(0, objName, OBJPROP_ANCHOR, ANCHOR_CENTER);
}

//+------------------------------------------------------------------+
//| 绘制止损止盈线                                                       |
//+------------------------------------------------------------------+
void DrawSLTPLine(int idx, double sl, double tp, string name)
{
    if(!EnableSLTP) return;
    
    string slName = "SL_" + name + "_" + IntegerToString(idx);
    ObjectDelete(0, slName);
    ObjectCreate(0, slName, OBJ_HLINE, 0, 0, sl);
    ObjectSetInteger(0, slName, OBJPROP_COLOR, clrRed);
    ObjectSetInteger(0, slName, OBJPROP_STYLE, STYLE_DOT);
    ObjectSetInteger(0, slName, OBJPROP_WIDTH, 1);
    
    string tpName = "TP_" + name + "_" + IntegerToString(idx);
    ObjectDelete(0, tpName);
    ObjectCreate(0, tpName, OBJ_HLINE, 0, 0, tp);
    ObjectSetInteger(0, tpName, OBJPROP_COLOR, clrGreen);
    ObjectSetInteger(0, tpName, OBJPROP_STYLE, STYLE_DOT);
    ObjectSetInteger(0, tpName, OBJPROP_WIDTH, 1);
}

//+------------------------------------------------------------------+
//| 绘制水平线                                                          |
//+------------------------------------------------------------------+
void DrawHLine(double price, string name, color clr, int style)
{
    ObjectDelete(0, name);
    ObjectCreate(0, name, OBJ_HLINE, 0, 0, price);
    ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, name, OBJPROP_STYLE, style);
    ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
    ObjectSetInteger(0, name, OBJPROP_BACK, true);
}

//+------------------------------------------------------------------+
//| 播放声音警报                                                         |
//+------------------------------------------------------------------+
void PlayAlert()
{
    if(!AlertSound) return;
    PlaySound(SoundFile);
}

//+------------------------------------------------------------------+
//| 弹出警报                                                           |
//+------------------------------------------------------------------+
void PopupAlert(string pattern, string dir, datetime t, double p)
{
    if(!AlertPopup) return;
    string msg = StringFormat("[形态识别] %s - %s\n时间: %s\n价格: %.5f",
                              pattern, dir,
                              TimeToString(t, TIME_DATE|TIME_SECONDS), p);
    Alert(msg);
}

//+------------------------------------------------------------------+
//| 写入日志                                                           |
//+------------------------------------------------------------------+
void WriteLog(string pattern, string dir, datetime t, double p, double sl, double tp)
{
    if(!AlertLog) return;
    
    string fn = "PatternSignal_" + Symbol() + ".log";
    int h = FileOpen(fn, FILE_READ|FILE_WRITE|FILE_TXT);
    if(h != INVALID_HANDLE)
    {
        FileSeek(h, 0, SEEK_END);
        string line = StringFormat("[%s] %s - %s | %s | 价格:%.5f 止损:%.5f 止盈:%.5f\n",
                                    TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS),
                                    pattern, dir, Symbol(), p, sl, tp);
        FileWriteString(h, line);
        FileClose(h);
    }
}

//+------------------------------------------------------------------+
//| 触发信号                                                            |
//+------------------------------------------------------------------+
void TriggerSignal(PatternType pt, SignalDir dir, int idx, double price, 
                   double sl, double tp, bool isPremium)
{
    datetime now = TimeCurrent();
    if(now - lastAlertTime < AlertInterval) return;
    if(idx == lastSignalBar && pt == lastPattern) return;
    
    lastAlertTime = now;
    lastSignalBar = idx;
    lastPattern = pt;
    
    string pn = GetPatternName(pt);
    string dn = GetDirName(dir);
    
    PlayAlert();
    PopupAlert(pn, dn, Time[idx], price);
    WriteLog(pn, dn, Time[idx], price, sl, tp);
    
    lastSignal.type = pt;
    lastSignal.dir = dir;
    lastSignal.time = Time[idx];
    lastSignal.price = price;
    lastSignal.stopLoss = sl;
    lastSignal.takeProfit = tp;
    lastSignal.isPremium = isPremium;
    lastSignal.barIndex = idx;
}

//+------------------------------------------------------------------+
//| 绘制整数位支撑阻力                                                   |
//+------------------------------------------------------------------+
void DrawSR_Integer()
{
    if(!EnableSR_Int) return;
    
    double high = iHigh(_Symbol, _Period, iHighest(_Symbol, _Period, MODE_HIGH, 500, 0));
    double low  = iLow(_Symbol, _Period, iLowest(_Symbol, _Period, MODE_LOW, 500, 0));
    double step;
    
    int digits = (int)MathLog10(Point);
    if(digits <= -4) step = 100 * Point;
    else if(digits <= -2) step = 1.0;
    else step = 100 * Point;
    
    double start = MathFloor(low / step) * step;
    int count = 0;
    
    for(double p = start; p <= high; p += step)
    {
        string name = "SR_Int_" + DoubleToString(p, _Digits);
        DrawHLine(p, name, ColorSR_Int, SR_Style);
        count++;
        if(count > 30) break;
    }
}

//+------------------------------------------------------------------+
//| 绘制半数位支撑阻力                                                   |
//+------------------------------------------------------------------+
void DrawSR_Half()
{
    if(!EnableSR_Half) return;
    
    double high = iHigh(_Symbol, _Period, iHighest(_Symbol, _Period, MODE_HIGH, 500, 0));
    double low  = iLow(_Symbol, _Period, iLowest(_Symbol, _Period, MODE_LOW, 500, 0));
    double step;
    
    int digits = (int)MathLog10(Point);
    if(digits <= -4) step = 50 * Point;
    else if(digits <= -2) step = 0.5;
    else step = 50 * Point;
    
    double start = MathFloor(low / step) * step;
    int count = 0;
    
    for(double p = start; p <= high; p += step)
    {
        string name = "SR_Half_" + DoubleToString(p, _Digits);
        DrawHLine(p, name, ColorSR_Half, SR_Style);
        count++;
        if(count > 50) break;
    }
}

//+------------------------------------------------------------------+
//| 绘制长K起涨点支撑阻力                                                |
//+------------------------------------------------------------------+
void DrawSR_LongK()
{
    if(!EnableSR_LongK) return;
    
    int bars = MathMin(Bars, 500);
    double avgRange = 0;
    int cnt = 0;
    
    for(int i = 0; i < 100 && i < bars; i++)
    {
        avgRange += (High[i] - Low[i]);
        cnt++;
    }
    if(cnt > 0) avgRange /= cnt;
    
    int found = 0;
    for(int i = 0; i < bars && found < 20; i++)
    {
        double range = High[i] - Low[i];
        if(range >= avgRange * LongK_Ratio)
        {
            double support = Low[i];
            double resistance = High[i];
            
            string name1 = "SR_LongK_L_" + IntegerToString(i);
            DrawHLine(support, name1, ColorSR_LongK, STYLE_SOLID);
            
            string name2 = "SR_LongK_H_" + IntegerToString(i);
            DrawHLine(resistance, name2, ColorSR_LongK, STYLE_SOLID);
            
            found++;
        }
    }
}

//+------------------------------------------------------------------+
//| 识别所有形态并标记                                                   |
//+------------------------------------------------------------------+
void RecognizeAll(int idx)
{
    if(idx < 3) return;
    
    bool premium = false;
    SignalDir dir = SD_NONE;
    
    // 顶分型
    if(EnableTopFractal && IsTopFractal(idx, premium))
    {
        Print("发现顶分型 at bar ", idx, " 时间:", TimeToString(Time[idx+1]));
        double sl = High[idx+1] + StopLoss_Buffer * Point;
        double tp = Low[idx+1] - (sl - High[idx+1]);
        DrawArrowObj(idx+1, SD_SELL, High[idx+1], "TopFrac");
        string label = premium ? "顶分型(优)" : "顶分型";
        DrawTextObj(idx+1, SD_SELL, label, High[idx+1], "TopFrac");
        DrawSLTPLine(idx+1, sl, tp, "TopFrac");
        TriggerSignal(PT_TOP_FRACTAL, SD_SELL, idx+1, High[idx+1], sl, tp, premium);
        return;
    }
    
    // 底分型
    if(EnableBottomFractal && IsBottomFractal(idx, premium))
    {
        Print("发现底分型 at bar ", idx, " 时间:", TimeToString(Time[idx+1]));
        double sl = Low[idx+1] - StopLoss_Buffer * Point;
        double tp = High[idx+1] + (Low[idx+1] - sl);
        DrawArrowObj(idx+1, SD_BUY, Low[idx+1], "BotFrac");
        string label = premium ? "底分型(优)" : "底分型";
        DrawTextObj(idx+1, SD_BUY, label, Low[idx+1], "BotFrac");
        DrawSLTPLine(idx+1, sl, tp, "BotFrac");
        TriggerSignal(PT_BOTTOM_FRACTAL, SD_BUY, idx+1, Low[idx+1], sl, tp, premium);
        return;
    }
    
    // 上Pinbar
    if(EnableUpPinbar && IsUpPinbar(idx))
    {
        Print("发现上Pinbar at bar ", idx, " 时间:", TimeToString(Time[idx]));
        double sl = Low[idx] - StopLoss_Buffer * Point;
        double tp = High[idx] + (Low[idx] - sl);
        DrawArrowObj(idx, SD_BUY, Low[idx], "UpPin");
        DrawTextObj(idx, SD_BUY, "上Pinbar", Low[idx], "UpPin");
        DrawSLTPLine(idx, sl, tp, "UpPin");
        TriggerSignal(PT_UP_PINBAR, SD_BUY, idx, Low[idx], sl, tp, false);
        return;
    }
    
    // 下Pinbar
    if(EnableDownPinbar && IsDownPinbar(idx))
    {
        Print("发现下Pinbar at bar ", idx, " 时间:", TimeToString(Time[idx]));
        double sl = High[idx] + StopLoss_Buffer * Point;
        double tp = Low[idx] - (sl - High[idx]);
        DrawArrowObj(idx, SD_SELL, High[idx], "DownPin");
        DrawTextObj(idx, SD_SELL, "下Pinbar", High[idx], "DownPin");
        DrawSLTPLine(idx, sl, tp, "DownPin");
        TriggerSignal(PT_DOWN_PINBAR, SD_SELL, idx, High[idx], sl, tp, false);
        return;
    }
    
    // 孕线
    if(EnableHarami && IsHarami(idx, dir, premium))
    {
        Print("发现孕线 at bar ", idx, " 方向:", dir, " 时间:", TimeToString(Time[idx+1]));
        CandleData mother = GetCandle(idx+1);
        double sl, tp;
        PatternType pt;
        
        if(dir == SD_BUY)
        {
            sl = mother.low - StopLoss_Buffer * Point;
            tp = mother.high + (mother.low - sl);
            pt = PT_HARAMI_BULL;
            DrawArrowObj(idx+1, SD_BUY, mother.low, "Harami");
            string label = premium ? "孕线看涨(优)" : "孕线看涨";
            DrawTextObj(idx+1, SD_BUY, label, mother.low, "Harami");
        }
        else
        {
            sl = mother.high + StopLoss_Buffer * Point;
            tp = mother.low - (sl - mother.high);
            pt = PT_HARAMI_BEAR;
            DrawArrowObj(idx+1, SD_SELL, mother.high, "Harami");
            string label = premium ? "孕线看跌(优)" : "孕线看跌";
            DrawTextObj(idx+1, SD_SELL, label, mother.high, "Harami");
        }
        DrawSLTPLine(idx+1, sl, tp, "Harami");
        TriggerSignal(pt, dir, idx+1, mother.close, sl, tp, premium);
        return;
    }
    
    // 2B战法
    if(Enable2B && Is2BPattern(idx, dir, premium))
    {
        Print("发现2B战法 at bar ", idx, " 方向:", dir, " 时间:", TimeToString(Time[idx]));
        double sl, tp;
        PatternType pt;
        
        if(dir == SD_BUY)
        {
            sl = Low[idx] - StopLoss_Buffer * Point;
            tp = Close[idx] + (Close[idx] - sl);
            pt = PT_2B_BULL;
            DrawArrowObj(idx, SD_BUY, Low[idx], "2B");
            string label = premium ? "2B看涨(优)" : "2B看涨";
            DrawTextObj(idx, SD_BUY, label, Low[idx], "2B");
        }
        else
        {
            sl = High[idx] + StopLoss_Buffer * Point;
            tp = Close[idx] - (sl - Close[idx]);
            pt = PT_2B_BEAR;
            DrawArrowObj(idx, SD_SELL, High[idx], "2B");
            string label = premium ? "2B看跌(优)" : "2B看跌";
            DrawTextObj(idx, SD_SELL, label, High[idx], "2B");
        }
        DrawSLTPLine(idx, sl, tp, "2B");
        TriggerSignal(pt, dir, idx, Close[idx], sl, tp, premium);
        return;
    }
}

//+------------------------------------------------------------------+
//| 指标初始化                                                          |
//+------------------------------------------------------------------+
int OnInit()
{
    IndicatorShortName("形态识别");
    
    lastSignal.type = PT_NONE;
    lastSignal.dir = SD_NONE;
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| 指标主函数                                                          |
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
    // 确保有足够的K线数据
    if(rates_total < 10) return(rates_total);
    
    // 计算起始位置，确保不越界（最大索引为 rates_total-3，因为需要访问 idx+2）
    int start;
    if(prev_calculated > 0)
        start = MathMin(prev_calculated - 1, rates_total - 3);
    else
        start = rates_total - 3;
    
    if(start < 5) start = 5;
    
    DrawSR_Integer();
    DrawSR_Half();
    DrawSR_LongK();
    
    // 从start递减到1（跳过idx=0，当前K线未完成）
    for(int i = start; i >= 1; i--)
    {
        RecognizeAll(i);
    }
    
    return(rates_total);
}

//+------------------------------------------------------------------+
//| EA接口 - 获取最新信号                                                |
//+------------------------------------------------------------------+
SignalData GetLatestSignal()
{
    return lastSignal;
}

//+------------------------------------------------------------------+
//| EA接口 - 获取信号类型                                                |
//+------------------------------------------------------------------+
int GetSignalType()
{
    return (int)lastSignal.type;
}

//+------------------------------------------------------------------+
//| EA接口 - 获取信号方向                                                |
//+------------------------------------------------------------------+
int GetSignalDirection()
{
    return (int)lastSignal.dir;
}

//+------------------------------------------------------------------+
//| EA接口 - 获取信号价格                                                |
//+------------------------------------------------------------------+
double GetSignalPrice()
{
    return lastSignal.price;
}

//+------------------------------------------------------------------+
//| EA接口 - 获取止损                                                    |
//+------------------------------------------------------------------+
double GetSignalSL()
{
    return lastSignal.stopLoss;
}

//+------------------------------------------------------------------+
//| EA接口 - 获取止盈                                                    |
//+------------------------------------------------------------------+
double GetSignalTP()
{
    return lastSignal.takeProfit;
}

//+------------------------------------------------------------------+
//| EA接口 - 获取信号时间                                                |
//+------------------------------------------------------------------+
datetime GetSignalTime()
{
    return lastSignal.time;
}

//+------------------------------------------------------------------+
//| EA接口 - 是否为优品                                                  |
//+------------------------------------------------------------------+
bool IsSignalPremium()
{
    return lastSignal.isPremium;
}
