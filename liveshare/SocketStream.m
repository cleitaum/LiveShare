//
//  SocketStream.m
//  liveshare
//
//  Created by Cleiton Amaral Souza on 15/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SocketStream.h"

@implementation SocketStream

@synthesize inputStream;
@synthesize outputStream;

-(SocketStream *)init{
    
    if (( self = [super init] )) {
        [self initNetworkCommunication];   
    }
    return self;
}


-(void)addStream:(NSString *)msg{
    
    NSString *response  = [NSString stringWithFormat:msg];
	NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
	[self.outputStream write:[data bytes] maxLength:[data length]];
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
	switch (streamEvent) {
            
		case NSStreamEventOpenCompleted:
			NSLog(@"Stream opened");
			break;
            
		case NSStreamEventHasBytesAvailable:
			break;			
            
		case NSStreamEventErrorOccurred:
			NSLog(@"Can not connect to the host!");
			break;
            
		case NSStreamEventEndEncountered:
            NSLog(@"End encoutered!");
			break;
            
		default:
			NSLog(@"Unknown event");
	}
}

- (void)initNetworkCommunication {
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (CFStringRef)@"192.168.1.101", 2008, &readStream, &writeStream);
    
    self.inputStream = (__bridge  NSInputStream *)readStream;
    self.outputStream = (__bridge NSOutputStream *)writeStream;
    
    [self.inputStream setDelegate:self];
    [self.outputStream setDelegate:self];
    
    [self.inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    [self.inputStream open];
    [self.outputStream open];
}

-(void)endNetworkCommunication{
    
    [self.inputStream close];
    [self.outputStream close];
}

@end
