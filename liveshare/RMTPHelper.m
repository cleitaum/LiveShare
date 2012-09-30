//
//  RMTPHelper.m
//  liveshare
//
//  Created by cleitaum on 30/09/12.
//
//

#import "RMTPHelper.h"

@implementation RMTPHelper

@synthesize socket;
@synthesize state;
@synthesize alerts;
@synthesize clientSO;

-(RMTPHelper *)init:(NSString *)host withPort:(int)port withApplication:(NSString *)application{
    
    if (( self = [super init] )) {
        
        socket = [[RTMPClient alloc] init];
        socket.delegate = self;
        [socket connect:host port:port app:application];
    }
    return self;
}

-(void)connectSO {
    
    if (!clientSO) {
        
        printf("connectSO SEND ----> getSharedObject\n");
        
        // send "getSharedObject (+ connect)"
        clientSO = [socket getSharedObject:@"TempApplicationName" persistent:NO];
    }
    else
        if (![clientSO isConnected]) {
            
            printf("connectSO SEND ----> connect\n");
            
            // send "connect"
            [clientSO connect];
        }
        else {
            
            printf("connectSO SEND ----> disconnect\n");
            
            // send "disconnect"
            [clientSO disconnect];
        }
}

-(void)doDisconnect:(id)sender {
    
    if (state == 0)
        return;
    
    clientSO = nil;
    socket = nil;
}


-(void)write:(const uint8_t *)buffer maxLength:(NSUInteger)len{
    
    NSLog(@"===> going to write file");
    
 //   socket stream:<#(NSStream *)#> handleEvent:<#(NSStreamEvent)#>
    
}

#pragma mark -
#pragma mark ISharedObjectListener Methods

-(void)onSharedObjectClear:(id<IClientSharedObject>)so{
    
    NSLog(@"===> onSharedObjectClear");
}

-(void)onSharedObjectConnect:(id<IClientSharedObject>)so{
 
    NSLog(@"===> onSharedObjectConnect");
}

-(void)onSharedObjectDelete:(id<IClientSharedObject>)so withKey:(NSString *)key{
    
    NSLog(@"===> onSharedObjectDelete");
}

-(void)onSharedObjectDisconnect:(id<IClientSharedObject>)so{
    
    NSLog(@"===> onSharedObjectDisconnect");
}

-(void)onSharedObjectSend:(id<IClientSharedObject>)so withMethod:(NSString *)method andParams:(NSArray *)parms{
    
    NSLog(@"===> onSharedObjectSend");
}

-(void)onSharedObjectUpdate:(id<IClientSharedObject>)so withDictionary:(NSDictionary *)values{
    
    NSLog(@"===> onSharedObjectUpdate");
}

-(void)onSharedObjectUpdate:(id<IClientSharedObject>)so withKey:(id)key andValue:(id)value{

    NSLog(@"===> onSharedObjectUpdate");
}


-(void)onSharedObjectUpdate:(id<IClientSharedObject>)so withValues:(id<IAttributeStore>)values{
    
    NSLog(@"===> onSharedObjectUpdate");
}

#pragma mark -
#pragma mark IRTMPClientDelegate Methods

-(void)connectedEvent{
   
    NSLog(@"===> connectedEvent");
}

-(void)disconnectedEvent{
    
    NSLog(@"===> disconnectedEvent");
}

-(void)resultReceived:(id<IServiceCall>)call{
 
    NSLog(@"===> resultReceived");
}

-(void)connectFailedEvent:(int)code description:(NSString *)description{
    
    NSLog(@"===> connectFailedEvent");
}


@end
