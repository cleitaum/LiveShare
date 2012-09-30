//
//  RMTPHelper.h
//  liveshare
//
//  Created by cleitaum on 30/09/12.
//
//

#import <Foundation/Foundation.h>
#import "RTMPClient.h"
#import "ISharedObjectListener.h"


@interface RMTPHelper : NSObject<IRTMPClientDelegate, ISharedObjectListener>{

}

@property(nonatomic, retain) RTMPClient	*socket;
@property(nonatomic, assign) int state;
@property(nonatomic, assign) int alerts;

//test
@property(nonatomic, retain) id <IClientSharedObject>  clientSO;


-(RMTPHelper *)init:(NSString *)host withPort:(int)port withApplication:(NSString *)application;
-(void)write:(const uint8_t *)buffer maxLength:(NSUInteger)len;


@end
