//
//  LSBluetooth.h
//  LSBluetooth
//
//  Created by liushuai on 16/4/28.
//  Copyright © 2016年 liushuai1992@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CBUUID;
@class CBPeripheral;
@class CBCharacteristic;


@protocol LSBluetooth <NSObject>

/**
 *  @brief 成功连接外围设备后调用
 *
 *  @param notification 通知的userInfo中包含"peripheral"信息
 */
- (void)bluetoothConnectSuccess:(nullable NSNotification *)notification;

/**
 *  @brief 连接外围设备失败后调用
 *
 *  @param notification 通知的userInfo中包含"peripheral"和"error"信息
 */
- (void)bluetoothConnectFailed:(nullable NSNotification *)notification;

/**
 *  @brief 与外围设备断开连接后调用
 *
 *  @param notification 通知的userInfo中包含"peripheral"和"error"信息
 */
- (void)bluetoothDisconnect:(nullable NSNotification *)notification;

@end

@interface LSBluetooth : NSObject

#pragma mark - init 初始化方法 + 1.create centralManager 创建中心角色
/**
 *  @brief 初始化方法，以单例形式实例化LSBluetooth类
 *
 *  @return 类的实例
 */
+ (nullable instancetype)sharedBluetooth;

#pragma mark -  add the observer of bluetooth's states 添加蓝牙连接状态的观察者
/**
 *  @brief add the observer of bluetooth's states 添加蓝牙连接状态的观察者
 *
 *  @param observer observer 观察者
 */
- (void)notificationForBluetoothStateWithObserver:(nullable id)observer;

#pragma mark - 2.discover 扫描外设
/**
 *  @brief 扫描(指定)设备
 *
 *  @param serviceUUIDs 存放扫描指定设备的UUID号数组，为nil时扫描全部设备
 */
- (void)discoverWithServices:(nullable NSArray<CBUUID *> *)serviceUUIDs options:(nullable NSDictionary<NSString *, id> *)options;

#pragma mark - 3.connect 连接外设
/**
 *  @brief 连接指定的外围设备
 *
 *  @param peripheral 要连接的外围设备
 */
- (void)connectWithPeripheral:(nullable CBPeripheral *)peripheral;

#pragma mark - 4.discover servers and characteristics 扫描外围设备的服务和特征
#pragma mark - 5.write characteristic 写特征值
/**
 *  @brief 写特征值
 *
 *  @param characteristic 特征
 *  @param value          特征值
 *  @param peripheral     当前外围设备
 */
- (void)writeCharacteristic:(nullable CBCharacteristic *)characteristic value:(nullable NSData *)value peripheral:(nullable CBPeripheral *)peripheral;

#pragma mark - 6.Characteristic Notification 特征通知
/**
 *  @brief 订阅通知
 *
 *  @param peripheral     当前的外围设备
 *  @param characteristic 特征值
 */
- (void)notifyCharacteristicFromPeripheral:(nullable CBPeripheral *)peripheral characteristic:(nullable CBCharacteristic *)characteristic;

/**
 *  @brief 取消订阅通知
 *
 *  @param peripheral     当前外围设备
 *  @param characteristic 特征值
 */

- (void)cancelCharacteristicFromPeripheral:(nullable CBPeripheral *)peripheral characteristic:(nullable CBCharacteristic *)characteristic;

#pragma mark - 7.Disconnect 断开连接
/**
 *  @brief 断开与外围设备的连接
 *
 *  @param peripheral 当前外围设备
 */
- (void)disconnectPeripheral:(nullable CBPeripheral *)peripheral;

@end
