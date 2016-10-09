//
//  MyWindowController.h
//  KeyDrive
//
//  Created by Michael DePhillips on 10/18/12.
//  Copyright (c) 2012 Orbotix Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"
#import "GCDAsyncSocket.h" // for TCP

@interface MyWindowController : NSWindowController <NSStreamDelegate, GCDAsyncSocketDelegate> {
    BOOL isCalibrating;
    unsigned int keyMask;
    BOOL calibrateDirection;
    BOOL noArrowsPressed;
  GCDAsyncSocket *listenSocket;
  NSMutableArray *connectedSockets;
  NSInputStream *dataStream;
  BOOL isRunning;

  dispatch_queue_t socketQueue;
}
-(void)startStop;
-(void)setUpNetworking;

@end
