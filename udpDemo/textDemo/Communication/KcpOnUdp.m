//
//  KcpOnUdp.m
//  textDemo
//
//  Created by caobo56 on 2018/2/23.
//  Copyright © 2018年 caobo. All rights reserved.
//

#import "KcpOnUdp.h"

#import "UDPManager.h"

#import <arpa/inet.h>
#import <netdb.h>
#import "ikcp.h"

@interface KcpOnUdp ()<UDPManagerDelegate>

@property(nonatomic,strong)UDPManager *udpManager;

@end

@implementation KcpOnUdp

ikcpcb * c_kcp;

static NSString * c_host = @"0.0.0.0";
static int c_port = 10099;

static UDPManager * c_udpManager;

+(KcpOnUdp *)creatKcpOnUdpWithPort:(int)port{
    KcpOnUdp * sender = [[KcpOnUdp alloc]init];
    [sender loadSettingWithPort:port];
    return sender;
}

-(void)loadSettingWithPort:(int)port{

    _udpManager = [UDPManager shareUDPManagerWithPort:port];
    c_udpManager = _udpManager;
    c_udpManager.delegate = self;

    //设置KCP参数，同服务端或者对点端参数保持一致
    int32_t conv = 121106;
    c_kcp = ikcp_create(conv, NULL);
    c_kcp->output = c_udp_output;
    ikcp_nodelay(c_kcp, 1, 10, 2, 1);
    c_kcp->rx_minrto = 10;
    ikcp_wndsize(c_kcp, 128, 128);
    ikcp_setmtu(c_kcp, 512);
    
    NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:0.0001f
                                                       target:self
                                                     selector:@selector(timerFire:)
                                                     userInfo:nil
                                                      repeats:YES];
    [timer fire];
}

-(void)timerFire:(id)userinfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        ikcp_update(c_kcp,clock());
    });
}

-(void)sendMsg:(NSString *)msg toHost:(NSString *)ip toPort:(int)port{
    c_host = ip;
    c_port = port;
    NSData *sendData = [msg dataUsingEncoding:NSUTF8StringEncoding];
    int a = ikcp_send(c_kcp, sendData.bytes, (int)sendData.length);
    NSLog(@" -- ikcp_send => %d  size => %ld %@",a,(unsigned long)sendData.length, sendData);
}

#pragma mark - delegate
-(void)udpManagerdidReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    NSLog(@" --- sock didReceive ---%lu --- %hu",(unsigned long)data.length,[GCDAsyncUdpSocket portFromAddress:address]);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!data || !address) {
            return;
        }
        
        if (data.length == 0) {
            return;
        }
        
        int input = ikcp_input(c_kcp, data.bytes, data.length);
        NSLog(@" --- input - %d len ---%lu",input,(unsigned long)data.length);
        
        if (input != 0) {
            return;
        }
        
        NSLog(@" --- len ---%lu",(unsigned long)data.length);
        char buffer[1000000];
        int recv = ikcp_recv(c_kcp, buffer, sizeof(buffer));
        NSLog(@" --- recv -- %d",recv);
        if (recv > 0) {
            c_host = [GCDAsyncUdpSocket hostFromAddress:address];
            c_port = [GCDAsyncUdpSocket portFromAddress:address];
            NSData * receiveData = [NSData dataWithBytes:buffer length:recv];
            NSString *receiveStr = [[NSString alloc] initWithData:receiveData encoding:NSUTF8StringEncoding];
            NSLog(@"服务器ip地址--->%@,port---%u,内容--->%@",
                  [GCDAsyncUdpSocket hostFromAddress:address],
                  [GCDAsyncUdpSocket portFromAddress:address],
                  receiveStr);
            [self.delegate kcpOnUdpDidReciveMsg:receiveStr];
        }
    });
}


int c_udp_output(const char * buf, int len, ikcpcb * kcp, void * user)
{
    NSData * data = [NSData dataWithBytes:buf length:len];
    NSLog(@"\n host == %@ port == %d conv = %d",c_host,c_port,kcp->conv);
    NSLog(@"\n data == %@",data);
    [c_udpManager sendData:data toHost:c_host port:c_port withTimeout:10 * 1000 tag:0];
    return 0;
}


@end














