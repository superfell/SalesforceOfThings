#include <Bounce.h>
#include <SPI.h> 
#include <Ethernet.h>

// Enter a MAC address and IP address for your controller below.
// The IP address will be dependent on your local network:
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192,168,1, 177 };
byte server[] = { 192,168,1,11 };

// This code turns a led on/off through a debounced button
// Build the circuit indicated here: http://arduino.cc/en/Tutorial/Button

#define BUTTON 2
#define LED 8

// Instantiate a Bounce object with a 5 millisecond debounce time
Bounce bouncer = Bounce( BUTTON,25 ); 
Client client = Client(server, 9091 );

void setup() {
  pinMode(BUTTON,INPUT);
  pinMode(LED,OUTPUT);
  
  // start the Ethernet connection and the server:
  Ethernet.begin(mac, ip);
}

void loop() {
 // Update the debouncer
  bouncer.update();

 // Get the update value
 int value = bouncer.read();
 
 // Turn on or off the LED
 if ( value == HIGH) {
   digitalWrite(LED, HIGH );
 } else {
    digitalWrite(LED, LOW );
 }

 
  if (bouncer.fallingEdge()) {
     if (client.connect()) {
       client.println("POST /?sid=002&val=231 HTTP/1.0");
//       client.print(value);
       client.println("");
     }
  }

  if (client.connected()) {
    if (client.available() >= 7)
      client.stop();
  }
}
