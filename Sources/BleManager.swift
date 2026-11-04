import Foundation
import CoreBluetooth

class BleManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    private var targetPeripheral: CBPeripheral?
    private var characteristic: CBCharacteristic?
    
    // این UUIDها باید دقیقاً با اندروید یکی باشند
    private let SERVICE_UUID = CBUUID(string: "0000FFF0-0000-1000-8000-00805F9B34FB")
    private let CHARACTERISTIC_UUID = CBUUID(string: "0000FFF1-0000-1000-8000-00805F9B34FB")
    
    var onConnected: (() -> Void)?
    var onDisconnected: (() -> Void)?
    var onDataReceived: ((String) -> Void)?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func startScanning() {
        if centralManager.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: [SERVICE_UUID], options: nil)
            print("PhoneX-iOS: Scanning for Android...")
        }
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning()
        } else {
            print("PhoneX-iOS: Bluetooth is not available")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("PhoneX-iOS: Found device: \(peripheral.name ?? "Unknown")")
        targetPeripheral = peripheral
        targetPeripheral?.delegate = self
        centralManager.stopScan()
        centralManager.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("PhoneX-iOS: Connected to Android!")
        onConnected?()
        peripheral.discoverServices([SERVICE_UUID])
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("PhoneX-iOS: Disconnected from Android")
        onDisconnected?()
        startScanning() // تلاش مجدد برای اتصال
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics([CHARACTERISTIC_UUID], for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for char in characteristics {
            if char.uuid == CHARACTERISTIC_UUID {
                self.characteristic = char
                print("PhoneX-iOS: Found characteristic, ready to receive data")
                // اجازه دادن به آیفون برای دریافت نوتیفیکیشن از اندروید
                peripheral.setNotifyValue(true, for: char)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value, let string = String(data: data, encoding: .utf8) {
            print("PhoneX-iOS: Received data from Android: \(string)")
            onDataReceived?(string)
        }
    }
    
    func sendDataToAndroid(data: String) {
        guard let peripheral = targetPeripheral, let char = characteristic else { return }
        let dataBytes = data.data(using: .utf8)!
        peripheral.writeValue(dataBytes, for: char, type: .withResponse)
    }
}