//
//  AppDelegate.h
//  HelloWorld
//  This Application sets up a connection to Sphero and blinks the LED green
//
//  Created by Michael DePhillips on 6/21/12.
//  Copyright (c) 2012 Orbotix Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MyWindowController;
@class GCDAsyncSocket;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    BOOL robotOnline;
    MyWindowController *myWindowController;
  dispatch_queue_t socketQueue;
  GCDAsyncSocket *listenSocket;
  NSMutableArray *connectedSockets;
  NSInputStream *dataStream;
  BOOL isRunning;
  
  
  
  IBOutlet id logView;
  IBOutlet id portField;
  IBOutlet id startStopButton;
  
  NSWindow *__unsafe_unretained appDelegateWindow;


}

@property (assign) IBOutlet NSWindow *window;

-(void)setupRobotConnection;
-(void)handleRobotOnline;

@end

