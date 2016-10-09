#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){
    ofBackground(0, 0, 0);
    
    ofSetColor(255, 255, 255);
    ofFill();
    
    // Connect to arduino serial
    ofLog(OF_LOG_NOTICE, "Connecting to Arduino...");
    std::vector<ofx::IO::SerialDeviceInfo> devicesInfo = ofx::IO::SerialDeviceUtils::listDevices();
    
    if (!devicesInfo.empty()){
        
        // Get a lits of all connected usb devices
        ofLog(OF_LOG_NOTICE, "\nConnected USB Devices are: ");
        unsigned int num_usb_devices = devicesInfo.size();
        for (std::size_t i = 0; i < num_usb_devices; ++i){
            ofLog(OF_LOG_NOTICE, "\t" + ofToString(i) + "\t" + ofToString(devicesInfo[i]));
        }
        
        ofLog(OF_LOG_NOTICE, "\nFinding Arduino Devices...");
        for(unsigned int i = 0; i < num_usb_devices; i++ ){
            string deviceName =  ofToString(devicesInfo[i]);
            if (deviceName.find(ARDUINO_PORT_NAME_BASE_STRING) != string::npos) { // the search string was found in the usb device name
                ofLog(OF_LOG_NOTICE, "\tDevice " + ofToString(i) + " is the first arduino found.");
                arduino = new ofx::IO::SerialDevice;
                bool success = arduino->setup(devicesInfo[i], ARDUINO_SERIAL_BAUDRATE);
            }
        }
    }
    
}

void ofApp::commandRobotScreen(int x, int y){
    y = ofGetWindowHeight() - y;
    double xVelocity = (double)(x - ofGetWindowWidth()/2)/(ofGetWindowWidth()/2.0);
    double yVelocity = (double)(y - ofGetWindowHeight()/2)/(ofGetWindowHeight()/2.0);
    
    commandRobotWheels(xVelocity, yVelocity);
    //commandRobotVector(xVelocity, yVelocity);
}

void ofApp::commandRobotVector(double xVel, double yVel){
    double theta = atan2(yVel, xVel) + (PI/4.0);//- PI/2.0;
    while (theta < - 2 *PI){
        theta += 2*PI;
    }
    while (theta > 2 * PI){
        theta -= 2 * PI;
    }
    // Angle in [-180, 180] deg
    
    
    /*
    while (theta > PI){
        theta -= PI;
    }
    while (theta < -PI){
        theta += PI);
    }
    */
    
    double r = sqrt((xVel*xVel) + (yVel*yVel));
    
    ofLogNotice("Heading (" + ofToString(xVel) + ", " + ofToString(yVel) + ") to Polar {" + ofToString(theta * (180.0/PI)) + ", " + ofToString(r) + "}");
    
    commandRobotDrive(theta, r);
}

void ofApp::commandRobotDrive(double angle, double velocity){
    /*double sideWeight = cos(angle);
    double rightFraction = sideWeight/2.0 + 0.5;
    double leftFraction = 1.0 - rightFraction;
    
    double velocityAngleMultiplier = sin(angle);
    double normalizedVelocity = velocity * velocityAngleMultiplier;
    */
    double leftVel = velocity * cos(angle); //normalizedVelocity * leftFraction;
    double rightVel = velocity * sin(angle);    //normalizedVelocity * rightFraction;
    
    ofLogNotice("Polar {" + ofToString(angle * (180.0/PI)) + ", " + ofToString(velocity) + "} to velocities <" + ofToString(leftVel) + ", " + ofToString(rightVel) + ">");
    
    commandRobotWheels(leftVel, rightVel);
}

void ofApp::commandRobotWheels(double left, double right){
    commandFrame[0] = SERIAL_DELIMITER;
    commandFrame[1] = (int8_t)(0.5 + left * 127);
    commandFrame[2] = (int8_t)(0.5 + right * 127);
    
    ofLogNotice("Commanding Robot: <" + ofToString((int)commandFrame[1]) + ", " + ofToString((int)commandFrame[2]) + ">");
    //ofx::IO::ByteBuffer buffer((char*)commandFrame);
    try{
        if (arduino->isClearToSend()){
            arduino->writeBytes((unsigned char*)commandFrame, 3);
            arduino->flush();
        }
    }
    catch (const std::exception& exc)
    {
        ofLogError("Serial Error: ") << exc.what();
    }
}

//--------------------------------------------------------------
void ofApp::update(){
    /*unsigned int bytesAvailable = arduino->available();
    char buffer[bytesAvailable];
    std::size_t sz = arduino->readBytes((uint8_t*)buffer, bytesAvailable);
    ofLogNotice("RECEIVED: " + ofToString(string(buffer)));
     */
    // The serial device can throw exeptions.
    try
    {
        // Read all bytes from the device;
        uint8_t buffer[1024];
        
        while (arduino->available() > 0)
        {
            std::cout << "\nRECEIVED: ";
            
            std::size_t sz = arduino->readBytes(buffer, 1024);
            
            for (std::size_t i = 0; i < sz; ++i)
            {
                std::cout << buffer[i];
            }
        }
    }
    catch (const std::exception& exc)
    {
        ofLogError("ofApp::update") << exc.what();
    }
}

//--------------------------------------------------------------
void ofApp::draw(){
    ofCircle(ofGetWindowWidth()/2, ofGetWindowHeight()/2, 10);
}

//--------------------------------------------------------------
void ofApp::keyPressed(int key){

}

//--------------------------------------------------------------
void ofApp::keyReleased(int key){

}

//--------------------------------------------------------------
void ofApp::mouseMoved(int x, int y ){

}

//--------------------------------------------------------------
void ofApp::mouseDragged(int x, int y, int button){
    commandRobotScreen(x, y);
    //ofSleepMillis(200);
}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button){
    //commandRobotScreen(x, y);
    //ofSleepMillis(100);
}

//--------------------------------------------------------------
void ofApp::mouseReleased(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::mouseEntered(int x, int y){

}

//--------------------------------------------------------------
void ofApp::mouseExited(int x, int y){

}

//--------------------------------------------------------------
void ofApp::windowResized(int w, int h){

}

//--------------------------------------------------------------
void ofApp::gotMessage(ofMessage msg){

}

//--------------------------------------------------------------
void ofApp::dragEvent(ofDragInfo dragInfo){ 

}
