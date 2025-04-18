#property copyright   "Denis Kislitsyn"
#property link        "https://kislitsyn.me/peronal/algo"
#property description "The Chaikin Money Flow (CMF) is an indicator created by Marc Chaikin in the 1980s to monitor the accumulation and distribution of a stock over a specified period"
#property version     "1.00"
#property icon        "img\\logo\\logo_64.ico"

#property strict

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_label1  "CMF"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMaroon
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

// Paramètres d'entrée
input uint                InpCMFPeriod    = 21;           // Period
input ENUM_APPLIED_VOLUME InpVolumeType   = VOLUME_TICK;  // Volume Type

// Buffer
double         CMFBuffer[];

// Variables globales
int            CMFPeriod;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
   CMFPeriod = (InpCMFPeriod > 0) ? (int)InpCMFPeriod : 21;
   
   // Mapping du buffer
   SetIndexBuffer(0, CMFBuffer, INDICATOR_DATA);
   
   // Propriétés de l'indicateur
   IndicatorSetInteger(INDICATOR_DIGITS, 4);
   IndicatorSetString(INDICATOR_SHORTNAME, "CMF(" + IntegerToString(CMFPeriod) + ")");
   
   // Définir la ligne zéro
   IndicatorSetInteger(INDICATOR_LEVELS, 1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 0, 0.0);
   IndicatorSetString(INDICATOR_LEVELTEXT, 0, "0");
   IndicatorSetInteger(INDICATOR_LEVELCOLOR, 0, clrGray);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE, 0, STYLE_SOLID);
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   if(rates_total < CMFPeriod)
      return 0;
   
   int start = prev_calculated - 1;
   if(start < CMFPeriod) start = CMFPeriod;
   
   for(int i = start; i < rates_total && !IsStopped(); i++)
   {
      double sumAD = 0;
      double sumVolume = 0;
      
      for(int j = 0; j < CMFPeriod; j++)
      {
         int index = i - j;
         double highLowRange = high[index] - low[index];
         
         if(highLowRange > 0)
         {
            double moneyFlowMultiplier = ((close[index] - low[index]) - (high[index] - close[index])) / highLowRange;
            double moneyFlowVolume = moneyFlowMultiplier * (InpVolumeType == VOLUME_TICK ? (double)tick_volume[index] : (double)volume[index]);
            
            sumAD += moneyFlowVolume;
            sumVolume += (InpVolumeType == VOLUME_TICK ? (double)tick_volume[index] : (double)volume[index]);
         }
      }
      
      CMFBuffer[i] = (sumVolume > 0) ? sumAD / sumVolume : 0;
   }
   
   return(rates_total);
}