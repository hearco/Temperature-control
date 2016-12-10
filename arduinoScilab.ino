
/* CODE BASED ON THE TOOLBOX ARDUINO v3 AND MODIFIED TO BE USED ON A HEATER FOR PID CONTROL
 * 
 * This file is meant to be used with the SCILAB arduino  
   toolbox, however, it can be used from the IDE environment
   (or any other serial terminal) by typing commands like:
   
   Conversion ascii -> number
   48->'0' ... 57->'9' 58->':' 59->';' 60->'<' 61->'=' 62->'>' 63->'?' 64->'@' 
   65->'A' ... 90->'Z' 91->'[' 92->'\' 93->']' 94->'^' 95->'_' 96->'`' 
   97->'a' ... 122->'z'
   
   Dan0 or Dan1 : attach digital pin n (ascii from 2 to b) to input (0) or output (1)
   Drn : read digital value (0 or 1) on pin n (ascii from 2 to b)
   Dwn0 or Dwn1 : write 1 or 0 on pin n
   An    : reads analog pin n (ascii from 0 to 19)
   Wnm  : write analog value m (ascii from 0 to 255) on pin n (ascii from 0 to 19)
   Sa1 or Sa2 : Attach servo 1 (digital pin 9) or 2 (digital pin 10)
   Sw1n or Sw2n : moves servo 1 or servo 2 to position n (from ascii(0) to ascii(180))
   Sd1 or Sd2 : Detach servo 1 or 2
   
*/



/* define internal for the MEGA as 1.1V (as as for the 328)  */
#if defined(__AVR_ATmega1280__) || defined(__AVR_ATmega2560__)
#define INTERNAL INTERNAL1V1
#endif

int initiat=1;

/*
// AC Control V1.1
//
// This arduino sketch is for use with the heater 
// control circuit board which includes a zero 
// crossing detect fucntion and an opto-isolated triac.
//
// AC Phase control is accomplished using the internal 
// hardware timer1 in the arduino
//
// Timing Sequence
// * timer is set up but disabled
// * zero crossing detected on pin 2
// * timer starts counting from zero
// * comparator set to "delay to on" value
// * counter reaches comparator value
// * comparator ISR turns on triac gate
// * counter set to overflow - pulse width
// * counter reaches overflow
// * overflow ISR truns off triac gate
// * triac stops conducting at next zero cross


// The hardware timer runs at 16MHz. Using a
// divide by 256 on the counter each count is 
// 16 microseconds.  1/2 wave of a 60Hz AC signal
// is about 520 counts (8,333 microseconds).
*/

#include <avr/io.h>
#include <avr/interrupt.h>

#define DETECT 2  //zero cross detect
#define GATE 9    //triac gate

// Define the pulse with 64 uS long (remember each count is 16 microseconds)
#define PULSE 4   //trigger pulse width, where max int value is 6 (about 100 uS) due to project requirements

// ANGLE SHOT MAX AND MIN VALUES 483
#define MIN_ANGLE            16   // Value where the heater will be at its lowest power
#define MAX_ANGLE           512   // Value where the heater will be at its highest power
#define MAX_TIMER_COUNT   65536   // Value the timer 1 will count up to.


int inByte;
int realStep = 0;
int INPUT_STEP = 0;

void setup() {

  // set up pins
  pinMode(DETECT, INPUT);     //zero cross detect
  digitalWrite(DETECT, HIGH); //enable pull-up resistor
  pinMode(GATE, OUTPUT);      //triac gate control

  // -----------------------------------------------------
  // ** TIMSK1 -- Timer/Counter1 Interrupt Mask Register **
  // Consider the next bits:
  //
  // b7 - Reserved
  // b6 - Reserved
  // b5 - Timer/Counter1 input capture interrupt enable.
  // b4 - Reserved
  // b3 - Reserved
  // b2 - Timer/Counter1 output compare B match interrupt enable.
  // b1 - Timer/Counter1 output compare A match interrupt enable.
  // b0 - Timer/Counter1, overflow interrupt enable
  // -----------------------------------------------------
  TIMSK1 = 0x03;    // enable comparator A and overflow interrupts (Enable/Disable timer interrupts)

  // ------------------------------------------------------
  // ** TCCR1A -- Timer/Counter1 Control Register A **
  // Consider the next bits:
  //
  // b7 - COM1A1 Compare Output Mode for Channel A
  // b6 - COM1A0 Compare Output Mode for Channel A
  // b5 - COM1B1 Compare Output Mode for Channel B
  // b4 - COM1B0 Compare Output Mode for Channel B
  // b3 - Reserved
  // b2 - Reserved
  // b1 - WGM11:0: Waveform Generation Mode
  // b0 - WGM11:0: Waveform Generation Mode
  // ------------------------------------------------------  
  TCCR1A = 0x00;    //timer control registers set for (Timer/Counter Control Register. The pre-scaler can be configured here)

  // ------------------------------------------------------
  // ** TCCR1B -- Timer/Counter1 Control Register B **
  // Consider the next bits:
  //
  // b7 - ICNC1: Input Capture Noise Canceler
  // b6 - ICES1: Input Capture Edge Select
  // b5 - Reserved
  // b4 - WGM13:2: Waveform Generation Mode
  // b3 - WGM13:2: Waveform Generation Mode
  // b2 - CS12:0: Clock Select
  // b1 - CS12:0: Clock Select
  // b0 - CS12:0: Clock Select
  // ------------------------------------------------------  
  TCCR1B = 0x00;    //normal operation, timer disabled


  // set up zero crossing interrupt
  attachInterrupt(digitalPinToInterrupt(DETECT),zeroCrossingInterrupt, RISING);  
  
  
  /* initialize serial                                       */
  Serial.begin(115200);
  
}

//Interrupt Service Routines

void zeroCrossingInterrupt()              // zero cross detect
{   

  // ------------------------------------
  // b7 - b6 - b5 - b4 - b3 - b2 - b1 - b0
  //  0    0    0    0    0    1    0    0
  // -------------------------------------
  TCCR1B = 0x04;                          // start timer with prescaler of 256
  
  // -------------------------------------
  // TCNT1[15:8]  --> TCNT1H
  // TCNT1[7:0]   --> TCNT1L
  // -------------------------------------
  TCNT1 = 0;                              // reset timer - count from zero
  
  // -------------------------------------
  // OCR1A[15:8]  --> OCR1AH
  // OCR1A[7:0]   --> OCR1AL
  //
  // Consider the next equation for OCR1A
  // 
  // hz = (16 * 10^6) / (prescaler * ( OCR1A + 1))
  //
  // so, for 60 hz, the max value should be 1040.67. Now, considering that 1/2 wave occurs
  // at the middle of 60 hz, the max value is now 520
  //
  // EXPERIMENTAL RESULTS:
  //
  // According to the experiments, the max temp could reach up to 52.3°C
  // and the minimun value is about ~24°C (depending on the room temperature
  // So, values goes this way:
  //
  // 512 ---> 0 % (~24°C)
  // 7  ---> 100 % (~52.3°C)
  // -------------------------------------
  
  if (INPUT_STEP > 100)
    INPUT_STEP = 100;
  
  else if (INPUT_STEP < 1)
    INPUT_STEP = 1;
  
  realStep = MAX_ANGLE - (INPUT_STEP * 5.05);   // Compensate the 0 to 100 % to the real scale (512 - 7)
  OCR1A = realStep;                             // Setting up t1
                                                // Experimental range value:
                                                // (Min value = 7) (Max value = 512)
}

// Timer interrupt for comparisson
ISR(TIMER1_COMPA_vect)                    // comparator match
{                   
  digitalWrite(GATE,HIGH);                // set triac gate to high
  TCNT1 = MAX_TIMER_COUNT - PULSE;        // trigger pulse width
}

// Timer interrupt for overflow
ISR(TIMER1_OVF_vect)                      //timer1 overflow
{
  digitalWrite(GATE,LOW);                 //turn off triac gate
  TCCR1B = 0x00;                          //disable timer stopd unintended triggers
}

void loop() {
  
  /* variables declaration and initialization                */
  
  static int  s   = -1;    /* state                          */
  static int  pin = 13;    /* generic pin number             */
  static int  dcm =  4;    /* generic dc motor number        */

  int  val =  0;           /* generic value read from serial */
  int  agv =  0;           /* generic analog value           */
  int  dgv =  0;           /* generic digital value          */
  static int  enc   = 1;    /* encoder number 1 (or 2 for Arduino mega)     */

  while (Serial.available()==0) {}; // Waiting char
  val = Serial.read(); 
  
  //case A -> Analog
  if (val==65){//A -> Analog read
    while (Serial.available()==0) {}; // Waiting char

       val=Serial.read();
       if (val>47 && val<67) { //from pin 0, to pin 19
          pin=val-48; //number of the pin
          agv=analogRead(pin);
          //Serial.println(agv);
          Serial.write((uint8_t*)&agv,2); /* send binary value via serial  */   
       }
       val=-1;
  }
  else if (val==87){//W -> Analog write
      while (Serial.available()==0) {}; // Waiting char
      val=Serial.read();
         if (val>47 && val<67) { //from pin 0 to pin 19
            pin=val-48; //number of the pin
            while (Serial.available()==0) {}; // Waiting char
            //val=Serial.read();
            //analogWrite(pin,val);
            inByte = Serial.read();
            INPUT_STEP = inByte;
         }
          val=-1;
      }

  //case D -> Digital
  else if (val==68){//D -> Digital pins
    while (Serial.available()==0) {}; // Waiting char
    val=Serial.read();
    if (val==97){ //'a'-> declare pin
       while (Serial.available()==0) {}; // Waiting char
       val=Serial.read();
       if (val>49 && val<102) {
         pin=val-48;
         while (Serial.available()==0) {}; // Waiting char
         val=Serial.read();
         if (val==48 || val==49) { 
            if (val==48){//'0' -> input
               pinMode(pin,INPUT);
            }
            else if (val==49){//'1' -> output
               pinMode(pin,OUTPUT);
            }
         }
       }
    }
    if (val==114){ //'r'-> read pin
       while (Serial.available()==0) {}; // Waiting char
       val=Serial.read();
       if (val>49 && val<102) { 
          pin=val-48; //number of the digital pin
          dgv=digitalRead(pin);      
          Serial.print(dgv);         
       }
    }
    if (val==119){ //'w'-> write pin
       while (Serial.available()==0) {}; // Waiting char
       val=Serial.read();
       if (val>49 && val<102) { 
          pin=val-48; //number of the digital pin
          while (Serial.available()==0) {}; // Waiting char
          val=Serial.read();
          if (val==48 || val==49) { // 0 or 1
            dgv=val-48;
            digitalWrite(pin,dgv);
          }
       }
    }
   val=-1;

  }
  


  //case R -> Analog reference
  if(val==82){
    while (Serial.available()==0) {};                
    val = Serial.read();
    if (val==48) analogReference(DEFAULT);
    if (val==49) analogReference(INTERNAL);
    if (val==50) analogReference(EXTERNAL);
    if (val==51) Serial.print("v3");
    val=-1;
  }
  
} /* end loop statement                                      */



