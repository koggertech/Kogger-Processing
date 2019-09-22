class KS_DriverExample_c extends KoggerSonicBaseDriver_c {
  Boolean LogChartEnable;
  PrintWriter LogChart;
  String LogDir = "/logs/";

  String GetLogFileID() {
    int d = day();    // Values from 1 - 31
    int m = month();  // Values from 1 - 12
    int y = year();   // 2003, 2004, 2005, etc.
    int s = second();  // Values from 0 - 59
    int min = minute();  // Values from 0 - 59
    int h = hour();    // Values from 0 - 23

    return String.valueOf(d) + "-" + String.valueOf(m) + "-" + String.valueOf(y) + "_" + String.valueOf(h) + "-" + String.valueOf(min) + "-" + String.valueOf(s);
  }

  void LogChart() {
    if (LogChartEnable) {
      if (LogChart == null) {
        LogChart = createWriter(LogDir + "LogChart_" + GetLogFileID() + ".csv");
      }

      String str_to_log = new String();
      str_to_log += millis()  + ";"; // Add timestamp
      str_to_log += Data.YPR.Yaw  + ";" + Data.YPR.Pitch  + ";"  + Data.YPR.Roll + ";"; // Add attitude
      str_to_log += Data.Chart.GetStartPos() + ";" + Data.Chart.GetResol() + ";" + Data.Chart.GetSize() + ";"; // Add chart settings
      for (int i = 0; i < Data.Chart.GetSize(); i++) {
        str_to_log += (Data.Chart.Data[i]) + ";";
      }
      LogChart.println(str_to_log);
      LogChart.flush();
    }
  }


  void SetLogChartEnable(Boolean enable) {
    LogChartEnable = enable;
  }

  void ChartUpdateCallback() {
    if (Data.Chart.GetDataComlete()) {
      LogChart();

      int[] val_chart = new int[5000];
      for (int i = 0; i < Data.Chart.GetSize(); i++) {
        val_chart[i] = Data.Chart.Data[i];
      }

      VTimeChart.PushData(val_chart, Data.Chart.GetSize(), (int)Data.Chart.GetStartPos(), Data.Chart.GetResol());

      //GetYPR();
      //GetTemp();
    }

    if (Data.Chart.GetSettingsUpdate()) {
      SliderChartCount.setValue(Data.Chart.GetSize());
      SliderChartResol.setValue(Data.Chart.GetResol()/10);
      SliderChartStart.setValue((int)(Data.Chart.GetStartPos()/1000));
      SliderChartPeriod.setValue((int)(Data.Chart.GetPeriod()));
    }
  }

  void YPRUpdateCallback() {

  }

  void TempUpdateCallback() {
    //Temp = Data.Temp;
  }

  void SoundSpeedUpdateCallback() {
  }

  void AGCUpdateCallback() { 
    SliderAGCOffset.setValue((float)(Data.AGC.getOffset())/100);
    SliderAGCAbsorp.setValue((float)(Data.AGC.getAbsorp())/1000);
    SliderAGCStart.setValue((float)(Data.AGC.getStart())/1000);
    SliderAGCSlope.setValue((float)Data.AGC.getSlope()/10);
  }

  void TranscUpdateCallback() {
    SliderTranscFreq.setValue(Data.Transc.GetFreq());
    SliderTranscWidth.setValue(Data.Transc.GetWidth());
    ToogleTranscBoost.setValue(Data.Transc.GetBoost());
  }

  void UARTUpdateCallback() {
  }

  void ParseUpdateCallback() {
  }

  void CopyDataFromSource() {
    Data.Chart.SetSize((int)SliderChartCount.getValue());
    Data.Chart.SetResol((int)SliderChartResol.getValue()*10);
    Data.Chart.SetStartPos((int)SliderChartStart.getValue()*1000);
    Data.Chart.SetPeriod((int)SliderChartPeriod.getValue());

    Data.AGC.Set((int)SliderAGCStart.getValue()*1000, (int)SliderAGCOffset.getValue()*100, (int)SliderAGCSlope.getValue()*10, (int)SliderAGCAbsorp.getValue()*1000);

    Data.Transc.Set((int)SliderTranscFreq.getValue(), (short)SliderTranscWidth.getValue(), (short)ToogleTranscBoost.getValue());

    if (SerialBaudrate != -1) {
      Data.UART.Set(SerialBaudrate);
    }
  }
}
