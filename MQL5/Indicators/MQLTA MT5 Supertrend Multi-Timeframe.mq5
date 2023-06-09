#property link          "https://www.earnforex.com/metatrader-indicators/supertrend-multi-timeframe/"
#property version       "1.12"

#property copyright     "EarnForex.com - 2019-2023"
#property description   "This Indicator will show you the status of the Supertrend"
#property description   "indicator on multiple timeframes."
#property description   " "
#property description   "WARNING : You use this software at your own risk."
#property description   "The creator of these plugins cannot be held responsible for damage or loss."
#property description   " "
#property description   "Find More on EarnForex.com"
#property icon          "\\Files\\EF-Icon-64x64px.ico"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots 2
#property indicator_type1 DRAW_COLOR_LINE
#property indicator_color1 clrGreen, clrRed
#property indicator_width1 2

enum enum_candle_to_check
{
    Current,
    Previous
};

input string Comment_1 = "====================";  // Indicator Settings
input double ATRMultiplier = 2.0;                 // ATR multiplier
input int ATRPeriod = 100;                        // ATR period
input int ATRMaxBars = 1000;                      // ATR max bars
input int Shift = 0;                              // Indicator shift, positive or negative
input enum_candle_to_check TriggerCandle = Previous; // Candle to check values
input string SupertrendFileName = "MQLTA MT5 Supertrend Line"; // Supertrend indicator's file name
input string Comment_2b = "===================="; // Enabled Timeframes
input bool TFM1 = true;                           // Enable M1
input bool TFM5 = true;                           // Enable M5
input bool TFM15 = true;                          // Enable M15
input bool TFM30 = true;                          // Enable M30
input bool TFH1 = true;                           // Enable H1
input bool TFH4 = true;                           // Enable H4
input bool TFD1 = true;                           // Enable D1
input bool TFW1 = true;                           // Enable W1
input bool TFMN1 = true;                          // Enable MN1
input string Comment_3 = "====================";  // Notification Options
input bool EnableNotify = false;                  // Enable notifications feature
input bool SendAlert = false;                      // Send alert notification
input bool SendApp = false;                        // Send notification to mobile
input bool SendEmail = false;                      // Send notification via email
input string Comment_4 = "====================";  // Graphical Objects
input bool DrawLinesEnabled = true;               // Draw Supertrend line
input bool DrawWindowEnabled = true;              // Draw panel
input bool DrawArrowSignal = true;                // Draw arrow signals
input int ArrowCodeUp = 241;                      // Arrow code Buy
input int ArrowCodeDown = 242;                    // Arrow code Sell
input int Xoff = 20;                              // Horizontal spacing for the control panel
input int Yoff = 20;                              // Vertical spacing for the control panel
input string IndicatorName = "MQLTA-SMTF";        // Indicator name (chart objects' prefix)

double Trend[], TrendColor[], TrendDirection[];
double up[], dn[], trend[];

bool UpTrend = false;
bool DownTrend = false;

// For each timeframe:
bool TFEnabled[9];
ENUM_TIMEFRAMES TFValues[9]; // Timeframe enum.
string TFText[9]; // Timeframe short name.
int TFTrend[9]; // Up/Down.
double TFSTValue[9]; // Supertrend line value.
int TFSTHandle[9]; // Handles for custom indicators.

/*
TrendDirection buffer contains the trend direction:
It is  1 if trending UP (Green)
It is -1 if trending DOWN (red)
*/

int AlertVariable;
int LastAlertDirection = 2; // Signal that was alerted on previous alert. "2" because "0", "1", and "-1" are taken for signals.

double DPIScale; // Scaling parameter for the panel based on the screen DPI.
int PanelMovX, PanelMovY, PanelLabX, PanelLabY, PanelRecX, PanelBaseButtonHeight, PanelBaseButtonWidth, PanelWideButtonWidth, PanelWB_DPI;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);

    CleanChart();

    TFEnabled[0] = TFM1;
    TFEnabled[1] = TFM5;
    TFEnabled[2] = TFM15;
    TFEnabled[3] = TFM30;
    TFEnabled[4] = TFH1;
    TFEnabled[5] = TFH4;
    TFEnabled[6] = TFD1;
    TFEnabled[7] = TFW1;
    TFEnabled[8] = TFMN1;
    TFValues[0] = PERIOD_M1;
    TFValues[1] = PERIOD_M5;
    TFValues[2] = PERIOD_M15;
    TFValues[3] = PERIOD_M30;
    TFValues[4] = PERIOD_H1;
    TFValues[5] = PERIOD_H4;
    TFValues[6] = PERIOD_D1;
    TFValues[7] = PERIOD_W1;
    TFValues[8] = PERIOD_MN1;
    TFText[0] = "M1";
    TFText[1] = "M5";
    TFText[2] = "M15";
    TFText[3] = "M30";
    TFText[4] = "H1";
    TFText[5] = "H4";
    TFText[6] = "D1";
    TFText[7] = "W1";
    TFText[8] = "MN1";

    if (TFM1)  TFSTHandle[0] = iCustom(Symbol(), TFValues[0], SupertrendFileName, "", ATRMultiplier, ATRPeriod);
    if (TFSTHandle[0] == INVALID_HANDLE) Print("Failied to load " + SupertrendFileName + ": " + IntegerToString(GetLastError()));
    if (TFM5)  TFSTHandle[1] = iCustom(Symbol(), TFValues[1], SupertrendFileName, "", ATRMultiplier, ATRPeriod);
    if (TFSTHandle[1] == INVALID_HANDLE) Print("Failied to load " + SupertrendFileName + ": " + IntegerToString(GetLastError()));
    if (TFM15) TFSTHandle[2] = iCustom(Symbol(), TFValues[2], SupertrendFileName, "", ATRMultiplier, ATRPeriod);
    if (TFSTHandle[2] == INVALID_HANDLE) Print("Failied to load " + SupertrendFileName + ": " + IntegerToString(GetLastError()));
    if (TFM30) TFSTHandle[3] = iCustom(Symbol(), TFValues[3], SupertrendFileName, "", ATRMultiplier, ATRPeriod);
    if (TFSTHandle[3] == INVALID_HANDLE) Print("Failied to load " + SupertrendFileName + ": " + IntegerToString(GetLastError()));
    if (TFH1)  TFSTHandle[4] = iCustom(Symbol(), TFValues[4], SupertrendFileName, "", ATRMultiplier, ATRPeriod);
    if (TFSTHandle[4] == INVALID_HANDLE) Print("Failied to load " + SupertrendFileName + ": " + IntegerToString(GetLastError()));
    if (TFH4)  TFSTHandle[5] = iCustom(Symbol(), TFValues[5], SupertrendFileName, "", ATRMultiplier, ATRPeriod);
    if (TFSTHandle[5] == INVALID_HANDLE) Print("Failied to load " + SupertrendFileName + ": " + IntegerToString(GetLastError()));
    if (TFD1)  TFSTHandle[6] = iCustom(Symbol(), TFValues[6], SupertrendFileName, "", ATRMultiplier, ATRPeriod);
    if (TFSTHandle[6] == INVALID_HANDLE) Print("Failied to load " + SupertrendFileName + ": " + IntegerToString(GetLastError()));
    if (TFW1)  TFSTHandle[7] = iCustom(Symbol(), TFValues[7], SupertrendFileName, "", ATRMultiplier, ATRPeriod);
    if (TFSTHandle[7] == INVALID_HANDLE) Print("Failied to load " + SupertrendFileName + ": " + IntegerToString(GetLastError()));
    if (TFMN1) TFSTHandle[8] = iCustom(Symbol(), TFValues[8], SupertrendFileName, "", ATRMultiplier, ATRPeriod);
    if (TFSTHandle[8] == INVALID_HANDLE) Print("Failied to load " + SupertrendFileName + ": " + IntegerToString(GetLastError()));

    SetIndexBuffer(0, Trend, INDICATOR_DATA);
    SetIndexBuffer(1, TrendColor, INDICATOR_COLOR_INDEX);
    SetIndexBuffer(2, TrendDirection, INDICATOR_DATA); // For iCustom reading (EAs and the like).
    
    PlotIndexSetInteger(0, PLOT_SHIFT, Shift);
    PlotIndexSetInteger(1, PLOT_SHIFT, Shift);
    
    PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
    PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);

    ArraySetAsSeries(Trend, true);
    ArraySetAsSeries(TrendColor, true);
    ArraySetAsSeries(TrendDirection, true);
    
    DPIScale = (double)TerminalInfoInteger(TERMINAL_SCREEN_DPI) / 96.0;
    PanelBaseButtonHeight = 20;
    PanelBaseButtonWidth = 50;
    PanelWideButtonWidth = 75;
    PanelMovX = (int)MathRound(PanelBaseButtonWidth * DPIScale); // Narrow label width.
    PanelMovY = (int)MathRound(PanelBaseButtonHeight * DPIScale); // Label height.
    PanelLabX = (int)MathRound((2 * PanelBaseButtonWidth + PanelWideButtonWidth + 4) * DPIScale); // Wide label width.
    PanelLabY = PanelMovY; // Wide label height.
    PanelRecX = PanelLabX + (int)MathRound(4 * DPIScale); // Panel width
    PanelWB_DPI = (int)MathRound(PanelWideButtonWidth * DPIScale);
    
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate (const int rates_total,
                 const int prev_calculated,
                 const datetime& time[],
                 const double& open[],
                 const double& high[],
                 const double& low[],
                 const double& close[],
                 const long& tick_volume[],
                 const long& volume[],
                 const int& spread[])
{
    // int counted_bars = IndicatorCounted();
    int counted_bars = 0;
    if (prev_calculated > 0) counted_bars = prev_calculated - 1;

    if (counted_bars < 0) return -1;
    if (counted_bars > 0) counted_bars--;
    int limit = rates_total - counted_bars;
    if (limit > ATRMaxBars)
    {
        limit = ATRMaxBars;
        if (rates_total < ATRMaxBars + 2 + ATRPeriod) limit = rates_total - 2 - ATRPeriod;
        if (limit <= 0)
        {
            Print("Need more historical data to calculate Supertrend");
            return 0;
        }
    }
    if (limit > rates_total - 2 - ATRPeriod) limit = rates_total- 2 - ATRPeriod;

    CalculateLevels(limit);
    
    Notify();
    if (DrawArrowSignal) DrawArrow(0);
    if (DrawWindowEnabled) DrawPanel();
    
    return rates_total;
}

//+------------------------------------------------------------------+
//| Indicator deinitialization.                                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    CleanChart();
}

//+------------------------------------------------------------------+
//| Delets all chart objects created by the indicator.               |
//+------------------------------------------------------------------+
void CleanChart()
{
    ObjectsDeleteAll(ChartID(), IndicatorName);
}

//+------------------------------------------------------------------+
//| Main function to detect Positive, Negative, Uncertain state.     |
//| It also draws the current timeframe line                         |
//| and fills the overall direction buffer.                          |
//+------------------------------------------------------------------+
void CalculateLevels(int limit) // limit is used for the current timeframe only to draw its line.
{
    int EnabledCount = 0;
    int UpCount = 0;
    int DownCount = 0;
    UpTrend = false;
    DownTrend = false;
    int MaxBars = ATRMaxBars;
    ArrayInitialize(TFTrend, 0);
    ArrayInitialize(TFSTValue, 0);
    for (int i = 0; i < ArraySize(TFTrend); i++)
    {
        if (!TFEnabled[i]) continue;
        if (iBars(Symbol(), TFValues[i]) < MaxBars)
        {
            MaxBars = iBars(Symbol(), TFValues[i]);
            Print("Please load more historical candles. Current calculation only on ", MaxBars, " bars for timeframe ", TFText[i], ".");
            if (MaxBars < 0)
            {
                break;
            }
        }
        EnabledCount++;
        
        if ((DrawLinesEnabled) && (TFValues[i] == Period())) // Calculate all bars for the current period.
        {
            if (limit >= iBars(Symbol(), TFValues[i])) limit = iBars(Symbol(), TFValues[i]) - 1;
            if (limit < 0) return;
            for (int j = limit; j >= 0; j--) TrendDirection[j] = EMPTY_VALUE;
            CopyBuffer(TFSTHandle[i], 0, 0, limit + 1, Trend);
            CopyBuffer(TFSTHandle[i], 1, 0, limit + 1, TrendColor);
        }
        
        if (BarsCalculated(TFSTHandle[i]) < 0)
        {
            Print("Waiting for Supertrend indicator data on ", EnumToString(TFValues[i]), "...");
        }

        double values[1];
        values[0] = 0;
        CopyBuffer(TFSTHandle[i], 0, (int)TriggerCandle, 1, values);
        TFSTValue[i] = values[0];

        double directions[1];
        directions[0] = -1;
        CopyBuffer(TFSTHandle[i], 1, (int)TriggerCandle, 1, directions);
        TFTrend[i] = (int)directions[0]; // 0 or 1.

        if (TFTrend[i] == -1)
        {
            Print("Not enough historical data, please load more candles for ", TFText[i]);
        }
        else if (TFTrend[i] == 0)
        {
            UpCount++;
        }
        else // == 1
        {
            DownCount++;
        }
    }
    if (UpCount == EnabledCount)
    {
        UpTrend = true;
        TrendDirection[0] = 1;
    }
    else if (DownCount == EnabledCount)
    {
        DownTrend = true;
        TrendDirection[0] = -1;
    }
    else TrendDirection[0] = 0;
}

//+------------------------------------------------------------------+
//| Alert processing.                                                |
//+------------------------------------------------------------------+
void Notify()
{
    if (!EnableNotify) return;
    if ((!SendAlert) && (!SendApp) && (!SendEmail)) return;
    
    if (UpTrend) AlertVariable = 1;
    if (DownTrend) AlertVariable = -1;
    if ((!UpTrend) && (!DownTrend)) AlertVariable = 0;
    if (LastAlertDirection == 2)
    {
        LastAlertDirection = AlertVariable; // Avoid initial alert when just attaching the indicator to the chart.
        return;
    }
    if (AlertVariable == LastAlertDirection) return; // Avoid alerting about the same signal.
    LastAlertDirection = AlertVariable;
    string TrendString = "No trend";
    if (UpTrend) TrendString = "Uptrend";
    if (DownTrend) TrendString = "Downtrend";
    if (SendAlert)
    {
        string AlertText = IndicatorName + " - " + Symbol() + " Notification: ";
        if ((!UpTrend) && (!DownTrend)) AlertText += "The Pair is NOT Trending.";
        else AlertText += "The Pair is currently in a Trend - " + TrendString + ".";
        Alert(AlertText);
    }
    if (SendEmail)
    {
        string EmailSubject = IndicatorName + " " + Symbol() + " Notification";
        string EmailBody = AccountInfoString(ACCOUNT_COMPANY) + " - " + AccountInfoString(ACCOUNT_NAME) + " - " + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) + "\r\n\r\n" + IndicatorName + " Notification for " + Symbol() + "\r\n\r\n";
        if ((!UpTrend) && (!DownTrend)) EmailBody += "The Pair is NOT Trending.";
        else EmailBody += "The Pair is currently in a Trend - " + TrendString + ".";
        if (!SendMail(EmailSubject, EmailBody)) Print("Error sending email " + IntegerToString(GetLastError()) + ".");
    }
    if (SendApp)
    {
        string AppText = AccountInfoString(ACCOUNT_COMPANY) + " - " + AccountInfoString(ACCOUNT_NAME) + " - " + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) + " - " + IndicatorName + " - " + Symbol() + " - ";
        if ((!UpTrend) && (!DownTrend)) AppText += "The Pair is NOT Trending.";
        else AppText += "The Pair is currently in a Trend - " + TrendString + ".";
        if (!SendNotification(AppText)) Print("Error sending notification " + IntegerToString(GetLastError()) + ".");
    }
}

//+------------------------------------------------------------------+
//| Draws arrow signal on a given bar.                               |
//+------------------------------------------------------------------+
void DrawArrow(int i)
{
    if ((!UpTrend) && (!DownTrend)) return;
    datetime ArrowDate = iTime(Symbol(), Period(), i);
    string ArrowName = IndicatorName + "-ARWS-" + IntegerToString(ArrowDate);
    double ArrowPrice = 0;
    ENUM_OBJECT ArrowType = 0;
    color ArrowColor = 0;
    int ArrowAnchor = 0;
    int ArrowCode = 0;
    string ArrowDesc = "";
    if (UpTrend)
    {
        ArrowPrice = iLow(Symbol(), Period(), i);
        ArrowType = OBJ_ARROW_UP;
        ArrowColor = clrGreen;
        ArrowAnchor = ANCHOR_TOP;
        ArrowDesc = "BUY";
        ArrowCode = ArrowCodeUp;
    }
    if (DownTrend)
    {
        ArrowPrice = iHigh(Symbol(), Period(), i);
        ArrowType = OBJ_ARROW_DOWN;
        ArrowColor = clrRed;
        ArrowAnchor = ANCHOR_BOTTOM;
        ArrowDesc = "SELL";
        ArrowCode = ArrowCodeDown;
    }
    ObjectCreate(0, ArrowName, ArrowType, 0, ArrowDate, 0);
    ObjectSetDouble(0, ArrowName, OBJPROP_PRICE, ArrowPrice);
    ObjectSetInteger(0, ArrowName, OBJPROP_COLOR, ArrowColor);
    ObjectSetInteger(0, ArrowName, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, ArrowName, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, ArrowName, OBJPROP_ANCHOR, ArrowAnchor);
    int SignalWidth = (int)ChartGetInteger(0, CHART_SCALE, 0);
    if (SignalWidth == 0) SignalWidth++;
    ObjectSetInteger(0, ArrowName, OBJPROP_WIDTH, SignalWidth);
    ObjectSetInteger(0, ArrowName, OBJPROP_STYLE, STYLE_SOLID);
    ObjectSetInteger(0, ArrowName, OBJPROP_BGCOLOR, ArrowColor);
    ObjectSetString(0, ArrowName, OBJPROP_TEXT, ArrowDesc);
    ObjectSetInteger(0, ArrowName, OBJPROP_ARROWCODE, ArrowCode);
}

//+------------------------------------------------------------------+
//| Main panel drawing function.                                     |
//+------------------------------------------------------------------+
void DrawPanel()
{
    string PanelBase = IndicatorName + "-P-BAS";
    string PanelLabel = IndicatorName + "-P-LAB";
    string PanelDAbove = IndicatorName + "-P-DABOVE";
    string PanelDBelow = IndicatorName + "-P-DBELOW";
    string PanelSig = IndicatorName + "-P-SIG";
    int Rows = 1;
    ObjectCreate(0, PanelBase, OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, PanelBase, OBJPROP_XDISTANCE, Xoff);
    ObjectSetInteger(0, PanelBase, OBJPROP_YDISTANCE, Yoff);
    ObjectSetInteger(0, PanelBase, OBJPROP_XSIZE, PanelRecX);
    ObjectSetInteger(0, PanelBase, OBJPROP_YSIZE, (int)MathRound(((PanelBaseButtonHeight + 2) * 1 + 2) * DPIScale));
    ObjectSetInteger(0, PanelBase, OBJPROP_BGCOLOR, White);
    ObjectSetInteger(0, PanelBase, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, PanelBase, OBJPROP_STATE, false);
    ObjectSetInteger(0, PanelBase, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, PanelBase, OBJPROP_FONTSIZE, 8);
    ObjectSetInteger(0, PanelBase, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, PanelBase, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, PanelLabel, OBJ_EDIT, 0, 0, 0);
    ObjectSetInteger(0, PanelLabel, OBJPROP_XDISTANCE, Xoff + 2);
    ObjectSetInteger(0, PanelLabel, OBJPROP_YDISTANCE, Yoff + 2);
    ObjectSetInteger(0, PanelLabel, OBJPROP_XSIZE, PanelLabX);
    ObjectSetInteger(0, PanelLabel, OBJPROP_YSIZE, PanelLabY);
    ObjectSetInteger(0, PanelLabel, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, PanelLabel, OBJPROP_STATE, false);
    ObjectSetInteger(0, PanelLabel, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, PanelLabel, OBJPROP_READONLY, true);
    ObjectSetInteger(0, PanelLabel, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, PanelLabel, OBJPROP_TOOLTIP, "MT SUPERTREND");
    ObjectSetString(0, PanelLabel, OBJPROP_TEXT, "MT SUPERTREND");
    ObjectSetString(0, PanelLabel, OBJPROP_FONT, "Consolas");
    ObjectSetInteger(0, PanelLabel, OBJPROP_FONTSIZE, 10);
    ObjectSetInteger(0, PanelLabel, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, PanelLabel, OBJPROP_COLOR, clrNavy);
    ObjectSetInteger(0, PanelLabel, OBJPROP_BGCOLOR, clrKhaki);
    ObjectSetInteger(0, PanelLabel, OBJPROP_BORDER_COLOR, clrBlack);

    for (int i = 0; i < ArraySize(TFTrend); i++)
    {
        if (!TFEnabled[i]) continue;
        string TrendRowText = IndicatorName + "-P-TREND-" + TFText[i];
        string TrendRowValue = IndicatorName + "-P-TREND-V-" + TFText[i];
        string TrendRowSTValue = IndicatorName + "-P-TREND-STV-" + TFText[i];
        string TrendDirectionText = TFText[i];
        string TrendDirectionValue = "";
        color TrendBackColor = clrKhaki;
        color TrendTextColor = clrNavy;
        if (TFTrend[i] == 0)
        {
            TrendDirectionValue = "UP";
            TrendBackColor = clrDarkGreen;
            TrendTextColor = clrWhite;
        }
        else if (TFTrend[i] == 1)
        {
            TrendDirectionValue = "DOWN";
            TrendBackColor = clrDarkRed;
            TrendTextColor = clrWhite;
        }
        else // EMPTY_VALUE
        {
            TrendDirectionValue = "-";
        }
        ObjectCreate(0, TrendRowText, OBJ_EDIT, 0, 0, 0);
        ObjectSetInteger(0, TrendRowText, OBJPROP_XDISTANCE, Xoff + 2);
        ObjectSetInteger(0, TrendRowText, OBJPROP_YDISTANCE, Yoff + (int)MathRound(((PanelBaseButtonHeight + 1) * Rows + 2) * DPIScale));
        ObjectSetInteger(0, TrendRowText, OBJPROP_XSIZE, PanelMovX);
        ObjectSetInteger(0, TrendRowText, OBJPROP_YSIZE, PanelLabY);
        ObjectSetInteger(0, TrendRowText, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, TrendRowText, OBJPROP_STATE, false);
        ObjectSetInteger(0, TrendRowText, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, TrendRowText, OBJPROP_READONLY, true);
        ObjectSetInteger(0, TrendRowText, OBJPROP_FONTSIZE, 8);
        ObjectSetString(0, TrendRowText, OBJPROP_TOOLTIP, "Trend detected on the timeframe");
        ObjectSetInteger(0, TrendRowText, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, TrendRowText, OBJPROP_FONT, "Consolas");
        ObjectSetString(0, TrendRowText, OBJPROP_TEXT, TrendDirectionText);
        ObjectSetInteger(0, TrendRowText, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, TrendRowText, OBJPROP_COLOR, clrNavy);
        ObjectSetInteger(0, TrendRowText, OBJPROP_BGCOLOR, clrKhaki);
        ObjectSetInteger(0, TrendRowText, OBJPROP_BORDER_COLOR, clrBlack);

        ObjectCreate(0, TrendRowValue, OBJ_EDIT, 0, 0, 0);
        ObjectSetInteger(0, TrendRowValue, OBJPROP_XDISTANCE, Xoff + (int)MathRound((PanelBaseButtonWidth + 4) * DPIScale));
        ObjectSetInteger(0, TrendRowValue, OBJPROP_YDISTANCE, Yoff + (int)MathRound(((PanelBaseButtonHeight + 1) * Rows + 2) * DPIScale));
        ObjectSetInteger(0, TrendRowValue, OBJPROP_XSIZE, PanelMovX);
        ObjectSetInteger(0, TrendRowValue, OBJPROP_YSIZE, PanelLabY);
        ObjectSetInteger(0, TrendRowValue, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, TrendRowValue, OBJPROP_STATE, false);
        ObjectSetInteger(0, TrendRowValue, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, TrendRowValue, OBJPROP_READONLY, true);
        ObjectSetInteger(0, TrendRowValue, OBJPROP_FONTSIZE, 8);
        ObjectSetString(0, TrendRowValue, OBJPROP_TOOLTIP, "Trend detected on the timeframe");
        ObjectSetInteger(0, TrendRowValue, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, TrendRowValue, OBJPROP_FONT, "Consolas");
        ObjectSetString(0, TrendRowValue, OBJPROP_TEXT, TrendDirectionValue);
        ObjectSetInteger(0, TrendRowValue, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, TrendRowValue, OBJPROP_COLOR, TrendTextColor);
        ObjectSetInteger(0, TrendRowValue, OBJPROP_BGCOLOR, TrendBackColor);
        ObjectSetInteger(0, TrendRowValue, OBJPROP_BORDER_COLOR, clrBlack);

        ObjectCreate(0, TrendRowSTValue, OBJ_EDIT, 0, 0, 0);
        ObjectSetInteger(0, TrendRowSTValue, OBJPROP_XDISTANCE, Xoff + (int)MathRound((PanelBaseButtonWidth * 2 + 6) * DPIScale));
        ObjectSetInteger(0, TrendRowSTValue, OBJPROP_YDISTANCE, Yoff + (int)MathRound(((PanelBaseButtonHeight + 1) * Rows + 2) * DPIScale));
        ObjectSetInteger(0, TrendRowSTValue, OBJPROP_XSIZE, PanelWB_DPI);
        ObjectSetInteger(0, TrendRowSTValue, OBJPROP_YSIZE, PanelLabY);
        ObjectSetInteger(0, TrendRowSTValue, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, TrendRowSTValue, OBJPROP_STATE, false);
        ObjectSetInteger(0, TrendRowSTValue, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, TrendRowSTValue, OBJPROP_READONLY, true);
        ObjectSetInteger(0, TrendRowSTValue, OBJPROP_FONTSIZE, 8);
        ObjectSetString(0, TrendRowSTValue, OBJPROP_TOOLTIP, "Supertrend value");
        ObjectSetInteger(0, TrendRowSTValue, OBJPROP_ALIGN, ALIGN_RIGHT);
        ObjectSetString(0, TrendRowSTValue, OBJPROP_FONT, "Consolas");
        ObjectSetString(0, TrendRowSTValue, OBJPROP_TEXT, DoubleToString(TFSTValue[i], _Digits));
        ObjectSetInteger(0, TrendRowSTValue, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, TrendRowSTValue, OBJPROP_COLOR, clrNavy);
        ObjectSetInteger(0, TrendRowSTValue, OBJPROP_BGCOLOR, clrKhaki);
        ObjectSetInteger(0, TrendRowSTValue, OBJPROP_BORDER_COLOR, clrBlack);
        
        Rows++;
    }
    string SigText = "";
    color SigColor = clrNavy;
    color SigBack = clrKhaki;
    if (UpTrend)
    {
        SigText = "Uptrend";
        SigColor = clrWhite;
        SigBack = clrDarkGreen;
    }
    if (DownTrend)
    {
        SigText = "Downtrend";
        SigColor = clrWhite;
        SigBack = clrDarkRed;
    }
    if ((!UpTrend) && (!DownTrend))
    {
        SigText = "Uncertain";
    }

    ObjectCreate(0, PanelSig, OBJ_EDIT, 0, 0, 0);
    ObjectSetInteger(0, PanelSig, OBJPROP_XDISTANCE, Xoff + 2);
    ObjectSetInteger(0, PanelSig, OBJPROP_YDISTANCE, Yoff + (int)MathRound(((PanelBaseButtonHeight + 1) * Rows + 2) * DPIScale));
    ObjectSetInteger(0, PanelSig, OBJPROP_XSIZE, PanelLabX);
    ObjectSetInteger(0, PanelSig, OBJPROP_YSIZE, PanelLabY);
    ObjectSetInteger(0, PanelSig, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, PanelSig, OBJPROP_STATE, false);
    ObjectSetInteger(0, PanelSig, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, PanelSig, OBJPROP_READONLY, true);
    ObjectSetInteger(0, PanelSig, OBJPROP_FONTSIZE, 8);
    ObjectSetInteger(0, PanelSig, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, PanelSig, OBJPROP_FONT, "Consolas");
    ObjectSetString(0, PanelSig, OBJPROP_TOOLTIP, "Trend tetected considering all timeframes");
    ObjectSetString(0, PanelSig, OBJPROP_TEXT, SigText);
    ObjectSetInteger(0, PanelSig, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, PanelSig, OBJPROP_COLOR, SigColor);
    ObjectSetInteger(0, PanelSig, OBJPROP_BGCOLOR, SigBack);
    ObjectSetInteger(0, PanelSig, OBJPROP_BORDER_COLOR, clrBlack);
    Rows++;

    ObjectSetInteger(0, PanelBase, OBJPROP_XSIZE, PanelRecX);
    ObjectSetInteger(0, PanelBase, OBJPROP_YSIZE, (int)MathRound(((PanelBaseButtonHeight + 1) * Rows + 3) * DPIScale));
}
//+------------------------------------------------------------------+