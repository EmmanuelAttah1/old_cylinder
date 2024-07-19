import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cylinder/widgets/animated_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import "../widgets/accordion.dart";
import "../widgets/bluetooth_item.dart";


//Done: clean up bluetooth code and release resources
//TODO: check if  bluetooth is on

class AddCylinder extends StatefulWidget {
  final Future<void> Function(String tag, String size) createCylinder;

  const AddCylinder({super.key, required this.createCylinder});

  @override
  State<AddCylinder> createState() => _AddCylinderState();
}

class _AddCylinderState extends State<AddCylinder> {
  List<bool> _tabOpened = [];
  List<ScanResult> scanResults = [];
  bool bluetothConnected = false;
  int? currentConectedDevice;

  StreamSubscription<BluetoothConnectionState>? subscription;

  final _formKey = GlobalKey<FormState>();
  final cylinderForm = GlobalKey<FormState>();

  TextEditingController wifiSsidController = TextEditingController();
  TextEditingController wifiPasswordController = TextEditingController();

  TextEditingController tagController = TextEditingController();
  TextEditingController sizeController = TextEditingController();

  void saveCylinder() {
    debugPrint("Saving cylinder");
    if (cylinderForm.currentState!.validate()) {
      widget.createCylinder(
          tagController.value.text, sizeController.value.text);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabOpened = [true, false, false];
    startScan();
  }

  @override
  void dispose() {
    disconnectBluetooth();
    wifiPasswordController.dispose();
    wifiSsidController.dispose();
    tagController.dispose();
    sizeController.dispose();

    super.dispose();
  }

  disconnectBluetooth() async {
    //check connected device before disconnecting
    // Disconnect from device
    BluetoothDevice device = scanResults[currentConectedDevice!].device;
    await device.disconnect();

    // cancel to prevent duplicate listeners
    subscription!.cancel();
  }

  turnOnBluetooth() async {
    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    } else {
      //TODO: Create UI to prompt IOS users to turn on bluetooth
    }
  }

  void startScan() async {
    await turnOnBluetooth();
    await FlutterBluePlus.startScan();

    var subscription = FlutterBluePlus.onScanResults.listen(
      (results) {
        if (results.isNotEmpty) {
          // ScanResult r = results.last; // the most recently found device
          setState(() {
            //results
            scanResults = results
                .where((item) => item.advertisementData.advName.isNotEmpty)
                .toList();
          });
        }
      },
      onError: (e) => debugPrint(e),
    );

    // cleanup: cancel subscription when scanning stops
    FlutterBluePlus.cancelWhenScanComplete(subscription);
  }

  Future<void> connectToDevice(int index) async {
    BluetoothDevice device = scanResults[index].device;

    setState(() {
      currentConectedDevice = index;
    });
    // listen for disconnection
    subscription =
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
    device.cancelWhenDisconnected(subscription!, delayed: true, next: true);

// Connect to the device
    await device.connect();

    setState(() {
      bluetothConnected = true;
    });
  }

  Future<void> sendWifiInfoThroughBluetooth() async {
    debugPrint("wifi name : ${wifiSsidController.value.text}");
    debugPrint("wifi password : ${wifiPasswordController.value.text}");

    BluetoothDevice device = scanResults[currentConectedDevice!].device;

    // Discover services and characteristics
    List<BluetoothService> services = await device.discoverServices();
    for (var service in services) {
      // ignore: avoid_function_literals_in_foreach_calls
      service.characteristics.forEach((characteristic) async {
        // Check if this is the characteristic we want to write to
        if (characteristic.uuid.toString().toLowerCase() ==
            "19b10001-e8f2-537e-4f6c-d104768a1214") {
          final subscription = characteristic.onValueReceived.listen((value) {
            debugPrint("recieved ${utf8.decode(value)}");
          });

          device.cancelWhenDisconnected(subscription);

          await characteristic.setNotifyValue(true);

          var val =
              "${wifiSsidController.value.text}:${wifiPasswordController.value.text}";
          // Convert the string to bytes using UTF-8 encoding
          List<int> bytesToSend = utf8.encode(val);

          await characteristic.write(bytesToSend);
          debugPrint('Value written to characteristic.');
        }
      });
    }
  }

  void openTab(index) {
    setState(() {
      for (var i = 0; i < _tabOpened.length; i++) {
        if (i == index) {
          _tabOpened[i] = !_tabOpened[i];
        } else {
          _tabOpened[i] = false;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var cyinderInfoContainer = CustomAccordion(
      opened: _tabOpened[2],
      openTab: openTab,
      index: 2,
      title: const Text(
        'Cylinder Information',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Form(
            key: cylinderForm,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 25),
                  child: AnimatedTextField(
                    inputController: tagController,
                    label: "Tag",
                    suffix: null,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 25),
                  child: AnimatedTextField(
                    inputController: sizeController,
                    label: "Size",
                    suffix: null,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );

    var wifiContainer = Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: CustomAccordion(
        opened: _tabOpened[1],
        openTab: openTab,
        index: 1,
        title: const Text(
          'WIFI Connection Information',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(bottom: 25),
                    child: AnimatedTextField(
                      inputController: wifiSsidController,
                      label: "WIFI SSID",
                      suffix: null,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 25),
                    child: AnimatedTextField(
                      label: "WIFI Password",
                      suffix: null,
                      inputController: wifiPasswordController,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Processing Data')),
                        );
                        sendWifiInfoThroughBluetooth();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0XFF1A2329),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // rounded corners
                      ),
                    ),
                    child: const Text("Save"))
              ],
            )
          ],
        ),
      ),
    );

    var bluetoothContainer = Column(children: [
      Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: CustomAccordion(
          opened: _tabOpened[0],
          openTab: openTab,
          index: 0,
          title: Text(
            bluetothConnected ? "Connected to sensor" : 'Connect to sensor',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
          content: SizedBox(
            height: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: const Text(
                    'Select the name of sensor you want to connect to',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: scanResults.length,
                      itemBuilder: (BuildContext context, int index) {
                        return BluetoothItem(
                            title: scanResults[index].advertisementData.advName,
                            connectFunction: connectToDevice,
                            index: index);
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
    ]);

    return Scaffold(
      backgroundColor: const Color(0xFFE7ECEF),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                child: const Text(
                  "Add new cylinder",
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
                ),
              ),
              bluetoothContainer,
              wifiContainer,
              cyinderInfoContainer,
              Container(
                margin: const EdgeInsets.symmetric(vertical: 40),
                width: double.maxFinite,
                child: ElevatedButton(
                  onPressed: () {
                    // Add your onPressed logic here
                    // turnOnBluetooth();
                    saveCylinder();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF6096BA), // text color
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // rounded corners
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 24), // button padding
                  ),
                  child: const Text("SAVE CYLINDER"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
