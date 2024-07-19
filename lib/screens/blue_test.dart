import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class MyBluetooth extends StatefulWidget {
  const MyBluetooth({super.key});

  @override
  State<MyBluetooth> createState() => _MyBluetoothState();
}

class _MyBluetoothState extends State<MyBluetooth> {
  List<ScanResult> scanResults = [];
  bool lightOn = false;
  int current = 0;

  Future<void> _connectToDevice(int index) async {
    BluetoothDevice device = scanResults[index].device;

    setState(() {
      current = index;
    });
    // listen for disconnection
    var subscription =
        device.connectionState.listen((BluetoothConnectionState state) async {
      if (state == BluetoothConnectionState.disconnected) {
        // 1. typically, start a periodic timer that tries to
        //    reconnect, or just call connect() again right now
        // 2. you must always re-discover services after disconnection!
        //print("${device.disconnectReasonCode} ${device.disconnectReasonDescription}");
      }
    });

// cleanup: cancel subscription when disconnected
// Note: `delayed:true` lets us receive the `disconnected` event in our handler
// Note: `next:true` means cancel on *next* disconnection. Without this, it
//   would cancel immediately because we're already disconnected right now.
    device.cancelWhenDisconnected(subscription, delayed: true, next: true);

// Connect to the device
    await device.connect();

// // Disconnect from device
//     await device.disconnect();

// // cancel to prevent duplicate listeners
//     subscription.cancel();
  }

  Future<void> _toggleLight() async {
    BluetoothDevice device = scanResults[current].device;
    // Note: You must call discoverServices after every re-connection!
    // List<BluetoothService> services = await device.discoverServices();
    // services.forEach((service) {
    //   // do something with service
    //   if(service.serviceUuid == "19b10000-e8f2-537e-4f6c-d104768a1214"){

    //   }
    //   print(service);
    // });
    
    // Discover services and characteristics
    List<BluetoothService> services = await device.discoverServices();
    for (var service in services) {
      service.characteristics.forEach((characteristic) async {
        // Check if this is the characteristic we want to write to
        debugPrint("my id ${characteristic.uuid.toString().toLowerCase()}");
        if (characteristic.uuid.toString().toLowerCase() == "19b10001-e8f2-537e-4f6c-d104768a1214") {
          var val = lightOn ? "OFF" : "ON";

          // Convert the string to bytes using UTF-8 encoding
          List<int> bytesToSend = utf8.encode(val);

          await characteristic.write(bytesToSend);

          //Write the value 1 to the characteristic
          // await characteristic.write([val]);
          setState(() {
            lightOn = !lightOn;
          });
          debugPrint('Value written to characteristic.');
        }
      });
    }

    // Disconnect from the device
    // await device.disconnect();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: scanResults.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    onTap: () {
                      _connectToDevice(index);
                    },
                    title: Text(scanResults[index].advertisementData.advName),
                  );
                }),
          ),
          ElevatedButton(
              onPressed: () async {
                //final List<ScanResult> result =
                await FlutterBluePlus.startScan();

                var subscription = FlutterBluePlus.onScanResults.listen(
                  (results) {
                    if (results.isNotEmpty) {
                      ScanResult r =
                          results.last; // the most recently found device
                      setState(() {
                        scanResults = results;
                      });
                      print(
                          '${r.device.remoteId}: "${r.advertisementData.advName}" found!');
                      print("$results");
                    }
                  },
                  onError: (e) => print(e),
                );

                // cleanup: cancel subscription when scanning stops
                FlutterBluePlus.cancelWhenScanComplete(subscription);
              },
              child: const Text("Start Scan")),
              ElevatedButton(onPressed: _toggleLight, child: const Text("Toggle LED"))
        ],
      ),
    ));
  }
}
