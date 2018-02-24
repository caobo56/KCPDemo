//
//  SendViewController.m
//  textDemo
//
//  Created by caobo56 on 18/2/22.
//  Copyright © 2018年 caobo56. All rights reserved.
//

#import "SendViewController.h"

#import "KcpOnUdp.h"

/**
 *  客户端
 */
@interface SendViewController ()<KcpOnUdpDelegate>
{
    __weak IBOutlet UITextField *msgTF;
    __weak IBOutlet UITextField *ipTF;
    __weak IBOutlet UILabel *receiveLab;
}

@property (nonatomic,strong)KcpOnUdp * netWork;

@end

@implementation SendViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"KcpOnUdp节点";
    _netWork = [KcpOnUdp creatKcpOnUdpWithPort:10099];
    //启动KcpOnUdp 并设置启动时的端口
    _netWork.delegate = self;
    //设置代理，接受数据

}

#pragma mark 发送消息
- (IBAction)sendMsgClick:(UIButton *)sender {
    //向指定的 ip port 发送数据
    [_netWork sendMsg:msgTF.text toHost:ipTF.text toPort:10099];
}

#pragma mark KcpOnUdp delegate
//接收数据
-(void)kcpOnUdpDidReciveMsg:(NSString *)str{
    NSLog(@"kcpOnUdpDidReciveMsg = %@",str);
}

@end

