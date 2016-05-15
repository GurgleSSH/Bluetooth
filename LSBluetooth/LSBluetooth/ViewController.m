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
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController () <LSBluetoothHelperDelegate, UITableViewDelegate, UITableViewDataSource, LSBluetooth>

@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (nonatomic, strong) NSMutableArray *arrForBLEs;

@end

@implementation ViewController

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
    [self presentViewController:vc animated:YES completion:^{
        NSDictionary *dic = notification.userInfo;
        NSArray *arr = [dic objectForKey:@"characteristics"];
        CBCharacteristic *characteristic = [arr firstObject];
        
        NSDictionary *dic2 = notification.userInfo;
        CBPeripheral *peripheral =[dic2 objectForKey:@"peripheral"];
        
        [[LSBluetoothHelper sharedBluetoothHelper] saveBluetooth:peripheral];
        
        const char * string = "Hi";
        NSData *data = [NSData dataWithBytes:string length:2];
        [[LSBluetooth sharedBluetooth] writeCharacteristic:characteristic value:data peripheral: peripheral];
    }];
}

- (void)bluetoothDisconnect:(NSNotification *)notification {
    NSLog(@"%s", __FUNCTION__);
    
}

- (void)bluetoothConnectFailed:(NSNotification *)notification {
    NSLog(@"%s", __FUNCTION__);
    
}
@end
