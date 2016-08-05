//
//  ViewController.m
//  LSBluetooth
//
//  Created by liushuai on 16/4/28.
//  Copyright © 2016年 liushuai1992@gmail.com. All rights reserved.
//

#import "ViewController.h"
#import "LSBluetooth.h"
#import "LSBluetoothHelper.h"
#import "LSBluetoothInfo.h"
#import "LSBluetoothMicro.h"
#import <CoreBluetooth/CoreBluetooth.h>


#define NSDATA_FROM_BYTES(bytes) [NSData dataWithBytes:bytes length:4]
Byte defaultValue[]         = {0x00};
//请求解锁
Byte requestUnlock[]        = {0x00, 0x00, 0x00, 0x00};
//请求失败
Byte respondUnlockFaild[]   = {0x01, 0x00, 0x01, 0x00};
//请求成功
Byte respondUnlockSuccess[] = {0x01, 0x01, 0x01, 0x01};
//鉴权失败
Byte requestAuthFauld[]     = {0x02, 0x00, 0x02, 0x00};
//鉴权成功
Byte requestAuthSuccess[]   = {0x02, 0x01, 0x02, 0x01};
//否认鉴权
Byte respondAuthFauld[]     = {0x03, 0x00, 0x03, 0x00};
//认可鉴权
Byte respondAuthSuccess[]   = {0x03, 0x01, 0x03, 0x01};



@interface ViewController () <LSBluetoothHelperDelegate, UITableViewDelegate, UITableViewDataSource, LSBluetooth>

@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (nonatomic, strong) NSMutableArray *arrForBLEs;

@end

@implementation ViewController {
    CBCharacteristic *characteristic;
    CBPeripheral *peripheral;
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[LSBluetooth sharedBluetooth] discoverWithServices:nil options:nil];
    [[LSBluetooth sharedBluetooth]
     notificationForBluetoothStateWithObserver:self];
    [LSBluetoothHelper sharedBluetoothHelper].delegate = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"pool"];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}


- (NSMutableArray *)arrForBLEs {
    if (!_arrForBLEs) {
        _arrForBLEs = [NSMutableArray array];
    }
    return _arrForBLEs;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updatePeripheralList:(NSArray *)arrForBLE {
    self.arrForBLEs = arrForBLE.mutableCopy;
    NSLog(@"ddd %@", self.arrForBLEs.description);
    [self.tableView reloadData];
}

#pragma mark - UITableView delegate methods
#pragma mark ** two request dataSoure delegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrForBLEs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"pool"];
    
    LSBluetoothInfo *info = self.arrForBLEs[indexPath.row];
    cell.textLabel.text = info.discoveredPeripheral.name;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LSBluetoothInfo *info = self.arrForBLEs[indexPath.row];
    [[LSBluetooth sharedBluetooth] connectWithPeripheral:info.discoveredPeripheral];
}

#pragma mark - LSBluetooth notification
- (void)bluetoothConnectSuccess:(NSNotification *)notification {
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = [UIColor greenColor];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"button" forState:UIControlStateNormal];
    btn.frame = CGRectMake(50, 50, 100, 30);
    [btn addTarget:self action:@selector(btn) forControlEvents:UIControlEventTouchUpInside];
    [vc.view addSubview:btn];
    
    [self presentViewController:vc animated:YES completion:^{
        NSDictionary *dic = notification.userInfo;
        NSArray *arr = [dic objectForKey:@"characteristics"];
        characteristic = [arr firstObject];
        
        NSDictionary *dic2 = notification.userInfo;
        peripheral =[dic2 objectForKey:@"peripheral"];
        
        [[LSBluetoothHelper sharedBluetoothHelper] saveBluetooth:peripheral];
    }];
}

- (void)btn {
    /** 1.请求解锁 */
    //请求解锁
    NSData *dataForRequestUnlock = NSDATA_FROM_BYTES(requestUnlock);
    [[LSBluetooth sharedBluetooth] notifyCharacteristicFromPeripheral:peripheral characteristic:characteristic];
    [[LSBluetooth sharedBluetooth] writeCharacteristic:characteristic value:dataForRequestUnlock peripheral: peripheral];
}

- (void)bluetoothDisconnect:(NSNotification *)notification {
    NSLog(@"%s", __FUNCTION__);
    
}

- (void)bluetoothConnectFailed:(NSNotification *)notification {
    NSLog(@"%s", __FUNCTION__);
    
}

- (void)bluetoothValueChanged:(NSNotification *)notification {
    NSLog(@"%s", __FUNCTION__);
    NSString *uuid = [notification.userInfo valueForKey:@"uuid"];
    NSData *value = [notification.userInfo valueForKey:@"value"];
    NSData *dataForDefaultValue = [NSData dataWithBytes:defaultValue length:1];
    
    /** 2 */
    //请求失败
    NSData *dataForRespondUnlockFaild = NSDATA_FROM_BYTES(respondUnlockFaild);
    //请求成功
    NSData *dataForRespondUnlockSuccess = NSDATA_FROM_BYTES(respondUnlockSuccess);
    
    /** 3 */
    //鉴权失败
    NSData *dataForRequestAuthFauld = NSDATA_FROM_BYTES(requestAuthFauld);
    //鉴权成功
    NSData *dataForRequestAuthSuccess = NSDATA_FROM_BYTES(requestAuthSuccess);
    
    /** 4 */
    //否认鉴权
    NSData *dataForRespondAuthFauld = NSDATA_FROM_BYTES(respondAuthFauld);
    //认可鉴权
    NSData *dataForRrespondAuthSuccess = NSDATA_FROM_BYTES(respondAuthSuccess);
    
    if ([value isEqual:dataForDefaultValue]) {
        NSLog(@"default");
    }
    
    if ([value isEqual:dataForRespondUnlockSuccess]) {
        //请求指纹验证
        //指纹验证成功执行
        [[LSBluetooth sharedBluetooth] writeCharacteristic:characteristic value:dataForRequestAuthSuccess peripheral: peripheral];
        //
        NSLog(@"success");
    }

    
    
    
    
    
}


@end
