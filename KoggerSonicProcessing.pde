KS_DriverExample_c KoggerSonicDriver;
TimeChart_c VTimeChart;

void setup() {
  //orientation(LANDSCAPE);
  //fullScreen(P3D); // for android
  //size(displayWidth, displayHeight, P3D);
  size(1600, 1000, JAVA2D);
  //surface.setResizable(true);
  frameRate(20);

  noStroke();
  GUI();

  KoggerSonicDriver = new KS_DriverExample_c();
  KoggerSonicDriver.SetLogChartEnable(true);
  VTimeChart = new TimeChart_c(0, 0, width, height, 1000, 2);

  Baudrate[0] = 38400;
  Baudrate[1] = 57600;
  Baudrate[2] = 115200;
  Baudrate[3] = 230400;
  Baudrate[4] = 460800;
  Baudrate[5] = 921600;
}

void ClearWindow() {
  colorMode(RGB, 255);
  background(220);
}

float avrg_chart_data = 0;
int max_chart_data = 0;

void draw() {
  ClearWindow();

  KoggerSonicDriver.Process();
  VTimeChart.Draw();
  
  
  int last_chart_elem = KoggerSonicDriver.Data.Chart.Data[KoggerSonicDriver.Data.Chart.Size - 1];
  
  avrg_chart_data = avrg_chart_data*0.95 + (float)(last_chart_elem)*0.05;
  if(max_chart_data < last_chart_elem) {
    max_chart_data = last_chart_elem;
  }
  
  AvrgVal.setText("Cur: " + last_chart_elem + "\nAvrg: " + avrg_chart_data  + "\nMax: " + max_chart_data);
}

void keyPressed() {
  if (keyCode == ENTER) {
    SaveScreen();
  }
}

void SaveScreen() {
  int d = day();    // Values from 1 - 31
  int m = month();  // Values from 1 - 12
  int y = year();   // 2003, 2004, 2005, etc.
  int s = second();  // Values from 0 - 59
  int min = minute();  // Values from 0 - 59
  int h = hour();    // Values from 0 - 23
  int mills = millis() % 1000;

  String file_name = String.valueOf(d) + "-" + String.valueOf(m) + "-" + String.valueOf(y) + "_" + String.valueOf(h) + "-" + String.valueOf(min) + "-" + String.valueOf(s) + "-" + String.valueOf(mills);
  save("/screen/" + file_name + ".jpg");
}
