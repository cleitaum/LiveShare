//
//  RTMPClient.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 21.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IRTMProtocol.h"
#import "IClientSharedObjectDelegate.h"
#import "IPendingServiceCallback.h"
#import "IClientSharedObject.h"

@protocol IRTMPClientDelegate <NSObject, IPendingServiceCallback>
-(void)connectedEvent;
-(void)disconnectedEvent;
-(void)connectFailedEvent:(int)code description:(NSString *)description;
@end

@class CrowdNode, RTMProtocol;

@interface RTMPClient : NSObject <NSStreamDelegate, IRTMProtocol, IClientSharedObjectDelegate> {
	// delegate
	id <IRTMPClientDelegate>	delegate;
		
	// socket
	NSString		*_host;
	int				_port;
	NSOutputStream	*outputStream;
	NSInputStream	*inputStream;
	uint8_t			*outputBuffer;
	uint8_t			*inputBuffer;
	
	// context
	NSArray			*parameters;
	CrowdNode		*connectionParams;
	
	// protocol
	RTMProtocol		*rtmp;	
	BOOL			firstHandshake;
	uint			lengthHandshake;
	
	// invoke/notify
	int				invokeId;
	CrowdNode		*pendingCalls;
	
	// shared objects
	CrowdNode		*sharedObjects;
	
	// test
}
@property (nonatomic, assign) id <IRTMPClientDelegate> delegate;

// connect
-(void)connect:(NSString *)server;
-(void)connect:(NSString *)server port:(int)port;
-(void)connect:(NSString *)server port:(int)port app:(NSString *)application;
-(void)connect:(NSString *)server port:(int)port app:(NSString *)application params:(NSArray *)params;

// service requests
-(void)invoke:(NSString *)method withArgs:(NSArray *)args;
-(id <IClientSharedObject>)getSharedObject:(NSString *)name persistent:(BOOL)persistent;

// test
@end
