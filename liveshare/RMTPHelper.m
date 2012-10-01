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
@synthesize filePath;
@synthesize offset;
@synthesize isConnected;

-(RMTPHelper *)init:(NSString *)host withPort:(int)port withApplication:(NSString *)application  withFilePath:(NSString *)__filePath{
    
    if (( self = [super init] )) {
        
        socket = [[RTMPClient alloc] init];
        socket.delegate = self;
        [socket connect:host port:port app:application];
        
        self.filePath =  __filePath;
    }
    return self;
}

-(void)transmit{

    NSUInteger SIZE = 128;
    
    
    NSUInteger total_filelenght = [[NSData dataWithContentsOfFile:self.filePath] length];
    
    int i =0;
    
    while (total_filelenght >= (NSUInteger)offset) {
        
        NSData *data = [self dataWithContentsOfFile:self.filePath atOffset:(NSUInteger)offset withSize:SIZE];
        
        i+=1;
      //  [self write:[data bytes] maxLength:[data length]];
        
        [socket stream:[data bytes] handleEvent:NSStreamEventHasBytesAvailable];
        
        offset += [data length] + 1;
        
        NSUInteger reminderBytes = total_filelenght - (NSUInteger)offset;
        
        NSLog(@"reminderBytes %d", reminderBytes);
        
        if (reminderBytes < SIZE){
            SIZE = reminderBytes;
        }
    }
    NSLog(@"Transmited %i", i);
}

- (NSData *) dataWithContentsOfFile:(NSString *)path atOffset:(off_t)offsett withSize:(size_t)bytes
{
    FILE *file = fopen([path UTF8String], "rb");
    if(file == NULL)
        return nil;
    
    void *data = malloc(bytes);  // check for NULL!
    fseeko(file, offsett, SEEK_SET);
    fread(data, 1, bytes, file);  // check return value, in case read was short!
    fclose(file);
    
    // NSData takes ownership and will call free(data) when it's released
    return [NSData dataWithBytesNoCopy:data length:bytes];
}

-(void)connectSO {
    
    if (!clientSO) {
        
        printf("connectSO SEND ----> getSharedObject\n");
        
        // send "getSharedObject (+ connect)"
        clientSO = [socket getSharedObject:self.filePath persistent:NO];
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
   
    self.isConnected = YES;
    NSLog(@"===> connectedEvent");
}

-(void)disconnectedEvent{
    
    NSLog(@"===> disconnectedEvent");
}

-(void)resultReceived:(id<IServiceCall>)call{
 
    NSLog(@"===> resultReceived");
}

-(void)connectFailedEvent:(int)code description:(NSString *)description{
    
    self.isConnected = NO;
    
    if (code == -1)
        NSLog(@"%@",[NSString stringWithFormat:
               @"Unable to connect to the server. Make sure the hostname/IP address and port number are valid\n"]);
    else
        NSLog(@"%@",[NSString stringWithFormat:@" !!! connectFailedEvent: %@ \n", description]);

}


@end
