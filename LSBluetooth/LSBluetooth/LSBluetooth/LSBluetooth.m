//
//  LSBluetooth.m
//  LSBluetooth
//
//  Created by liushuai on 16/4/28.
//  Copyright © 2016年 liushuai1992@gmail.com. All rights reserved.
//

#import "LSBluetoothMicro.h"

#import "LSBluetooth.h"
#import "LSBluetoothInfo.h"
#import "LSBluetoothHelper.h"
#import <CoreBluetooth/CoreBluetooth.h>

NSString *const BluetoothConnectSuccessNotification = @"LSBluetoothConnectSuccessNotification";
NSString *const BluetoothConnectFailureNotification = @"LSBluetoothConnectFailureNotification";
NSString *const BluetoothDisconnectNotification = @"LSBluetoothDisconnectNotification";
NSString *const BluetoothValueChangedNotification = @"LSBluetoothValueChangedNotification";
NSString *const BluetoothPeripheralDiscoverNotification = @"BluetoothPeripheralDiscoverNotification";



@interface LSBluetooth () <CBPeripheralDelegate, CBCentralManagerDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;

@end

@implementation LSBluetooth

#pragma mark - init 初始化方法

#pragma mark ** API
/**
 *  @brief 以单例形式实例化LSBluetooth类
 *
 *  @return 类的实例
 */
+ (instancetype)sharedBluetooth
{
    static LSBluetooth *bluetooth = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bluetooth = [[LSBluetooth alloc] init];
    });
    return bluetooth;
}
#pragma mark ** PRIVATE

#pragma mark -  add the observer of bluetooth's states 添加蓝牙连接状态的观察者
#pragma mark ** API
/**
 *  @brief add the observer of bluetooth's states 添加蓝牙连接状态的观察者
 *
 *  @param observer observer 观察者
 */
- (void)notificationForBluetoothStateWithObserver:(id)observer {
    //1.连接外围设备成功
    RESPONDS_TO(observer, bluetoothConnectSuccess:) {
        [[NSNotificationCenter defaultCenter] addObserver:observer selector:@selector(bluetoothConnectSuccess:) name:BluetoothConnectSuccessNotification object:nil];
    }
    //2.连接外围设备失败
    RESPONDS_TO(observer, bluetoothConnectFailed:) {
        [[NSNotificationCenter defaultCenter] addObserver:observer selector:@selector(bluetoothConnectFailed:) name:BluetoothConnectFailureNotification object:nil];
    }
    //3.与外围设备断开连接
    RESPONDS_TO(observer, bluetoothDisconnect:) {
        [[NSNotificationCenter defaultCenter] addObserver:observer selector:@selector(bluetoothDisconnect:) name:BluetoothDisconnectNotification object:nil];
    }
    //4.特征值改变
    RESPONDS_TO(observer, bluetoothValueChanged:) {
        [[NSNotificationCenter defaultCenter] addObserver:observer selector:@selector(bluetoothValueChanged:) name:BluetoothValueChangedNotification object:nil];
    }
    
    RESPONDS_TO(observer, bluetoothDiscoverBluetoothPeripheral:) {
        [[NSNotificationCenter defaultCenter] addObserver:observer selector:@selector(bluetoothDiscoverBluetoothPeripheral:) name:BluetoothPeripheralDiscoverNotification object:nil];
    }
}
#pragma mark ** PRIVATE

#pragma mark - 1.create centralManager 创建中心角色

#pragma mark ** API
#pragma mark ** PRIVATE
/**
 *  @brief 创建中心角色
 *
 *  @return 中心角色管理对象
 */
- (instancetype)init {
    self = [super init];
    if (self) {
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
        
    }
    return self;
}

#pragma mark - 2.discover 扫描外设
#pragma mark ** API
/**
 *  @brief 扫描(指定)设备
 *
 *  @param serviceUUIDs 存放扫描指定设备的UUID号数组，为nil时扫描全部设备
 */
- (void)discoverWithServices:(nullable NSArray<CBUUID *> *)serviceUUIDs options:(nullable NSDictionary<NSString *, id> *)options {
    [self.centralManager scanForPeripheralsWithServices:serviceUUIDs options:options];
}

#pragma mark ** PRIVATE 
/**
 *  @brief centralManager状态已经改变后回调
 *
 *  @param central 当前中心设备
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    //当centralManager的电源状态为打开时，开始扫描周围设备
    if (central.state == CBCentralManagerStatePoweredOn) {
        //扫描所有外设
        [self discoverWithServices:nil options:nil];
        NSLog(@"scan...");
    }
}

/**
 *  @brief 已经发现外围设备后回调
 *
 *  @param central           当前中心设备
 *  @param peripheral        当前外围设备
 *  @param advertisementData 广告数据
 *  @param RSSI              RSSI 信号强度
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    [[NSNotificationCenter defaultCenter] postNotificationName:BluetoothPeripheralDiscoverNotification object:nil userInfo:@{@"peripheral":peripheral}];
    LSBluetoothInfo *info = [[LSBluetoothInfo alloc] init];
    info.discoveredPeripheral = peripheral;
    info.rssi = RSSI;
    [[LSBluetoothHelper sharedBluetoothHelper] cacheBluetooth:info];
    NSLog(@"cache...");
    
}


#pragma mark - 3.connect 连接外设
#pragma mark ** API
/**
 *  @brief 连接指定的外围设备
 *
 *  @param peripheral 要连接的外围设备
 */
- (void)connectWithPeripheral:(CBPeripheral *)peripheral {
    //停止扫描
    [self.centralManager stopScan];
    //连接指定外设
    [self.centralManager connectPeripheral:peripheral options:nil];
}

#pragma mark ** PRIVATE
/**
 *  @brief 成功连接外围设备后回调
 *
 *  @param central    当前中心设备
 *  @param peripheral 当前外围设备
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    //已经成功连接外围设备，开始执行外围设备列表的清理工作
    [[LSBluetoothHelper sharedBluetoothHelper] cleanBluetoothCacheInfo];
    //设置委托对象
    peripheral.delegate = self;
    //获取外围设备的所有服务，成功后会进入方法：-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
    [peripheral discoverServices:nil];
    
}

/**
 *  @brief 外围设备断开连接后回调
 *
 *  @param central    当前中心设备
 *  @param peripheral 当前外围设备
 *  @param error      错误信息
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    //发送断开连接通知
    [[NSNotificationCenter defaultCenter] postNotificationName:BluetoothDisconnectNotification object:nil userInfo:@{@"peripheral":peripheral, @"error":error}];
    NSLog(@"外围设备%@断开连接:%@", peripheral.name, error.localizedDescription);
}

/**
 *  @brief 连接外围设备失败后回调
 *
 *  @param central    当前中心设备
 *  @param peripheral 当前外围设备
 *  @param error      错误信息
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:BluetoothConnectFailureNotification object:nil userInfo:@{@"peripheral":peripheral, @"error":error}];
    NSLog(@"连接到外围设备%@失败,%@", peripheral.name, error.localizedDescription);
}

#pragma mark - 4.discover servers and characteristics 扫描外围设备的服务和特征
#pragma mark ** API
#pragma mark ** PRIVATE
/**
 *  @brief 获取外围设备服务之后回调
 *
 *  @param peripheral 当前外围设备
 *  @param error      错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        NSLog(@"DiscoverServices:%@ error,reason:%@", peripheral.name, error.localizedDescription);
        return;
    }
    for (CBService *service in peripheral.services) {
        //扫描每个服务的特征值，扫描到特征值后会进入方法： -(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

/**
 *  @brief 扫描到特征值后回调
 *
 *  @param peripheral 当前外围设备
 *  @param service    当前服务
 *  @param error      错误信息
 */
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        NSLog(@"error Discovered characteristics for %@ with error: %@", service.UUID, [error localizedDescription]);
        return;
    }
    //遍历外围设备的所有特征值
    //读到数据会进入方法：-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
    for (CBCharacteristic *characteristic in service.characteristics) {
        [peripheral readValueForCharacteristic:characteristic];
        NSLog(@"service:%@ 的 Characteristic: %@",service.UUID,characteristic.UUID);
    }
    //发送连接成功通知
    [[NSNotificationCenter defaultCenter] postNotificationName:BluetoothConnectSuccessNotification object:nil userInfo:@{@"peripheral":peripheral, @"characteristics":service.characteristics}];
}

/**
 *  @brief 遍历到外围设备的特征值后回调
 *
 *  @param peripheral     当前外围设备
 *  @param characteristic 特征值
 *  @param error          错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    //打印出characteristic的UUID和值
    //!注意，value的类型是NSData，具体开发时，会根据外设协议制定的方式去解析数据
    NSLog(@"characteristic uuid:%@  value:%@",characteristic.UUID,characteristic.value);
    if (![characteristic isEqual:nil]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:BluetoothValueChangedNotification object:nil userInfo:@{@"peripheral":peripheral, @"characteristic":characteristic}];
    }
}

/**
 *  @brief 搜索到的特征值的描述descriptor
 *
 *  @param peripheral     当前外围设备
 *  @param characteristic 特征值
 *  @param error          错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    //打印出Characteristic和他的Descriptors
    NSLog(@"characteristic uuid:%@",characteristic.UUID);
    for (CBDescriptor *descriptor in characteristic.descriptors) {
        NSLog(@"Descriptor uuid:%@",descriptor.UUID);
    }
}

/**
 *  @brief 获取descriptor的值
 *
 *  @param peripheral 当前外围设备
 *  @param descriptor descriptor
 *  @param error      错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
    //打印出DescriptorsUUID 和value
    //这个descriptor都是对于characteristic的描述，一般都是字符串
    NSLog(@"characteristic uuid:%@  value:%@",[NSString stringWithFormat:@"%@",descriptor.UUID],descriptor.value);
    
}

#pragma mark - 5.write characteristic 写特征值
#pragma mark ** API
/**
 *  @brief 写特征值
 *
 *  @param characteristic 特征
 *  @param value          特征值
 *  @param peripheral     当前外围设备
 */
- (void)writeCharacteristic:(CBCharacteristic *)characteristic
                     value:(NSData *)value peripheral:(CBPeripheral *)peripheral {
    NSLog(@"%lu", (unsigned long)characteristic.properties);
    //只有 characteristic.properties 有write的权限才可以写
    if(characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse){
        /*
         最好一个type参数可以为CBCharacteristicWriteWithResponse或type:CBCharacteristicWriteWithResponse区别是是否会有反馈
         */
        [peripheral writeValue:value forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
    }else{
        NSLog(@"该字段不可写！");
    }
}

#pragma mark ** PRIVATE
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"Error writing characteristic value: %@",
              [error localizedDescription]);
        return;
    }
    NSLog(@"写入%@成功",characteristic);
}

#pragma mark - 6. Characteristic Notification 特征通知
#pragma mark ** API
/**
 *  @brief 订阅通知
 *
 *  @param peripheral     当前的外围设备
 *  @param characteristic 特征值
 */
- (void)notifyCharacteristicFromPeripheral:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic {
    //设置通知，数据通知会进入：didUpdateValueForCharacteristic方法
    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
}

/**
 *  @brief 取消订阅通知
 *
 *  @param peripheral     当前外围设备
 *  @param characteristic 特征值
 */
- (void)cancelCharacteristicFromPeripheral:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic {
    [peripheral setNotifyValue:NO forCharacteristic:characteristic];
}
#pragma mark ** PRIVATE

#pragma mark - 7.Disconnect 断开连接
#pragma mark ** API
/**
 *  @brief 断开与外围设备的连接
 *
 *  @param peripheral 当前外围设备
 */
- (void)disconnectPeripheral:(CBPeripheral *)peripheral {
    //1.停止扫描
    [self.centralManager stopScan];
    //2.断开连接
    [self.centralManager cancelPeripheralConnection:peripheral];
}
#pragma mark ** PRIVATE

@end
