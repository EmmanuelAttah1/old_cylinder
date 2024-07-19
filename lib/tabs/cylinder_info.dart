import 'package:flutter/material.dart';
import '../widgets/refil_date.dart';
import '../widgets/gas_progress.dart';

const Map<String, String> data = {
  "lastRefil": "MAR 19th 2024",
  "nextRefil": "JUN 1st 2024",
  "tag": "#newCylinder",
  "sensor": "newCylinder_sensor",
  "size": "12.5",
  "id": "1",
  "percentage": "0.7"
};

class CylinderInfo extends StatelessWidget {
  final double percent;
  final String tag;
  final String size;

  const CylinderInfo(
      {super.key,
      required this.percent,
      required this.tag,
      required this.size});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 220,
                height: 220, // Set the desired dimensions here
                child: GasProgress(
                    progress: percent,
                    gasUsed:
                        (double.parse(size) - percent * double.parse(size))),
              ),
              Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RefilDate(title: "Last Refil", date: data["lastRefil"]),
                      const SizedBox(width: 20),
                      RefilDate(title: "Next Refil", date: data["nextRefil"]),
                    ],
                  )),
              // Icon(Icons.circle)
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          decoration: const BoxDecoration(
            color: Color(0xFF274C77),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          ),
          width: double.maxFinite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: const Text(
                  "Cylinder info",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          "Tag : #$tag",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          "Sensor : #${tag}_sensor",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                        color: const Color(0x33C9D4DB),
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(children: [
                      const Text(
                        "Size",
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        "$size Kg",
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700),
                      )
                    ]),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 30),
                child: ElevatedButton(
                  onPressed: () {
                    // Add your onPressed logic here
                    
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF6096BA), // text color
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // rounded corners
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 24), // button padding
                  ),
                  child: const Text("ORDER REFIL"),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
