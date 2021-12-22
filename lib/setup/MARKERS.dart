import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class marker extends StatefulWidget {
  //const marker({Key key}) : super(key: key);

  @override
  _markerState createState() => _markerState();
}


class _markerState extends State<marker> {
  List <Marker> allMarkers=[];
  @override
  void initState(){
    super.initState();
    allMarkers.add(Marker(markerId: MarkerId('my marker'),
        draggable: false,
        onTap: () {
          print('marker tapped');
        },
        position: LatLng(40.1758,-74.008)
    ));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('map'),
      ),
      body: Center(
        child: Container(
          height: 400.0,
          width: MediaQuery.of(context).size.width,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(40.1758,-74.008),
              zoom: 12,
            ),
            markers: Set.from(allMarkers),
          ),
        ),
      ),
    );
  }
  
}

