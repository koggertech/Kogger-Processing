final short CMD_ID_Chart = 10;
final short CMD_ID_Array = 11;
final short CMD_ID_YPR = 12;
final short CMD_ID_QUAT = 13;
final short CMD_ID_TEMP = 14;
final short CMD_ID_AGC = 20;
final short CMD_ID_TRANSC = 21;
final short CMD_ID_SOUND_SPEED = 22;
final short CMD_ID_UART = 0x17;
final short CMD_ID_FLASH_SET = 0x1D;

final short Error = 0;
final short Confirm = 1;
final short Setting = 2;
final short Getting = 3;
final short Content = 4;
final short Action = 5;
final short Reaction = 6;

final long UART_KEY = 0xC96B5D4A;

enum  ProtoFrameState_e {
  StateSync1, 
    StateSync2, 
    StateLength1, 
    StateMode, 
    StateID, 
    StatePayload, 
    StateCRCA, 
    StateCRCB
};

class BinFrameIn_c {
  char Payload[] = new char[128];
  ProtoFrameState_e State;
  short PayloadLen;
  short PayloadOffset;
  short PayloadReadPos;
  char FieldCheckSumA;
  char FieldCheckSumB;
  char PayloadCheckSumA;
  char PayloadCheckSumB;
  int Format;
  int Mode;
  short Ver;
  int ErrorNbr;
  int ID;
  Serial Bus;

  BinFrameIn_c() {
    ResetState();
  }

  void SetBus(Serial bus) {
    Bus = bus;
  }

  void StopBus() {
    Bus.stop();
  }

  Boolean Process() {
    while (Bus != null && Bus.available() != 0) {
      if (PushByte(Bus.readChar())) {
        return true;
      }
    }
    return false;
  }

  Boolean PushByte(char b) {
    Boolean payload_complete = false;
    switch (State) {
    case StateSync1:
      if (b == 0xBB) {
        State = ProtoFrameState_e.StateSync2;
      }
      break;

    case StateSync2:
      if (b == 0x55) {
        State = ProtoFrameState_e.StateLength1;
      } else {
        State = ProtoFrameState_e.StateSync1;
      }
      break;

    case StateLength1:
      PayloadLen = (short)b;
      if (PayloadLen > 128) {
        ResetStateAsError();
      }
      CheckSumUpdate(b);
      State = ProtoFrameState_e.StateMode;
      break;

    case StateMode:
      Format = b;
      Mode = (Format & 0x7);
      CheckSumUpdate(b);
      State = ProtoFrameState_e.StateID;
      break;

    case StateID:
      ID = b;
      CheckSumUpdate(b);
      if (PayloadLen > 0) {
        State = ProtoFrameState_e.StatePayload;
        PayloadOffset = 0;
      } else {
        State = ProtoFrameState_e.StateCRCA;
      }
      break;

    case StatePayload:
      if (PayloadOffset < 128) {
        Payload[PayloadOffset] = b;
        CheckSumUpdate(b);
        PayloadOffset++;
        if (PayloadOffset >= PayloadLen) {
          State = ProtoFrameState_e.StateCRCA;
        }
      } else {
        ResetStateAsError();
      }
      break;

    case StateCRCA:
      State = ProtoFrameState_e.StateCRCB;
      FieldCheckSumA = b;
      break;

    case StateCRCB:
      FieldCheckSumB = b;

      if (CheckSummCheck()) {
        payload_complete = true;
        State = ProtoFrameState_e.StateSync1;
        ResetState();
      } else {
        ResetStateAsError();
      }
      break;
    }

    return payload_complete;
  }

  void PayloadCalckCheckSum() {
    for (int i = 0; i < PayloadLen; i++) {
      CheckSumUpdate((char)Payload[i]);
    }
  }

  void ResetState() {
    PayloadOffset = 0;
    PayloadReadPos = 0;
    State = ProtoFrameState_e.StateSync1;
    CheckSumReset();
  }

  void ResetStateAsError() {
    ErrorNbr++;
    ResetState();
  }

  void CheckSumUpdate(char b) {
    PayloadCheckSumA += b;
    PayloadCheckSumA &= 0xFF;
    PayloadCheckSumB += PayloadCheckSumA;
    PayloadCheckSumB &= 0xFF;
  }

  void CheckSumReset() {
    PayloadCheckSumA = 0;
    PayloadCheckSumB = 0;
  }

  Boolean CheckSummCheck() {
    if (FieldCheckSumA == PayloadCheckSumA && FieldCheckSumB == PayloadCheckSumB) {
      return true;
    } else {
      return false;
    }
  }

  short ReadU1() {
    short u1 = (short)Payload[PayloadReadPos];
    PayloadReadPos += 1;
    u1 &=0xFF;
    return u1;
  }

  int ReadU2() {
    short b1 = ReadU1();
    short b2 = ReadU1();

    return (b1) | (b2 << 8);
  }

  short ReadS2() {
    short b1 = ReadU1();
    short b2 = (short)(ReadU1() << 8);

    return (short)(b1 | b2);
  }

  long ReadU4() {
    int b1 = ReadU1();
    int b2 = ReadU1();
    int b3 = ReadU1();
    int b4 = ReadU1();

    return (b1) | (b2 << 8) | (b3 << 16) | (b4 << 24);
  }

  int ReadS4() {
    int b1 = ReadU1();
    int b2 = ReadU1();
    int b3 = ReadU1();
    int b4 = ReadU1();

    return (b1) | (b2 << 8) | (b3 << 16) | (b4 << 24);
  }

  short GetPayloadLen() {
    return PayloadLen;
  }

  short GetPayloadReadPos() {
    return PayloadReadPos;
  }

  short GetReadAvailable() {
    return (short)(GetPayloadLen() - GetPayloadReadPos());
  }
}

class BinFrameOut_c {
  int DataSize = 0;
  int DataFilled = 0;
  int PayloadCheckSumA = 0;
  int PayloadCheckSumB = 0;
  Serial Bus;

  BinFrameOut_c() {
  }

  void SetBus(Serial bus) {
    Bus = bus;
  }

  void StopBus() {
    Bus.stop();
  }

  Boolean End() {
    WriteCheckSum();
    return true;
  }

  void WriteCheckSum() {
    Write1B(PayloadCheckSumA, false);
    Write1B(PayloadCheckSumB, false);
  }

  void WriteU1(short val) {
    if (Bus == null) return;
    byte data[] = new byte[1];
    data[0] = (byte)(val & 0xFF);
    Bus.write(data);
    CheckSumUpdate(data);
    DataFilled += 1;
  }

  void WriteU2(int val) {
    if (Bus == null) return;
    byte data[] = new byte[2];
    data[0] = (byte)(val & 0xFF);
    data[1] = (byte)((val & 0xFF00) >> 8);
    Bus.write(data);
    CheckSumUpdate(data);
    DataFilled += 2;
  }

  void WriteS2(short val) {
    if (Bus == null) return;
    byte data[] = new byte[2];
    data[0] = (byte)(val & 0xFF);
    data[1] = (byte)((val & 0xFF00) >> 8);
    Bus.write(data);
    CheckSumUpdate(data);
    DataFilled += 2;
  }

  void WriteU4(long val) {
    if (Bus == null) return;
    byte data[] = new byte[4];
    data[0] = (byte)(val & 0xFF);
    data[1] = (byte)((val & 0xFF00) >> 8);
    data[2] = (byte)((val & 0xFF0000) >> 16);
    data[3] = (byte)((val & 0xFF000000) >> 24);
    Bus.write(data);
    CheckSumUpdate(data);
    DataFilled += 4;
  }

  void WriteS4(int val) {
    if (Bus == null) return;
    byte data[] = new byte[4];

    data[0] = (byte)(val & 0xFF);
    data[1] = (byte)((val & 0xFF00) >> 8);
    data[2] = (byte)((val & 0xFF0000) >> 16);
    data[3] = (byte)((val & 0xFF000000) >> 24);
    Bus.write(data);
    CheckSumUpdate(data);
    DataFilled += 4;
  }

  void Write4B(long val, Boolean update_checksum) {
    if (Bus == null) return;
    byte data[] = new byte[4];

    data[0] = (byte)(val & 0xFF);
    data[1] = (byte)((val & 0xFF00) >> 8);
    data[2] = (byte)((val & 0xFF0000) >> 16);
    data[3] = (byte)((val & 0xFF000000) >> 24);
    Bus.write(data);

    if (update_checksum) {
      CheckSumUpdate(data);
    }

    DataFilled += 4;
  }

  void Write1B(int val, Boolean update_checksum) {
    if (Bus == null) return;
    byte data = (byte)(val & 0xFF);
    Bus.write(data);

    if (update_checksum) {
      CheckSumUpdate(data);
    }

    DataFilled += 1;
  }

  void CheckSumUpdate(byte b[]) {
    for (int i = 0; i < b.length; i++) {
      CheckSumUpdate(b[i]);
    }
  }

  void CheckSumUpdate(byte b) {
    PayloadCheckSumA += b;
    PayloadCheckSumA &= 0xFF;
    PayloadCheckSumB += PayloadCheckSumA;
    PayloadCheckSumB &= 0xFF;
  }

  void CheckSumReset() {
    PayloadCheckSumA = 0;
    PayloadCheckSumB = 0;
  }

  void InitData(short id, short mode, Boolean debug) {
    short len = 0;
    switch(id) {
    case CMD_ID_Chart:
      if (mode == Action) {
        len = 14;
      } else if (mode == Getting) {
        len = 0;
      }
      break;
    case CMD_ID_Array:
      if (mode == Action) {
        len = 20;
      } else if (mode == Getting) {
        len = 0;
      }
      break;
    case CMD_ID_YPR:
      if (mode == Getting) {
        len = 0;
      }
      break;
    case CMD_ID_TEMP:
      if (mode == Getting) {
        len = 0;
      }
      break;
    case CMD_ID_QUAT:
      if (mode == Getting) {
        len = 0;
      }
      break;
    case CMD_ID_AGC:
      if (mode == Getting) {
        len = 0;
      } else if (mode == Setting) {
        len = 18;
      }
      break;
    case CMD_ID_TRANSC:
      if (mode == Getting) {
        len = 0;
      } else if (mode == Setting) {
        len = 8;
      }
      break;
    case CMD_ID_SOUND_SPEED:
      if (mode == Getting) {
        len = 0;
      } else if (mode == Setting) {
        len = 6;
      }
      break;
    case CMD_ID_UART:
      if (mode == Getting) {
        len = 5;
      } else if (mode == Setting) {
        len = 13;
      }
      break;

    case CMD_ID_FLASH_SET:
      if (mode == Action) {
        len = 8;
      }
      break;
    }
    InitData(id, mode, (short)0, debug, len);
  }

  void InitData(short id, short mode, short version, Boolean debug, short len) {
    CheckSumReset();
    Write1B(0xBB, false);
    Write1B(0x55, false);
    WriteU1(len);
    short param = (short)((mode & 0x7) | ((version & 0x3) << 3));
    WriteU1(param);
    WriteU1(id);
  }
}
