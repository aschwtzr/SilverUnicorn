#pragma once

#include "ofMain.h"

#include "ofxSerial.h"
#define ARDUINO_PORT_NAME_BASE_STRING "Arduino"
#define ARDUINO_SERIAL_BAUDRATE 9600
#define SERIAL_DELIMITER -128

class ofApp : public ofBaseApp{
    private:
        ofx::IO::SerialDevice* arduino;
        int8_t leftMotorVal = 0;
        int8_t rightMotorVal = 0;
    
        int8_t commandFrame[3] = {SERIAL_DELIMITER, 0, 0};
    
	public:
		void setup();
		void update();
		void draw();

        void commandRobotScreen(int x, int y);
        void commandRobotVector(double left, double right);
        void commandRobotDrive(double theta, double velocity);
        void commandRobotWheels(double xVel, double yVel);
    
		void keyPressed(int key);
		void keyReleased(int key);
		void mouseMoved(int x, int y );
		void mouseDragged(int x, int y, int button);
		void mousePressed(int x, int y, int button);
		void mouseReleased(int x, int y, int button);
		void mouseEntered(int x, int y);
		void mouseExited(int x, int y);
		void windowResized(int w, int h);
		void dragEvent(ofDragInfo dragInfo);
		void gotMessage(ofMessage msg);
		
};
