//
//  SocketStream.h
//  liveshare
//
//  Created by Cleiton Amaral Souza on 15/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SocketStream : NSObject<NSStreamDelegate>

@property (nonatomic, retain) NSInputStream *inputStream;
@property (nonatomic, retain) NSOutputStream *outputStream;


-(SocketStream *)init;
-(void)addStream:(NSString *)msg;

@end
