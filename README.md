# KCPDemo
iOS 通讯UDP/KCP协议的使用

### 什么是KCP？

kcp协议是传输层的一个具有可靠性的传输层ARQ协议。它的设计是为了解决在网络拥堵情况下tcp协议的网络速度慢的问题。kcp力求在保证可靠性的情况下提高传输速度。kcp协议的关注点主要在控制数据的可靠性和提高传输速度上面，因此kcp没有规定下层传输协议，一般用udp作为下层传输协议，kcp层协议的数据包在udp数据报文的基础上增加控制头。当用户数据很大，大于一个udp包能承担的范围时（大于mss），kcp会将用户数据分片存储在多个kcp包中。因此每个kcp包称为一个分片。

为了提供可靠性，kcp采用了重传机制。为实现重传机制，kcp为每个分片分配一个唯一标识，接收方收到一个包后告知发送方接到的包的序号，发送方接到确认后再继续发送。而如果发送方在一定时间内（超时重传时间）没有接到确认，就说明数据包丢失了，发送方需要重传丢失的数据包，所以发送方会把待确认的数据缓存起来，方便重传。

个人理解：KCP 只是一种对UDP收发包的处理机制，并不具有通讯功能。需要额外的配置其底层的传输协议如UDP。另外，KCP是一种快速重传的ARQ协议，因此，需要使用KCP的节点，同时具有收发数据的功能，以便KCP获取到完整数据后发送接收完整的回调。
KCP的好处：就是比TCP浪费30%左右的带宽，提升UDP的数据发送速度，并提升UDP的可靠性。

### 需要注意：
此外，需要说明的是，由于kcp需要在收到数据后，给数据的发送方发送回执消息。发送数据时，也要收取一个从服务端返回的发送成功回执。

所以，一个正常运行的kcp-UDP节点，必然同时具备收取消息和发送消息的功能，因此，我demo 里不再区分client 和 server 。

一个kcp节点，必然即是客户端，也是服务端。

### kcp协议详解
https://www.cnblogs.com/yuanyifei1/p/6846310.html

### KCP C源代码：
https://github.com/skywind3000/kcp

使用方法在KCP github 上写的很清晰，我这里不在重复。
传送门：https://github.com/skywind3000/kcp/blob/master/README.md

此demo就是我使用OC 实现UDP 的协议传输数据。

### 最终的使用方法：
```
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

```
此外，我用来跟客户端/服务端 链接测试的例子是jkcp， https://github.com/beykery/jkcp
在开发调试过程中可以以此作为调试基准进行测试。

### 配置说明：
调试过程中注意客户端服务端的kcp参数要保持一致，以下是我的配置：
server 配置：
```
        TestServer s = new TestServer(10099, 1);
        s.noDelay(1, 10, 2, 1);
        s.setMinRto(10);
        s.wndSize(128, 128);
        s.setTimeout(10 * 1000);
        s.setMtu(512);
        s.start();
```

clinet 配置：
```
    TestClient tc = new TestClient();
    tc.noDelay(1, 10, 2, 1);
    tc.setMinRto(10);
    tc.wndSize(128, 128);
    tc.setTimeout(10 * 1000);
    tc.setMtu(512);
    tc.setConv(121106);
```

iOS 端配置：
```
    //设置KCP参数，同服务端或者对点端参数保持一致
    //特别是conv，对方客户端的conv 必须同自身服务端的conv一致
    int32_t conv = 121106;
    c_kcp = ikcp_create(conv, NULL);
    ikcp_nodelay(c_kcp, 1, 10, 2, 1);
    c_kcp->rx_minrto = 10;
    ikcp_wndsize(c_kcp, 128, 128);
    ikcp_setmtu(c_kcp, 512);
```
