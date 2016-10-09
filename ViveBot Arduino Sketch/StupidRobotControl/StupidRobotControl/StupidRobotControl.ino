#define MIN_MOTOR_SPEED 0
#define MAX_MOTOR_SPEED 180

// int8_t -128 to 127
#define MIN_MOTOR_VELOCITY -127
#define MAX_MOTOR_VELOCITY 127
#define DELIMITER -128

#define LEFT_MOTOR_PIN 9
#define RIGHT_MOTOR_PIN 10

#define LEFT_MOTOR_INVERSE true
#define RIGHT_MOTOR_INVERSE false

#include <Wire.h>
#include <Adafruit_MotorShield.h>
#include "utility/Adafruit_PWMServoDriver.h"
#include <Servo.h> 

// Create the motor shield object with the default I2C address
Adafruit_MotorShield AFMS = Adafruit_MotorShield(); 

// We'll also test out the built in Arduino Servo library
Servo leftMotor;
Servo rightMotor;

void setLeftMotor(int8_t v){
  if (LEFT_MOTOR_INVERSE){
    v*=-1;
  }
  leftMotor.write(map(v, MIN_MOTOR_VELOCITY, MAX_MOTOR_VELOCITY, MIN_MOTOR_SPEED, MAX_MOTOR_SPEED));
}

void setRightMotor(int8_t v){
  if (RIGHT_MOTOR_INVERSE){
    v*=-1;
  }
  rightMotor.write(map(v, MIN_MOTOR_VELOCITY, MAX_MOTOR_VELOCITY, MIN_MOTOR_SPEED , MAX_MOTOR_SPEED));
}

void setup() {
  Serial.begin(9600);           // set up Serial library at 9600 bps
  Serial.println("VIVEBOT");

  AFMS.begin();  // create with the default frequency 1.6KHz
  //AFMS.begin(1000);  // OR with a different frequency, say 1KHz
  
  // Attach a servo to pin #10
  leftMotor.attach(LEFT_MOTOR_PIN);
  rightMotor.attach(RIGHT_MOTOR_PIN);  

  setLeftMotor(0);
  setRightMotor(0);
}

int8_t leftVelocity = 0;
int8_t rightVelocity = 0;
void loop() {
  int8_t bytesAvailable = Serial.available();
  if (bytesAvailable >= 3){
    if ((int8_t)Serial.read() == (int8_t)DELIMITER){
      leftVelocity = (int8_t)Serial.read();
      rightVelocity = (int8_t)Serial.read();

      Serial.print('<');
      Serial.print(leftVelocity);
      Serial.print(", ");
      Serial.print(rightVelocity);
      Serial.println('>');

      setLeftMotor(leftVelocity);
      setRightMotor(rightVelocity);
    }else{
      Serial.print('?');
      int8_t nextVal = Serial.read();
      while (Serial.available() > 0){
        nextVal = Serial.read();
        Serial.print((int)nextVal);
      }
      Serial.println();
    }
  }
}
