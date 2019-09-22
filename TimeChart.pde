class TimeChart_c {
  int data_pos = 0;
  int TimeCnt = 0;
  int WidthLineTimeChart = 0;
  int WidthLineLastChart = 0;

  int X, Y, W, H;

  PImage ImgCashTimeChart[];
  PImage ImgCashLastChart;

  int DataTimeChart[][];
  int DataLastChart[];
  int DataLastLen;
  int StartPosLast;
  int ResolLast;
  int TimeChartPrintLineNbr = 0;

  TimeChart_c(int x, int y, int w, int h, int time_cnt, int line_size) {
    X = x;
    Y = y;
    W = w;
    H = h;

    ResizeData(W, H, time_cnt, line_size);
  }

  void ResizeData(int w, int h, int time_cnt, int line_size) {
    TimeCnt = time_cnt;
    WidthLineTimeChart = line_size;

    DataTimeChart = new int[time_cnt][h];
    DataLastChart =  new int[H];

    ImgCashTimeChart = new PImage[time_cnt];
    for (int k = 0; k < time_cnt; k++) {
      ImgCashTimeChart[k] = createImage(line_size, h, RGB);
    }

    WidthLineLastChart = w/10;
    TimeChartPrintLineNbr = (w - WidthLineLastChart)/line_size;
    WidthLineLastChart += (w - WidthLineLastChart)%line_size;

    ImgCashLastChart = createImage(WidthLineLastChart, h, RGB);
  }

  void PushData(int data[], int data_len, int start_pos, int resol) {
    StartPosLast = start_pos;
    ResolLast = resol;
    DataLastLen = constrain(data_len, 0, DataLastChart.length);
    for (int i = 0; i < DataLastLen; i++) {
      DataLastChart[i] = data[i];
      DataTimeChart[data_pos][i] = data[i];
    }

    float step_y = (float)(DataLastLen) / (float)(H);

    colorMode(RGB, 255);
    ImgCashTimeChart[data_pos].loadPixels();
    ImgCashLastChart.loadPixels();

    int img_height = ImgCashTimeChart[data_pos].height;
    int img_time_chart_width = ImgCashTimeChart[data_pos].width;
    int img_last_chart_width = ImgCashLastChart.width;

    for (int i = 0; i < img_height; i++) {
      int index_of_data = constrain((int)((float)i*step_y - 0.01), 0, DataLastChart.length);
      color clr = ConvertDataToColor(DataLastChart[index_of_data]);

      for (int img_x = 0; img_x < img_time_chart_width; img_x++) {
        ImgCashTimeChart[data_pos].pixels[img_x + i*img_time_chart_width] = clr;
      }

      for (int img_x = 0; img_x < img_last_chart_width; img_x++) {
        ImgCashLastChart.pixels[img_x + i*img_last_chart_width] = clr;
      }
    }
    ImgCashTimeChart[data_pos].updatePixels();
    ImgCashLastChart.updatePixels();

    data_pos++;
    if (data_pos == TimeCnt) {
      data_pos = 0;
    }
  }
  
  void SetColorMode() {
  }

  color ConvertDataToColor(int data) {
    //float color_line = 180 - (float)(data)*3.2;
    //return color(color_line, 255, 255 - color_line);
    
    float color_line = sqrt((float)(data)*2)*20 - 10;
    float r = constrain(color_line*0.4 - 30, 0, 255);
    float g = constrain(color_line*0.6 - 20, 0, 255);
    float b = constrain(color_line , 0, 255);
    return color(r, g, b);
  }

  void Draw() {
    DrawLastChart();
    for (int k = 1; k <= TimeChartPrintLineNbr; k++) {
      int buf_pos = data_pos - k;
      if (buf_pos < 0) {
        buf_pos += TimeCnt;
      }
      DrawPartTimeChart(k, buf_pos);
    }
    colorMode(RGB, 255);

    fill(255);
    stroke(180);
    textAlign(CENTER, CENTER);
    textSize(22);
    strokeWeight(1);

    float range_meas = (float)((ResolLast*0.1)*DataLastLen)*0.01;
    int cnt_range_lable = 20;
    int range_lable_offset = H/cnt_range_lable;
    for (int i = 1; i < cnt_range_lable; i++) {
      float val_range_lable = (float)range_meas * (float)i / (float)cnt_range_lable + StartPosLast*0.001;
      text(nf(val_range_lable, 1, 2), X + W - ImgCashLastChart.width, i*range_lable_offset);
      line(X + W - ImgCashLastChart.width + 40, i*range_lable_offset, X + W, i*range_lable_offset);
      line(X, i*range_lable_offset, X + W - ImgCashLastChart.width - 40, i*range_lable_offset);
      line(X + W - ImgCashLastChart.width, (i - 1)*range_lable_offset + 20, X + W - ImgCashLastChart.width, i*range_lable_offset - 10);
    }
    line(X + W - ImgCashLastChart.width, (cnt_range_lable - 1)*range_lable_offset + 20, X + W - ImgCashLastChart.width, cnt_range_lable*range_lable_offset - 10);
  }

  void DrawPartTimeChart(int nbr_line, int buf_pos) {
    image(ImgCashTimeChart[buf_pos], X + W - ImgCashLastChart.width - nbr_line*ImgCashTimeChart[buf_pos].width, Y);
  }

  void DrawLastChart() {
    image(ImgCashLastChart, X + W - ImgCashLastChart.width, Y);
  }

  void DrawBox(int nbr_line, int buf_pos) {
    //pushMatrix();
    //rotateX(1);
    ////rotateY(PI/2);
    //rotateZ(PI/2);
    //translate(-1000, -1000, -1000);
    //noStroke();
    //colorMode(HSB, 255);
    //for (int i = 0; i < MeasCnt; i++) {
    //  float color_line = 180 - BufEcho[i][buf_pos]*3.2;
    //  float val = BufEcho[i][buf_pos]*4;
    //  pushMatrix();
    //  translate(nbr_line*4, i*4, val/2);
    //  fill(color_line, 255, 255 - color_line);
    //  box(4, 4, val);
    //  popMatrix();
    //}
    //popMatrix();
  }
}
