# Bluetooth
### iOS下的CoreBluetooth封装

-----

## WHAT 是什么

> iOS下的CoreBluetooth封装，iOS设备作为为中心设备（Central）。

### 方法

#### ` +sharedBluetooth `

初始化方法（单例），会创建中心角色（central manager）。

* #### 声明

	```
	+ (instancetype)sharedBluetooth
	```
	
* #### 返回值

	返回LSBluetooth的实例对象。
	
----

#### ` - notificationForBluetoothStateWithObserver:`

添加蓝牙连接状态的观察者。

* #### 声明

	```
	- (void)notificationForBluetoothStateWithObserver:(id)observer
	```

* #### 参数列表

	| 参数名 | 描述 |
	| ------------ | ------------- |
	| observer | 观察者 |
	
----

#### ` - discoverWithServices: options: `

扫描外设。

> 存放扫描指定设备的UUID号数组，为nil时扫描全部设备

* #### 声明

	```
	- (void)discoverWithServices:(nullable NSArray<CBUUID *> *)serviceUUIDs options:(nullable NSDictionary<NSString *, id> *)options
	```
	
* #### 参数列表

	| 参数名 | 描述 |
	| ------------ | ------------- |
	| serviceUUIDs | 存放设备的UUID号数组 |
	| options | 一般为nil |
	
----
	
#### ` - connectWithPeripheral: `
连接指定的外围设备

* #### 声明

	```
	- (void)connectWithPeripheral:(CBPeripheral *)peripheral
	
	```
	
* #### 参数列表

	| 参数名 | 描述 |
	| ------------ | ------------- |
	| peripheral | 要连接的外围设备 |
	

----	

#### ` - writeCharacteristic: value: peripheral: `
写特征值

* #### 声明

	```
	- (void)writeCharacteristic:(CBCharacteristic *)characteristic value:(NSData *)value peripheral:( CBPeripheral *)peripheral;
	
	```
	
* #### 参数列表

	| 参数名 | 描述 |
	| ------------ | ------------- |
	| characteristic | 特征 |
	| value | 特征值 |
	| peripheral | 当前外围设备 |
	

----	

#### ` - (void)notifyCharacteristicFromPeripheral: characteristic: `
订阅通知

* #### 声明

	```
	- (void)notifyCharacteristicFromPeripheral:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic;
	```
	
* #### 参数列表

	| 参数名 | 描述 |
	| ------------ | ------------- |
	| peripheral | 当前的外围设备 |
	| characteristic | 特征值 |
	
----	


#### ` - cancelCharacteristicFromPeripheral: characteristic: `
取消订阅通知

* #### 声明

	```
	- (void)cancelCharacteristicFromPeripheral:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic;
	```
	
* #### 参数列表

	| 参数名 | 描述 |
	| ------------ | ------------- |
	| peripheral | 当前的外围设备 |
	| characteristic | 特征值 |
	
----	

#### ` - disconnectPeripheral: `
断开与外围设备的连接

* #### 声明

	```
	- (void)disconnectPeripheral:(CBPeripheral *)peripheral;
	```
	
* #### 参数列表

	| 参数名 | 描述 |
	| ------------ | ------------- |
	| peripheral | 当前的外围设备 |
	
----	
### LSBluetooth协议

#### 协议名称
` LSBluetooth `

#### 协议方法

##### ` - bluetoothConnectSuccess: ` *Optional*

成功连接外围设备后调用。

* ##### 声明
	
	```
	- (void)bluetoothConnectSuccess:(NSNotification *)notification
	```
* ##### 参数列表

	| 参数名 | 描述 |
	| ------------ | ------------- |
	| notification | 通知的userInfo中包含"peripheral","characteristics"信息 |
	
----

##### ` - bluetoothConnectFailed:` *Optional*

连接外围设备失败后调用。

* ##### 声明
	
	```
	- (void)bluetoothConnectFailed:(NSNotification *)notification
	```
* ##### 参数列表

	| 参数名 | 描述 |
	| ------------ | ------------- |
	| notification | 通知的userInfo中包含"peripheral"和"error"信息 |
 
 ---
 
 
##### ` - bluetoothDisconnect: ` *Optional*

与外围设备断开连接后调用

* ##### 声明
	
	```
	- (void)bluetoothDisconnect:(NSNotification *)notification
	```
* ##### 参数列表

	| 参数名 | 描述 |
	| ------------ | ------------- |
	| notification | 通知的userInfo中包含"peripheral"和"error"信息 |
 
 ---
 
##### ` - bluetoothValueChanged: ` *Optional*

特征值改变时调用。

* ##### 声明
	
	```
	- (void)bluetoothValueChanged:(NSNotification *) notification
	```
* ##### 参数列表

	| 参数名 | 描述 |
	| ------------ | ------------- |
	| notification | 通知的userInfo中包含"peripheral"和"characteristic" |
 
 ---

 
##### ` - bluetoothDiscoverBluetoothPeripheral: ` *Optional*

发现外围设备后调用

* ##### 声明
	
	```
	- (void)bluetoothDiscoverBluetoothPeripheral:(NSNotification *)notification
	```
* ##### 参数列表

	| 参数名 | 描述 |
	| ------------ | ------------- |
	| notification | 通知的userInfo中包含"peripheral" |
 
 ---
 



 
 
## HOW 如何使用

	


