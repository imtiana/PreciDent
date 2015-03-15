import processing.serial.*;
PrintWriter output;
Serial myPort;
String data = "";
String dataBuffer = "";
String inBuffer = "";
String minString;
String secString;
int sec;
int position;

void setup() {
  
  //Obtain the current date & time for filename
  int d = day();
  int m = month();
  int y = year();
  int h = hour();
  int min = minute();
  
  //convert minute to two digit number (if less than 10)
  if (min < 10) {
    minString = "0" + str(min);
  }
  else{
    minString = str(min);
  }
  
  //create new csv file for data output
  output = createWriter( y + "-" + m + "-" + d + ", " + h + minString + ".csv" );
  
  //designate serial port to read from
  myPort = new Serial(this, "COM10", 9600);
  output.println("time,red,green,blue,green2,blue2,orange");
}

void draw() {
  
  //if serial port is available, read in data to buffer
  while ( myPort.available() > 0 ) {
    inBuffer = myPort.readString();
    dataBuffer = dataBuffer + inBuffer;  
  }
  
  //check for end character "e" to parse data correctly
  if ( dataBuffer.indexOf("e") != -1 ) {
    position = dataBuffer.indexOf("e");
    data = dataBuffer.substring(0, position);
    
    //obtain time of data reading
    int h = hour();
    int min = minute();
    int sec = second();
    if (min < 10) {
      minString = "0" + str(min);
    }
    else {
      minString = str(min);
    }
    
    if (sec < 10) {
      secString = "0" + str(sec);
    }
    else {
      secString = str(sec);
    }
    
    //output data to csv file
    output.print(h); 
    output.print(':');
    output.print(minString);
    output.print(':');
    output.print(secString + ",");
    output.println(data);
    println(data);
    data = "";
    dataBuffer = dataBuffer.substring(position+1, dataBuffer.length());
  }
}

//when key is pressed in application, data is flushed and file is closed
void keyPressed() {
  output.close();
  exit();
}
