#include <SPI.h> 
#include <Ethernet.h>
// You'll need NewSoftSerial from http://arduiniana.org/libraries/newsoftserial/
#include <NewSoftSerial.h>

// Enter a MAC address and IP address for your controller below.
// The IP address will be dependent on your local network:
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192,168,1, 177 };

byte server[] = { 192,168,1,36 };

// which pins are connected to what?
#define STATION_ID_1 2
#define STATION_ID_2 3
#define STATION_ID_3 4
#define RFID_RX 8
#define RFID_TX 9

// Tcp client to play! proxy
Client client = Client(server, 9091 );

// serial connect from ID-12 RFID reader
NewSoftSerial rfid = NewSoftSerial(RFID_RX, RFID_TX);

void setup() {
  // setup the relevant digital I/O pins
  pinMode(STATION_ID_1, INPUT);
  pinMode(STATION_ID_2, INPUT);
  pinMode(STATION_ID_3, INPUT);
  
  pinMode(RFID_RX, INPUT);
  pinMode(RFID_TX, OUTPUT);
  
  // start the Ethernet connection and the server:
  Ethernet.begin(mac, ip);
  // start soft serial for the ID-12 reader
  rfid.begin(9600);
}

// Pins 2,3,4 make up a 3 bit station Id, convert
// the 3 pin input into a 0-7 station Id value.
int getStationId() {
  int v = 0;
  if (digitalRead(STATION_ID_1)) v+= 1;
  if (digitalRead(STATION_ID_2)) v+= 2;
  if (digitalRead(STATION_ID_3)) v+= 4;
  return v;
}

void loop() {
  // wait until the entire tag data is buffered
  if (rfid.available() >= 16) {
    // read in the entire 16 byte data frame.
    char code[16];
    for (int i =0; i <16; i++) 
      code[i] = rfid.read();
    
    // sanity check its the id-12 format (0x02, 10 byte data, 2 byte checksum, CR, LF, 0x03)
    if (code[0] == 0x02 && code[13] == 0x0D && code[14] == 0x0A && code[15] == 0x03) {
       // extract out the 10 byte tag code + 2 byte checksum
      char tag[13];
      for (int i =0; i < 12; i++)
        tag[i] = code[i+1];
      // remember to null terminate the string
      tag[12] = 0x00;
     
      // connect to the proxy and send the tag value + checksum
      if (client.connect()) {
        client.print("POST /?sid=");
        client.print(getStationId());
        client.print("&val=");
        client.print(tag);
        client.println(" HTTP/1.0");
        client.println("");
      }
   }
 }
 
 // disconnect the client once the proxy has acknolwedged the request. 
 if (client.connected()) {
    if (client.available() >= 7)
      client.stop();
  }
}
