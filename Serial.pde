import processing.serial.*; // For Windows
//import io.inventit.processing.android.serial.*; // For Android

Serial Port;
int SerialPortNbr = -1;
int SerialBaudrate = -1;

int Baudrate[] = new int[8];

String GetPortList()[] {
  return Serial.list(); // For Windows
}

Boolean ConnectToPort(int id, int baudrate) {
  Port = new Serial(this, Serial.list()[id], baudrate);
  return true;
}

Boolean DisConnectToPort() {
  Port.stop();
  return true;
}
