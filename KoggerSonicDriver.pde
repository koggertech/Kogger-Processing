class ChartContent_c {
  long StartPos_mm = 0;
  int Size = 400;
  int Resol_mm = 10;
  int Offset;
  int Period_ms = 200;
  short Data[] = new short[5000];
  short DataPos;
  Boolean DataComplete = false;
  Boolean SettingsUpdate = false;

  void SetStartPos(long start_pos_mm) {
    StartPos_mm = start_pos_mm;
  }

  long GetStartPos() {
    return StartPos_mm;
  }

  void SetResol(int resol_mm) {
    Resol_mm = resol_mm;
  }

  int GetResol() {
    return Resol_mm;
  }

  int GetSize() {
    return Size;
  }

  void SetSize(int size_chart) {
    Size = size_chart;
  }
  
  void SetPeriod(int period_ms) {
    Period_ms = period_ms;
  }
  
  int GetPeriod() {
    return Period_ms;
  }

  void SetOffset(int offset) {
    if (offset == 0 && Offset != 0) {
      Size = Offset + DataPos;
    }

    Offset = offset;

    if (Size == Offset + DataPos) {
      DataComplete = true;
    }
  }

  Boolean GetDataComlete() {
    if (DataComplete) {
      DataComplete = false;
      return true;
    }
    return false;
  }
  
   Boolean GetSettingsUpdate() {
    if (SettingsUpdate) {
      SettingsUpdate = false;
      return true;
    }
    return false;
  }

  void InitData(long start_pos_mm, int offset, int resol_mm) {
    SetStartPos(start_pos_mm);
    SetResol(resol_mm);
    SetOffset(offset);
    DataPos = 0;
  }

  void InitContent(long start_pos_mm, int size_chart, int resol_mm, int period_ms) {
    SetStartPos(start_pos_mm);
    SetResol(resol_mm);
    SetSize(size_chart);
    SetPeriod(period_ms);
    SettingsUpdate = true;
  }

  void AddData(short data) {
    Data[DataPos + Offset] = data;
    DataPos++;
  }
}

class YPRContent_c {
  float Yaw;
  float Pitch;
  float Roll;

  void Set(float yaw, float pitch, float roll) {
    Yaw = yaw;
    Pitch = pitch;
    Roll = roll;
  }
}

class AGCContent_c {
  long StartPos = 0;
  int Offset = 0;
  int Slope = 20;
  int Absorp = 0;

  void Set(long start_pos, int offset, int slope, int absorp) {
    StartPos = start_pos;
    Offset = offset;
    Slope = slope;
    Absorp = absorp;
  }

  int getStart() {
    return (int)StartPos;
  }

  int getOffset() {
    return Offset;
  }

  int getSlope() {
    return Slope;
  }

  int getAbsorp() {
    return Absorp;
  }
}

class TransContent_c {
  int Freq_khz = 670;
  short WidthPulse = 10;
  short Boost = 1;

  void Set(int freq_khz, short width_pulse, short boost) {
    Freq_khz= freq_khz;
    WidthPulse = width_pulse;
    Boost = boost;
  }

  int GetFreq() {
    return Freq_khz;
  }

  int GetWidth() {
    return WidthPulse;
  }

  int GetBoost() {
    return Boost;
  }
}

class UARTContent_c {
  long Baudrate = 115200;

  void Set(long baudrate) {
    Baudrate = baudrate;
  }

  long GetBaudrate() {
    return Baudrate;
  }
}

class KoggerSonicData_c {
  ChartContent_c Chart;
  YPRContent_c YPR;
  float Temp;
  int SoundSpeed_m_s = 1500;
  AGCContent_c AGC;
  TransContent_c Transc;
  UARTContent_c UART;

  KoggerSonicData_c() {
    Chart = new ChartContent_c();
    YPR = new YPRContent_c();
    AGC = new AGCContent_c();
    Transc = new TransContent_c();
    UART = new UARTContent_c();
  }
}

class KoggerSonicBaseDriver_c {
  BinFrameIn_c Input;
  BinFrameOut_c Output;
  KoggerSonicData_c Data;

  KoggerSonicBaseDriver_c() {
    Input = new BinFrameIn_c();
    Output = new BinFrameOut_c();
    Data = new KoggerSonicData_c();
  }

  void SetBus(Serial bus) {
    Input.SetBus(bus);
    Output.SetBus(bus);
  }

  void StopBus() {
    Input.StopBus();
    Output.StopBus();
  }

  void Process() {
    while (Input.Process()) {
      SwitchParsing();
    }
  }

  void SwitchParsing() {
    Boolean parse_answer = false;
    switch(Input.ID) {
    case CMD_ID_Chart:
      parse_answer = ParsChart();
      if (parse_answer) {
        ChartUpdateCallback();
      }
      break;
    case CMD_ID_Array:
      //ParceArray();
      break;

    case CMD_ID_YPR:
      parse_answer = ParceYPR();
      if (parse_answer) {
        YPRUpdateCallback();
      }
      break;

    case CMD_ID_TEMP:
      parse_answer = ParceTemp();
      if (parse_answer) {
        TempUpdateCallback();
      }
      break;

    case CMD_ID_AGC:
      parse_answer = ParceAGC();
      if (parse_answer) {
        AGCUpdateCallback();
      }
      break;

    case CMD_ID_TRANSC:
      parse_answer = ParceTransc();
      if (parse_answer) {
        TranscUpdateCallback();
      }
      break;

    case CMD_ID_SOUND_SPEED:
      parse_answer = ParceSoundSpeed();
      if (parse_answer) {
        SoundSpeedUpdateCallback();
      }
      break;

    case CMD_ID_UART:
      parse_answer = ParceUART();
      if (parse_answer) {
        UARTUpdateCallback();
      }
      break;

    default:
      break;
    }

    if (parse_answer) {
      ParseUpdateCallback();
    }
  }

  Boolean ParsChart() {
    if (Input.Mode == Reaction) {
      long start_pos_mm = Input.ReadU4();
      int item_offset =  Input.ReadU2();
      int item_resol_mm =  Input.ReadU2();
      int data_len = Input.GetReadAvailable();

      Data.Chart.InitData(start_pos_mm, item_offset, item_resol_mm);

      for (int i = 0; i < data_len; i++) {
        short data = (short)(Input.ReadU1());
        Data.Chart.AddData(data);
      }
    } else if (Input.Mode == Content) {
      long start_pos_mm = Input.ReadU4();
      int item_cnt =  Input.ReadU2();
      int item_resol_mm =  Input.ReadU2();
      int item_repead_ms =  Input.ReadU2();
      
      Data.Chart.InitContent(start_pos_mm, item_cnt, item_resol_mm, item_repead_ms);
    }

    return true;
  }

  Boolean ParceYPR() {
    if (Input.Mode == Content) {
      short yaw = Input.ReadS2();
      short pitch = Input.ReadS2();
      short roll = Input.ReadS2();
      Data.YPR.Set((float)yaw*0.01, (float)pitch*0.01, (float)roll*0.01);
    }
    return true;
  }

  Boolean ParceTemp() {
    if (Input.Mode == Content) {
      Data.Temp = (float)(Input.ReadS2())*0.01;
    }
    return true;
  }

  Boolean ParceSoundSpeed() {
    if (Input.Mode == Content) {
      Data.SoundSpeed_m_s = Input.ReadU2();
    }
    return true;
  }

  Boolean ParceUART() {
    if (Input.Mode == Content) {
      long uart_key = Input.ReadU4();
      int id = Input.ReadU1();
      long boudrate = Input.ReadU4();

      if (uart_key == UART_KEY) {
        if (id == 1) {
          Data.UART.Set((int)boudrate);
        }
      } else {
        return false;
      }
    }

    return true;
  }

  Boolean ParceAGC() {
    if (Input.Mode == Content) {
      long start_pos_mm = Input.ReadU4();
      short offset =  Input.ReadS2();
      int slope =  Input.ReadU2();
      int absorp = Input.ReadU2();
      Data.AGC.Set(start_pos_mm, offset, slope, absorp);
    }
    return true;
  }

  Boolean ParceTransc() {
    if (Input.Mode == Content) {
      int freq_khz = Input.ReadU2();
      short width_pulse =  Input.ReadU1();
      short boost =  Input.ReadU1();
      Data.Transc.Set(freq_khz, width_pulse, boost);
    }
    return true;
  }

  void GetChart(int start_pos_mm, int item_cnt, int item_resol_mm, int repeat_ms) {
    Output.InitData(CMD_ID_Chart, Action, false);
    Output.WriteU4(start_pos_mm);
    Output.WriteU2(item_cnt);
    Output.WriteU2(item_resol_mm);
    Output.WriteU2(repeat_ms);
    Output.WriteU4(0);
    Output.End();
  }
  
  void SetChart() {
    Output.InitData(CMD_ID_Chart, Action, false);
    Output.WriteU4(Data.Chart.GetStartPos());
    Output.WriteU2(Data.Chart.GetSize());
    Output.WriteU2(Data.Chart.GetResol());
    Output.WriteU2(Data.Chart.GetPeriod());
    Output.WriteU4(0);
    Output.End();
  }
  
  void GetChartSettings() {
    Output.InitData(CMD_ID_Chart, Getting, false);
    Output.End();
  }

  void GetYPR() {
    Output.InitData(CMD_ID_YPR, Getting, false);
    Output.End();
  }

  void GetTemp() {
    Output.InitData(CMD_ID_TEMP, Getting, false);
    Output.End();
  }

  void SetAGC(int start_pos_mm, int offset_db_1_100, int slope_1_100, int absorp_db_mm) {
    Data.AGC.Set(start_pos_mm, offset_db_1_100, slope_1_100, absorp_db_mm);
    SetAGC();
  }

  void SetAGC() {
    Output.InitData(CMD_ID_AGC, Setting, false);
    Output.WriteU4(Data.AGC.StartPos);
    Output.WriteS2((short)Data.AGC.Offset);
    Output.WriteU2(Data.AGC.Slope);
    Output.WriteU2(Data.AGC.Absorp);
    Output.WriteU4(0);
    Output.WriteU4(0);
    Output.End();
  }

  void GetAGC() {
    Output.InitData(CMD_ID_AGC, Getting, false);
    Output.End();
  }

  void SetTransc(int freq, short width_pulse, short boost) {
    Data.Transc.Set(freq, width_pulse, boost);
    SetTransc();
  }

  void SetTransc() {
    Output.InitData(CMD_ID_TRANSC, Setting, false);
    Output.WriteU2(Data.Transc.Freq_khz);
    Output.WriteU1(Data.Transc.WidthPulse);
    Output.WriteU1(Data.Transc.Boost);
    Output.WriteU4(0);
    Output.End();
  }

  void GetTransc() {
    Output.InitData(CMD_ID_TRANSC, Getting, false);
    Output.End();
  }

  void SetSoundSpeed(int sound_speed_m_s) {
    Data.SoundSpeed_m_s = sound_speed_m_s;
    SetSoundSpeed();
  }

  void SetSoundSpeed() {
    Output.InitData(CMD_ID_SOUND_SPEED, Setting, false);
    Output.WriteU2(Data.SoundSpeed_m_s);
    Output.WriteU4(0); // Reseved
    Output.End();
  }

  void GetSoundSpeed() {
    Output.InitData(CMD_ID_SOUND_SPEED, Getting, false);
    Output.End();
  }

  void SetUART(long boudrate) {
    Data.UART.Set(boudrate);
    SetUART();
  }

  void SetUART() {
    Output.InitData(CMD_ID_UART, Setting, false);
    Output.WriteU4(UART_KEY);
    Output.WriteU1((short)1);
    Output.WriteU4(Data.UART.Baudrate);
    Output.WriteU4(0); // Reseved
    Output.End();
  }

  void GetUART() {
    Output.InitData(CMD_ID_UART, Getting, false);
    Output.WriteU4(UART_KEY);
    Output.WriteU1((short)1);
    Output.End();
  }

  void FlashAllSatting() {
    Output.InitData(CMD_ID_FLASH_SET, Action, false);
    Output.WriteU4(UART_KEY);
    Output.WriteU4(0);
    Output.End();
  }

  void ReadAllSettings() {
    GetChartSettings();
    GetAGC();
    GetTransc();
    GetSoundSpeed();
    GetUART();
  }

  void WriteAllSettings() {
    CopyDataFromSource();
    SetChart();
    SetAGC();
    SetTransc();
    SetSoundSpeed();
    SetUART();
  }

  void ChartUpdateCallback() {
  }
  void YPRUpdateCallback() {
  }
  void TempUpdateCallback() {
  }
  void SoundSpeedUpdateCallback() {
  }
  void AGCUpdateCallback() {
  }
  void TranscUpdateCallback() {
  }
  void UARTUpdateCallback() {
  }
  void ParseUpdateCallback() {
  }
  
  void CopyDataFromSource() {
  }
}
