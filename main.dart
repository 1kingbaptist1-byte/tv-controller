import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'dart:io';

void main() {
  runApp(TVControllerApp());
}

class TVControllerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TV Controller',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TVControlScreen(),
    );
  }
}

class TVControlScreen extends StatefulWidget {
  @override
  _TVControlScreenState createState() => _TVControlScreenState();
}

class _TVControlScreenState extends State<TVControlScreen> {
  List<Map<String, String>> devices = [];
  bool isScanning = false;

  // Discover UPnP devices (simplified)
  Future<void> scanForTVs() async {
    setState(() {
      isScanning = true;
      devices.clear();
    });

    try {
      // SSDP discovery message
      String ssdpMessage =
          'M-SEARCH * HTTP/1.1\r\nHOST: 239.255.255.250:1900\r\nMAN: "ssdp:discover"\r\nMX: 3\r\nST: upnp:rootdevice\r\n\r\n';
      var socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      socket.send(ssdpMessage.codeUnits, InternetAddress('239.255.255.250'), 1900);

      socket.listen((event) {
        if (event == RawSocketEvent.read) {
          var datagram = socket.receive();
          if (datagram != null) {
            String response = String.fromCharCodes(datagram.data);
            // Parse response for device info (simplified)
            if (response.contains('LOCATION')) {
              var location = response.split('LOCATION: ')[1].split('\r\n')[0];
              fetchDeviceInfo(location);
            }
          }
        }
      }, onDone: () {
        socket.close();
        setState(() {
          isScanning = false;
        });
      });

      // Timeout after 5 seconds
      await Future.delayed(Duration(seconds: 5), () => socket.close());
    } catch (e) {
      print('Error scanning: $e');
      setState(() {
        isScanning = false;
      });
    }
  }

  // Fetch device details from UPnP location URL
  Future<void> fetchDeviceInfo(String location) async {
    try {
      var response = await http.get(Uri.parse(location));
      if (response.statusCode == 200) {
        var xmlDoc = XmlDocument.parse(response.body);
        var friendlyName = xmlDoc.findAllElements('friendlyName').first.text;
        var ip = location.split('/')[2].split(':')[0];
        setState(() {
          devices.add({'name': friendlyName, 'ip': ip});
        });
      }
    } catch (e) {
      print('Error fetching device info: $e');
    }
  }

  // Send power command (hypothetical API)
  Future<void> togglePower(String ip, bool turnOn) async {
    try {
      // Example: Hypothetical TV API endpoint
      var url = Uri.parse('http://$ip:8080/api/power');
      var response = await http.post(
        url,
        body: {'state': turnOn ? 'on' : 'off'},
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('TV ${turnOn ? 'turned on' : 'turned off'}')),
        );
      } else {
        throw Exception('Failed to toggle power');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('TV Controller')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: isScanning ? null : scanForTVs,
            child: Text(isScanning ? 'Scanning...' : 'Scan for TVs'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                var device = devices[index];
                return ListTile(
                  title: Text(device['name'] ?? 'Unknown TV'),
                  subtitle: Text(device['ip'] ?? 'No IP'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.power),
                        onPressed: () => togglePower(device['ip']!, true),
                        tooltip: 'Turn On',
                      ),
                      IconButton(
                        icon: Icon(Icons.power_off),
                        onPressed: () => togglePower(device['ip']!, false),
                        tooltip: 'Turn Off',
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
