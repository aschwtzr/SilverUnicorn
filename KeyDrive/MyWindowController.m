//
//  MyWindowController.m
//  KeyDrive
//
//  Created by Michael DePhillips on 10/18/12.
//  Copyright (c) 2012 Orbotix Inc. All rights reserved.
//
//#import "BonjourServerAppDelegate.h"
#import "MyWindowController.h"
#import <RobotKit/RobotKit.h>
// When using iOS 8+ frameworks
//@import CocoaAsyncSocket;

// OR when not using frameworks, targeting iOS 7 or below
#import "AppDelegate.h"
#import "MyWindowController.h"
#import <RobotKit/RobotKit.h>
#import "GCDAsyncSocket.h"

#define WELCOME_MSG  0
#define ECHO_MSG     1
#define WARNING_MSG  2
#define MOVE_FORWARD 3
#define MOVE_RIGHT 4
#define MOVE_BACK 5
#define MOVE_LEFT 6


#define READ_TIMEOUT 15.0
#define READ_TIMEOUT_EXTENSION 10.0

#define FORMAT(format, ...) [NSString stringWithFormat:(format), ##__VA_ARGS__]


@implementation MyWindowController 

- (id)initWithPath:(NSString *)newPath
{

    return [super initWithWindowNibName:@"Window"];
}

-(void)setUpNetworking{
  socketQueue = dispatch_queue_create("socketQueue", NULL);
  listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:socketQueue];
  // Setup an array to store all accepted client connections
  connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
  isRunning = NO;
  
  [self startStop];
}

- (void)dealloc
{
	[super dealloc];
}

- (BOOL)keyWasDown:(unsigned int)mask
{
    return (keyMask & mask) == mask;
}

- (BOOL)isMask:(unsigned long)newMask upEventForModifierMask:(unsigned int)mask
{
    return [self keyWasDown:mask] && ((newMask & mask) == 0x0000);
}

- (BOOL)isMask:(unsigned long)newMask downEventForModifierMask:(unsigned int)mask
{
    return ![self keyWasDown:mask] && ((newMask & mask) == mask);
}

- (void)flagsChanged:(NSEvent *)theEvent
{
    // Modifier keyboard events are keys like shift
    // They can be processed while other keys like arrow keys are clicked too
    if(([theEvent modifierFlags] & NSShiftKeyMask) == NSShiftKeyMask)
    {
        isCalibrating = YES;
        keyMask |= NSShiftKeyMask;
        // Turn on tail light
        [RKBackLEDOutputCommand sendCommandWithBrightness:1.0f];
    }
    else if([self isMask:[theEvent modifierFlags] upEventForModifierMask:NSShiftKeyMask])
    {
        isCalibrating = NO;
        keyMask ^= NSShiftKeyMask;
        // Turn off tail light and send calibrate command at 0 heading
        [RKBackLEDOutputCommand sendCommandWithBrightness:0.0f];
        [RKCalibrateCommand sendCommandWithHeading:0.0f];
    }
}

- (void)keyDown:(NSEvent *)theEvent {
    NSString *keyPressed = [theEvent charactersIgnoringModifiers];
    unichar keyChar = [keyPressed characterAtIndex:0];
    
    // if pressed any arrow
    if(keyChar == NSUpArrowFunctionKey) {
        if( !isCalibrating ) [RKRollCommand sendCommandWithHeading:0.0 velocity:0.6];
    }
    else if(keyChar == NSDownArrowFunctionKey) {
        if( !isCalibrating ) [RKRollCommand sendCommandWithHeading:180.0 velocity:0.6];
    }
    else if(keyChar == NSLeftArrowFunctionKey) {
        // Drive when shift is not active
        if( !isCalibrating ) {
            [RKRollCommand sendCommandWithHeading:270.0 velocity:0.6];
        }
        // Start Calibrate animation when shift is active
        else {
            if( theEvent.type ==  NSKeyDown ) {
                noArrowsPressed = NO;
                calibrateDirection = YES;
                [self calibrateEvent];
            }
            else if( theEvent.type ==  NSKeyUp ) {
                noArrowsPressed = YES;
            }
        }
    }
    else if(keyChar == NSRightArrowFunctionKey) {
        if( !isCalibrating ) {
            [RKRollCommand sendCommandWithHeading:90.0 velocity:0.6];
        }
        else {
            // Drive when shift is not active
            if( theEvent.type ==  NSKeyDown ) {
                noArrowsPressed = NO;
                calibrateDirection = NO;
                [self calibrateEvent];
            }
            // Start Calibrate animation when shift is active
            else if( theEvent.type ==  NSKeyUp ) {
                noArrowsPressed = YES;
            }
        }
    }
    // Space bar pressed stop
    else if( [keyPressed isEqualToString:@" "] ) {
        [RKRollCommand sendStop];
      [super keyDown:theEvent];
    }
}
 
-(void)calibrateEvent {
    if( noArrowsPressed || !isCalibrating ) return;
    int newAngle = [RKRollCommand currentHeading];
    // rotate counter-clockwise
    if( calibrateDirection ) {
        newAngle -= 5;
        if( newAngle < 0 ) newAngle = 359;
    }
    // rotate clockwise
    else {
        newAngle += 5;
        if( newAngle >359 ) newAngle = 0;
    }
    [RKRollCommand sendCommandWithHeading:newAngle velocity:0.0f stopped:YES];
    [self performSelector:@selector(calibrateEvent) withObject:nil afterDelay:0.2];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NETWORKING
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)logError:(NSString *)msg
{
//  NSString *paragraph = [NSString stringWithFormat:@"%@\n", msg];
//  
//  NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:1];
//  [attributes setObject:[NSColor redColor] forKey:NSForegroundColorAttributeName];
  
//  NSAttributedString *as = [[NSAttributedString alloc] initWithString:paragraph attributes:attributes];
  
//  [[logView textStorage] appendAttributedString:as];
}

- (void)logInfo:(NSString *)msg
{
//  NSString *paragraph = [NSString stringWithFormat:@"%@\n", msg];
//  
//  NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:1];
//  [attributes setObject:[NSColor purpleColor] forKey:NSForegroundColorAttributeName];
  
//  NSAttributedString *as = [[NSAttributedString alloc] initWithString:paragraph attributes:attributes];
  
//  [[logView textStorage] appendAttributedString:as];
}

- (void)logMessage:(NSString *)msg
{
//  NSString *paragraph = [NSString stringWithFormat:@"%@\n", msg];
//  
//  NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:1];
//  [attributes setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
  
//  NSAttributedString *as = [[NSAttributedString alloc] initWithString:paragraph attributes:attributes];
  
//  [[logView textStorage] appendAttributedString:as];
}

- (void)startStop {
  if(!isRunning)
  {
    int port = 8651;
    
    if (port < 0 || port > 65535)
    {
//      [portField setStringValue:@""];
      port = 0;
    }
    
    NSError *error = nil;
    if(![listenSocket acceptOnPort:port error:&error])
    {
      NSLog(@"Error starting server: %@", error);
      return;
    }
    
    NSLog(@"Echo server started on port %hu", [listenSocket localPort]);
    isRunning = YES;
    
//    [portField setEnabled:NO];
    
  }
  else
  {
    // Stop accepting connections
    [listenSocket disconnect];
    
    // Stop any client connections
    @synchronized(connectedSockets)
    {
      NSUInteger i;
      for (i = 0; i < [connectedSockets count]; i++)
      {
        // Call disconnect on the socket,
        // which will invoke the socketDidDisconnect: method,
        // which will remove the socket from the list.
        [[connectedSockets objectAtIndex:i] disconnect];
      }
    }
    
    NSLog(@"Stopped Echo server");
    isRunning = false;
    
//    [portField setEnabled:YES];
//    [startStopButton setTitle:@"Start"];
  }
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
  // This method is executed on the socketQueue (not the main thread)
  
  @synchronized(connectedSockets)
  {
    [connectedSockets addObject:newSocket];
  }
  
  NSString *host = [newSocket connectedHost];
  UInt16 port = [newSocket connectedPort];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    @autoreleasepool {
      // [self setSocket:newSocket];
      

      NSLog(@"Accepted client %@:%hu", host, port);
      
    }
  });
  
  NSString *welcomeMsg = @"Connected";
  NSData *welcomeData = [welcomeMsg dataUsingEncoding:NSUTF8StringEncoding];
  
  [newSocket writeData:welcomeData withTimeout:-1 tag:WELCOME_MSG];
  // Read Data from Socket
  [newSocket readDataWithTimeout:-1 tag:0];
  
//  [newSocket readDataToLength:sizeof(uint64_t) withTimeout:-1.0 tag:0];
//  [newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
  // This method is executed on the socketQueue (not the main thread)
  [sock readDataWithTimeout:-1 tag:0];

}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
  dispatch_async(dispatch_get_main_queue(), ^{
    @autoreleasepool {
      
      [RKRollCommand sendCommandWithHeading:360.0 velocity:.6];
      
      NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] )];
      
      int toread = [data length] ;
      
      char bytesread [512] ;
      void *p = &bytesread[0];
      
      [strData getBytes:p length:toread];

      for ( int x = 0 ; x <toread ; x++ )
      {
        if( bytesread[x] == 1) {
          [RKRollCommand sendCommandWithHeading:0.0 velocity:0.6];
        }
        else if (bytesread[x] == 2 )
        {
          [RKRollCommand sendCommandWithHeading:90.0 velocity:0.6];
        }
        else if( bytesread[x] == 3) {
          [RKRollCommand sendCommandWithHeading:180.0 velocity:0.6];
        }
        else if (bytesread[x] == 4 )
        {
         [RKRollCommand sendCommandWithHeading:270.0 velocity:0.6];
        }
        else if (bytesread[x] == 5 )
        {
           [RKRollCommand sendStop];
        }
      }
      
      
      NSString *message = [[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding];
      
      if (![message isEqualToString:@""] || message == nil){
       
      
      
//      NSArray *array = [message componentsSeparatedByString:@","];
//        
//        if (array.count == 2 ){
//      float direction= [array[0] floatValue];
//      float velocity = ([array[1] floatValue]/10);
//        
//     
//      [RKRollCommand sendCommandWithHeading:direction velocity:velocity];
//        }
//       WE HAVE 360 CONTROLS!!!
      
//      if (strData == 3)
//      {
//        //first speed setting
//        if ([array[0] isEqualToString:@"3"]) {
//          if( !isCalibrating ) [RKRollCommand sendCommandWithHeading:0.0 velocity:0.6];
//          NSLog(@"Move Forward");
//          
//          //    [sock readDataToLength:LENGTH_BODY withTimeout:-1 tag:CHECK_STAUTS_BODY];
//          
//        } else if ([array[0] isEqualToString:@"4"]) {
//          [RKRollCommand sendCommandWithHeading:90.0 velocity:0.6];
//          NSLog(@"Move Right");
//          
//        }
//        
//        else if ([array[0] isEqualToString:@"5"]) {
//          if( !isCalibrating ) [RKRollCommand sendCommandWithHeading:180.0 velocity:0.6];
//          NSLog(@"Move Back");
//          
//        }
//        
//        else if ([array[0] isEqualToString:@"6"]) {
//          [RKRollCommand sendCommandWithHeading:270.0 velocity:0.6];
//          NSLog(@"Move Left");
//          
//        }
//        
//        else if ([array[0] isEqualToString:@"7"]) {
//          [RKRollCommand sendCommandWithHeading:270.0 velocity:0.6];
//          NSLog(@"Stop");
//          
//        }
//        
//        else
//        {
//          NSLog(@"Error converting received data into UTF-8 String");
//        }
//      }
//
//      else
//      {
//        [self logError:@"Error converting received data into UTF-8 String"];
//      }
      }
    }
    [sock readDataWithTimeout:-1 tag:0];
  });
  
  // Echo message back to client
  [sock writeData:data withTimeout:-1 tag:ECHO_MSG];
}



/**
 * This method is called if a read has timed out.
 * It allows us to optionally extend the timeout.
 * We use this method to issue a warning to the user prior to disconnecting them.
 **/
- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length
{
  if (elapsed <= READ_TIMEOUT)
  {
    NSString *warningMsg = @"Are you still there?\r\n";
    NSData *warningData = [warningMsg dataUsingEncoding:NSUTF8StringEncoding];
    
    [sock writeData:warningData withTimeout:-1 tag:WARNING_MSG];
    
    return READ_TIMEOUT_EXTENSION;
  }
  
  return READ_TIMEOUT_EXTENSION;
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
  if (sock != listenSocket)
  {
    dispatch_async(dispatch_get_main_queue(), ^{
      @autoreleasepool {
        
        NSLog(@"Client Disconnected");
        
      }
    });
    
    @synchronized(connectedSockets)
    {
      [connectedSockets removeObject:sock];
    }
  }
}


@end
