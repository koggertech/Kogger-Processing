import controlP5.*;

ControlP5 cp5;
Accordion accordion;

int gui_block_width = 300;
int gui_controll_thickness = 30;
int gui_controll_step = 50;
int gui_control_offset = 30;
int gui_control_offset_calc = gui_control_offset;
int gui_bar_thickness = 30;
int gui_controll_x_offset = 20;
int gui_controll_len = gui_block_width - gui_controll_x_offset*2;


ControlFont guiFontBase;

Group GroupConnection;
Button BoottonWriteToRAM;
Button BoottonWriteToFLASH;
DropdownList ListSerialPort;
DropdownList ListSerialBaudrate;
Toggle ToggleConnect;
Button BoottonUpdatePort;

Group GroupChart;
Slider SliderChartCount;
Slider SliderChartResol;
Slider SliderChartStart;
Slider SliderChartPeriod;

Group GroupTransceiver;
Slider SliderTranscFreq;
Slider SliderTranscWidth;
Toggle ToogleTranscBoost;

Group GroupAGC;
Slider SliderAGCOffset;
Slider SliderAGCStart;
Slider SliderAGCAbsorp;
Slider SliderAGCSlope;

Group GroupIMU;
Toggle ToogleIMUChart;

Group GroupLog;
Toggle ToogleLogChart;

Button BoottonHideMenu;

Textlabel AvrgVal;

void GUI() {
  cp5 = new ControlP5(this);

  PFont pfont = createFont("Arial", 20, true); // use true/false for smooth/no-smooth
  guiFontBase = new ControlFont(pfont, 25);

  AddGroupConnection();
  AddGroupChart();
  AddGroupTransceiver();
  AddGroupAGC();
  AddGroupIMU();
  AddGroupLog();

  AvrgVal = cp5.addTextlabel("AvrgLabel")
    .setText("Avrg\rere")
    .setPosition(width - 120, height - 100)
    .setColorValue(0xffffff00)
    .setFont(createFont("Georgia", 20))
    ;

  accordion = cp5.addAccordion("gui_menu")
    .setPosition(0, 0)
    .setWidth(gui_block_width)
    .addItem(GroupConnection)
    .addItem(GroupChart)
    .addItem(GroupTransceiver)
    .addItem(GroupAGC)
    .addItem(GroupIMU)
    .addItem(GroupLog)
    ;
  accordion.setCollapseMode(Accordion.SINGLE);

  BoottonHideMenu = cp5.addButton("button_hide_menu")
    .setPosition(gui_block_width + gui_controll_x_offset, 0)
    .setLabel("hide menu")
    ;
  ButtonCustomStyle(BoottonHideMenu);

  //cp5.setAutoDraw(false);
}

void SliderCustomStyle(Slider slider) {
  slider.setFont(guiFontBase);
  //slider.setSliderMode(Slider.FLEXIBLE);
  slider.setSize(gui_controll_len, gui_controll_thickness);
  slider.getValueLabel().align(ControlP5.RIGHT, ControlP5.CENTER).setPaddingX(5);
  slider.getCaptionLabel().align(ControlP5.LEFT, ControlP5.CENTER).setPaddingX(5);
}

void ToggleCustomStyle(Toggle toggle) {
  toggle.setFont(guiFontBase);
  toggle.setSize(gui_controll_len, gui_controll_thickness);
  toggle.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(5);
}

void DropdownListCustomStyle(DropdownList dlist) {
  dlist.setItemHeight(gui_controll_thickness);
  dlist.setBarHeight(gui_controll_thickness);
  dlist.setFont(guiFontBase);
  dlist.getCaptionLabel().getStyle().marginTop = 8;
  dlist.getValueLabel().getStyle().marginTop = 8;
}

void ButtonCustomStyle(Button button) {
  button.setSize(gui_controll_len, gui_controll_thickness);
  button.setFont(guiFontBase);
}

void GroupCustomStyle(Group groupe) {
  groupe.setBackgroundColor(color(0, 64));
  groupe.setBackgroundHeight(150);
  groupe.setPosition(0, 0);
  groupe.setBarHeight(gui_bar_thickness);
  groupe.setFont(guiFontBase);
  groupe.setSize(100, 250);
  groupe.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(5);
}

void AddGroupConnection() {
  gui_control_offset_calc = gui_control_offset;

  GroupConnection = cp5.addGroup("group_connection");
  GroupConnection.setLabel("connection");
  GroupCustomStyle(GroupConnection);

  BoottonWriteToRAM = cp5.addButton("button_write_ram")
    .setPosition(gui_controll_x_offset, gui_control_offset_calc)
    .setLabel("write ram")
    .moveTo(GroupConnection)
    ;
  ButtonCustomStyle(BoottonWriteToRAM);

  gui_control_offset_calc += gui_controll_step;
  BoottonWriteToFLASH = cp5.addButton("button_write_flash")
    .setPosition(gui_controll_x_offset, gui_control_offset_calc)
    .setLabel("save to flash")
    .moveTo(GroupConnection)
    ;
  ButtonCustomStyle(BoottonWriteToFLASH);

  gui_control_offset_calc += gui_controll_step;
  ToggleConnect = cp5.addToggle("switch_connect")
    .setPosition(gui_controll_x_offset, gui_control_offset_calc)
    .setLabel("connect")
    .moveTo(GroupConnection)
    ;
  ToggleCustomStyle(ToggleConnect);

  gui_control_offset_calc += gui_controll_step;
  BoottonUpdatePort = cp5.addButton("button_update_port")
    .setPosition(gui_controll_x_offset, gui_control_offset_calc)
    .setLabel("update ports")
    .moveTo(GroupConnection)
    ;
  ButtonCustomStyle(BoottonUpdatePort);

  gui_control_offset_calc += gui_controll_step;

  ListSerialPort = cp5.addDropdownList("dlist_serialport")
    .setPosition(gui_controll_x_offset, gui_control_offset_calc)
    .setSize(gui_controll_len / 2 - gui_controll_x_offset/2, gui_controll_thickness*4)
    .setLabel("port")
    .moveTo(GroupConnection)
    .setOpen(true)
    ;
  DropdownListCustomStyle(ListSerialPort);

  //ListSerialPort.clear();
  //String serial_list[] = GetPortList();
  //int serial_list_len = serial_list.length;

  //for (int i = 0; i < serial_list_len; i++) {
  //  ListSerialPort.addItem(serial_list[i], i + 2);
  // }

  ListSerialBaudrate = cp5.addDropdownList("dlist_baudrate")
    .setPosition(gui_controll_x_offset + gui_controll_len/2 + gui_controll_x_offset/2, gui_control_offset_calc)
    .setSize(gui_controll_len/2 - gui_controll_x_offset/2, gui_controll_thickness*4)
    .setLabel("rate")
    .moveTo(GroupConnection)
    .addItem("38400", 0)
    .addItem("57600", 1)
    .addItem("115200", 1)
    .addItem("230400", 0)
    .addItem("460800", 1)
    .addItem("921600", 1)
    .setOpen(true)
    ;

  DropdownListCustomStyle(ListSerialBaudrate);

  gui_control_offset_calc += gui_controll_step;
  gui_control_offset_calc += gui_controll_step;

  GroupConnection.setSize(gui_block_width, gui_control_offset_calc + gui_controll_thickness + gui_control_offset);
}

void AddGroupChart() {
  gui_control_offset_calc = gui_control_offset;

  GroupChart = cp5.addGroup("group_chart");
  GroupChart.setLabel("chart");
  GroupCustomStyle(GroupChart);

  SliderChartCount = cp5.addSlider("slider_chart_count")
    .setPosition(gui_controll_x_offset, gui_control_offset_calc)
    .setRange(100, 5000)
    .setValue(500)
    .setNumberOfTickMarks(50)
    .setLabel("count")
    .moveTo(GroupChart)
    ;
  SliderCustomStyle(SliderChartCount);

  gui_control_offset_calc += gui_controll_step;
  SliderChartResol = cp5.addSlider("slider_chart_resol")
    .setPosition(gui_controll_x_offset, gui_control_offset_calc)
    .setRange(1, 10)
    .setValue(1)
    .setNumberOfTickMarks(10)
    .setLabel("resol, cm")
    .moveTo(GroupChart)
    ;
  SliderCustomStyle(SliderChartResol);

  gui_control_offset_calc += gui_controll_step;
  SliderChartStart = cp5.addSlider("slider_chart_start")
    .setPosition(gui_controll_x_offset, gui_control_offset_calc)
    .setRange(0, 10)
    .setValue(0)
    .setNumberOfTickMarks(11)
    .setLabel("start, m")
    .moveTo(GroupChart)
    ;
  SliderCustomStyle(SliderChartStart);


  gui_control_offset_calc += gui_controll_step;
  SliderChartPeriod = cp5.addSlider("slider_chart_period")
    .setPosition(gui_controll_x_offset, gui_control_offset_calc)
    .setRange(0, 1000)
    .setValue(100)
    .setNumberOfTickMarks(101)
    .setLabel("period, ms")
    .moveTo(GroupChart)
    ;
  SliderCustomStyle(SliderChartPeriod);

  GroupChart.setSize(gui_block_width, gui_control_offset_calc + gui_controll_thickness + gui_control_offset);
}

void AddGroupTransceiver() {
  gui_control_offset_calc = gui_control_offset;

  GroupTransceiver = cp5.addGroup("group_transceiver");
  GroupTransceiver.setLabel("transceiver");
  GroupCustomStyle(GroupTransceiver);

  SliderTranscFreq = cp5.addSlider("slider_trans_freq")
    .setPosition(gui_controll_x_offset, gui_control_offset_calc)
    .setRange(300, 800)
    .setValue(675)
    .setNumberOfTickMarks(101)
    .setLabel("freq, kHz")
    .moveTo(GroupTransceiver)
    ;
  SliderCustomStyle(SliderTranscFreq);

  gui_control_offset_calc += gui_controll_step;
  SliderTranscWidth = cp5.addSlider("slider_trans_width")
    .setPosition(gui_controll_x_offset, gui_control_offset_calc)
    .setRange(0, 30)
    .setValue(10)
    .setNumberOfTickMarks(16)
    .setLabel("width")
    .moveTo(GroupTransceiver)
    ;
  SliderCustomStyle(SliderTranscWidth);


  gui_control_offset_calc += gui_controll_step;
  ToogleTranscBoost = cp5.addToggle("switch_trans_boost")
    .setPosition(gui_controll_x_offset, gui_control_offset_calc)
    .setLabel("boost")
    .moveTo(GroupTransceiver)
    ;
  ToggleCustomStyle(ToogleTranscBoost);

  GroupTransceiver.setSize(gui_block_width, gui_control_offset_calc + gui_controll_thickness + gui_control_offset);
}

void AddGroupAGC() {
  gui_control_offset_calc = gui_control_offset;

  GroupAGC = cp5.addGroup("group_agc");
  GroupAGC.setLabel("agc");
  GroupCustomStyle(GroupAGC);

  SliderAGCOffset = cp5.addSlider("slider_agc_offset")
    .setPosition(gui_controll_x_offset, gui_control_offset_calc)
    .setRange(-48, 48)
    .setValue(0)
    .setNumberOfTickMarks(17)
    .setLabel("offset")
    .moveTo(GroupAGC)
    ;
  SliderCustomStyle(SliderAGCOffset);

  gui_control_offset_calc += gui_controll_step;
  SliderAGCAbsorp = cp5.addSlider("slider_agc_absorp")
    .setPosition(gui_controll_x_offset, gui_control_offset_calc)
    .setRange(0, 2)
    .setValue(0)
    .setNumberOfTickMarks(21)
    .setLabel("absorp, db/m")
    .moveTo(GroupAGC)
    ;
  SliderCustomStyle(SliderAGCAbsorp);

  gui_control_offset_calc += gui_controll_step;
  SliderAGCStart = cp5.addSlider("slider_agc_start")
    .setPosition(gui_controll_x_offset, gui_control_offset_calc)
    .setRange(0.5, 10)
    .setValue(1)
    .setNumberOfTickMarks(20)
    .setLabel("start, m")
    .moveTo(GroupAGC)
    ;
  SliderCustomStyle(SliderAGCStart);

  gui_control_offset_calc += gui_controll_step;
  SliderAGCSlope = cp5.addSlider("slider_agc_slope")
    .setPosition(gui_controll_x_offset, gui_control_offset_calc)
    .setRange(1, 2)
    .setValue(2)
    .setNumberOfTickMarks(2)
    .setLabel("slope")
    .moveTo(GroupAGC)
    ;
  SliderCustomStyle(SliderAGCSlope);

  GroupAGC.setSize(gui_block_width, gui_control_offset_calc + gui_controll_thickness + gui_control_offset);
}

void AddGroupIMU() {
  gui_control_offset_calc = gui_control_offset;

  GroupIMU = cp5.addGroup("group_imu");
  GroupIMU.setLabel("imu");
  GroupCustomStyle(GroupIMU);

  ToogleIMUChart = cp5.addToggle("toggle_imu_chart")
    .setPosition(gui_controll_x_offset, gui_control_offset_calc)
    .setLabel("Get with chart")
    .moveTo(GroupIMU)
    ;
  ToggleCustomStyle(ToogleIMUChart);

  GroupIMU.setSize(gui_block_width, gui_control_offset_calc + gui_controll_thickness + gui_control_offset);
}

void AddGroupLog() {
  gui_control_offset_calc = gui_control_offset;

  GroupLog = cp5.addGroup("group_log");
  GroupLog.setLabel("log");
  GroupCustomStyle(GroupLog);

  ToogleLogChart = cp5.addToggle("toggle_log_chart")
    .setPosition(gui_controll_x_offset, gui_control_offset_calc)
    .setLabel("log chart")
    .moveTo(GroupLog)
    ;
  ToggleCustomStyle(ToogleLogChart);

  GroupLog.setSize(gui_block_width, gui_control_offset_calc + gui_controll_thickness + gui_control_offset);
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isGroup()) {
    // check if the Event was triggered from a ControlGroup
    //println("event from group : "+theEvent.getGroup().getValue()+" from "+theEvent.getGroup());
  } else if (theEvent.isController()) {
    println("event from controller : "+theEvent.getController().getValue()+" from "+theEvent.getController());
  }
}

void slider_chart_count(int theColor) {
  println("a slider event. setting background to "+theColor);
}

void dlist_serialport(int nbr_item) {
  SerialPortNbr = nbr_item;
  println("Nbr serial:  "+nbr_item);
}

void dlist_baudrate(int nbr_item) {
  SerialBaudrate = Baudrate[nbr_item];
  println("Set baudrate:  " + SerialBaudrate);
}

void switch_connect(int connect) {
  println("connect:  "+connect);
  if (SerialPortNbr != -1 && SerialBaudrate != -1) {
    if (connect > 0) {
      if (ConnectToPort(SerialPortNbr, SerialBaudrate)) {
        KoggerSonicDriver.SetBus(Port);
        KoggerSonicDriver.ReadAllSettings();
      } else {
        println("connect:  error");
      }
    } else {
      DisConnectToPort();
    }
  } else if (connect == 1) {
    ToggleConnect.setState(false);
  }
}

void button_update_port() {
  ListSerialPort.clear();
  String serial_list[] = GetPortList();
  int serial_list_len = serial_list.length;

  for (int i = 0; i < serial_list_len; i++) {
    ListSerialPort.addItem(serial_list[i], i + 2);
  }
}

void button_hide_menu() {
  if (accordion.isVisible()) {
    accordion.setVisible(false);
    BoottonHideMenu.setPosition(0, 0);
    BoottonHideMenu.setLabel("show menu");
  } else {
    accordion.setVisible(true);
    BoottonHideMenu.setPosition(gui_block_width + gui_controll_x_offset, 0);
    BoottonHideMenu.setLabel("hide menu");
  }
}

void button_write_ram() {
  KoggerSonicDriver.WriteAllSettings();
}

void button_write_flash() {
  KoggerSonicDriver.FlashAllSatting();
}
