//
//  UDPManager.m
//  textDemo
//
//  Created by caobo56 on 2018/2/24.
//  Copyright © 2018年 dahua. All rights reserved.
//

#import "UDPManager.h"

@interface UDPManager ()<GCDAsyncUdpSocketDelegate>

@property(nonatomic,strong)GCDAsyncUdpSocket *reciveSocket;

@end

@implementation UDPManager

static UDPManager *udpManager;
static int udpServerPort = 10000;

+ (instancetype)shareUDPManagerWithPort:(int)port{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        udpManager = [[self alloc] init];
    });
    return udpManager;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self loadSetting];
    }
    return self;
}

-(void)loadSetting{
    dispatch_queue_t sQueue = dispatch_queue_create("Server queue", NULL);
    _reciveSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self
                                                  delegateQueue:sQueue];
    
    NSError *error;
    [_reciveSocket bindToPort:udpServerPort error:&error];
    if (error) {
        NSLog(@"服务端绑定失败");
    }
    NSError *perror;
    [_reciveSocket beginReceiving:&perror];
    if (perror) {
        NSLog(@"客户端收数据失败");
    }
}

- (void)dealloc {
    [_reciveSocket close];
    _reciveSocket = nil;
}

- (void)sendData:(NSData *)data
          toHost:(NSString *)host
            port:(uint16_t)port
     withTimeout:(NSTimeInterval)timeout
             tag:(long)tag
{
//    NSLog(@"udp == %s",[data bytes]);
    [_reciveSocket sendData:data toHost:host port:port withTimeout:timeout tag:tag];
}


#pragma mark - delegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    if (tag == 200) {
        NSLog(@"client发送失败-->%@",error);
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    if (self.delegate) {
        [self.delegate udpManagerdidReceiveData:data fromAddress:address withFilterContext:filterContext];
    }
}

@end
