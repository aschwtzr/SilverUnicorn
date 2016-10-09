//
//  AppDelegate.m
//  HelloWorld
//  This Application sets up a connection to Sphero and blinks the LED green
//
//  Created by Michael DePhillips on 6/21/12.
//  Copyright (c) 2012 Orbotix Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "MyWindowController.h"
#import <RobotKit/RobotKit.h>
#import "GCDAsyncSocket.h"

//#define WELCOME_MSG  0
//#define ECHO_MSG     1
//#define WARNING_MSG  2
//
//#define READ_TIMEOUT 15.0
//#define READ_TIMEOUT_EXTENSION 10.0
//
//#define FORMAT(format, ...) [NSString stringWithFormat:(format), ##__VA_ARGS__]

@interface AppDelegate (PrivateAPI)

- (void)logError:(NSString *)msg;
- (void)logInfo:(NSString *)msg;
- (void)logMessage:(NSString *)msg;

@end

@implementation AppDelegate 

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(appWillTerminate:)
												 name:NSApplicationWillTerminateNotification
											   object:nil];
    
    if (myWindowController == NULL)
		myWindowController = [[MyWindowController alloc] initWithWindowNibName:@"Window"];
	
	[myWindowController showWindow:self];
  [myWindowController setUpNetworking];
    
    robotOnline = NO;
    
    /* Insert code here to initialize your application */
    [self setupRobotConnection];
//    socketQueue = dispatch_queue_create("socketQueue", NULL);
//		
//		listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:socketQueue];
  
//  // Setup an array to store all accepted client connections
//		connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
//		
//		isRunning = NO;
//  
//  [self startStop];

}

- (void)appWillTerminate:(NSNotification *)notification {
    
    if( !robotOnline ) return;
    
    /* When the application is entering the background we need to close the connection to the robot*/
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RKDeviceConnectionOnlineNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationWillTerminateNotification object:nil];
    
    // Close the connection
    [[RKRobotProvider sharedRobotProvider] closeRobotConnection];
    
    robotOnline = NO;
}

-(void)setupRobotConnection {
    /*Try to connect to the robot*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRobotOnline) name:RKDeviceConnectionOnlineNotification object:nil];
    [[RKRobotProvider sharedRobotProvider] openRobotConnection];
}

- (void)handleRobotOnline {
    /*The robot is now online, we can begin sending commands*/
    if(!robotOnline) {
        /* Send commands to Sphero Here: */
        robotOnline = YES;
    }
}

@end
