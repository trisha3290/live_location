import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:rxdart/rxdart.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyLocation extends StatefulWidget {
  const MyLocation(
      {Key? key,
        required this.username,
        required this.userid,
        required this.users,
        required this.grpid,
        required this.userlat,
        required this.userlong})
      : super(key: key);

  final List users;
  final String username;
  final String grpid;
  final String userid;
  final double userlat;
  final double userlong;
  @override
  _MyLocationState createState() => _MyLocationState();
}

class _MyLocationState extends State<MyLocation>
    with SingleTickerProviderStateMixin {
  late LocationData _currentPosition;
  bool _currentPositionbool = false;
  late GoogleMapController mapController;
  late Marker marker;
  Location location = Location();
  late GoogleMapController _controller;
  LatLng _initialcameraposition = LatLng(20.5937, 78.9629);
  bool _swipe = false;
  bool _showonappear = false;
  bool _myLocenabled = true;
  bool _isloading = true;
  BehaviorSubject<double> radius = BehaviorSubject();
  late Stream<List<DocumentSnapshot>> stream;
  List<Marker> markers = [];


  @override
  void initState() {
    super.initState();
    getLoc().whenComplete(() {
      setState(() {});
    });
    GeoFirePoint center =
    Geoflutterfire().point(latitude: widget.userlat, longitude: widget.userlong);
    stream = radius.switchMap((rad) {
      return Geoflutterfire()
          .collection(
          collectionRef:
          FirebaseFirestore.instance.collection('groups').doc(widget.grpid).collection('locations'))
          .within(
          center: center, radius: rad, field: 'position', strictMode: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController _controller) {
    _controller = _controller;
    if (_myLocenabled == true) {
      location.onLocationChanged.listen((l) {
        print(l.latitude);
        GeoFirePoint myLocation = Geoflutterfire()
            .point(latitude: l.latitude!, longitude: l.longitude!);
        dbadd(myLocation);
      });
      stream.listen((List<DocumentSnapshot> documentList) {
        _updateMarkers(documentList);
      });
    }
  }
  dbadd(GeoFirePoint myLocation){
    FirebaseFirestore.instance.collection('groups').doc(widget.grpid)
        .collection('locations').doc(widget.userid)
        .set({'name': widget.username, 'position': myLocation.data});

  }
  void _addMarker(double lat, double long, String name) {

    var _marker = (Marker(
      markerId: MarkerId(UniqueKey().toString()),
      position: LatLng(lat, long),
      icon: name == widget.username
          ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange)
          : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      draggable: false,
      infoWindow: InfoWindow(
        title: name,
        snippet: '$lat,$long',
      ),
    ));
    setState(() {
      markers.add(_marker);
    });
  }

  void _updateMarkers(List<DocumentSnapshot> documentList) {
    markers.clear();
    documentList.forEach((DocumentSnapshot document) {
      final GeoPoint point = document['position']['geopoint'];
      String name = document['name'];
      _addMarker(point.latitude, point.longitude, document['name']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: _isloading
            ? Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Center(child: Text('Loading... Please wait...',style: TextStyle(fontSize: 20.0),)))
            : Scaffold(
            backgroundColor: Colors.pink,
            appBar: AppBar(
              title: Text('Location Services', style: TextStyle(
                  color: Colors.white,
                  letterSpacing: 2,
                  fontSize: 20
              ),),
              centerTitle: true,
              backgroundColor: Colors.pinkAccent,
            ),
            body:
            Column(
              children:[
                Container(
                  height: MediaQuery.of(context).size.height/1.3,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(children: [

                    GoogleMap(
                      initialCameraPosition:
                      CameraPosition(target: _initialcameraposition, zoom: 8),
                      mapType: MapType.normal,
                      onMapCreated: (_controller) {
                        _onMapCreated(_controller);
                      },
                      myLocationEnabled: true,
                      markers: markers.toSet(),
                    ),
                    Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          child: ElevatedButton(
                            child: Icon(
                              Icons.location_pin,
                            ),
                            onPressed: getcurrentloc,
                          ),
                        )),



                  ]),),
                Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: Slider(
                    min: 0,
                    max: 1000,
                    divisions: 1000,
                    value: _value,
                    activeColor: Colors.blue,
                    inactiveColor: Colors.blue.withOpacity(0.2),
                    onChanged: (double value) => changed(value),
                  ),
                ),
                Text(
                  "Adjust Radius",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  _label,
                  style: TextStyle(fontWeight: FontWeight.w300),
                )

              ],)));
  }


  getLoc() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        setState(() {
          _myLocenabled = false;
        });
        setState(() {
          _isloading = false;
        });

        return;
      } else {
        setState(() {
          _isloading = false;
        });
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        setState(() {
          _myLocenabled = false;
        });
        setState(() {
          _isloading = false;
        });

        return;
      } else {
        setState(() {
          _isloading = false;
        });
      }
    }

    _currentPosition = await location.getLocation();
    setState(() {
      _currentPositionbool = true;
    });
    _initialcameraposition =
        LatLng(_currentPosition.latitude!, _currentPosition.longitude!);
    setState(() {
      _isloading = false;
    });
    location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _currentPosition = currentLocation;
        _initialcameraposition =
            LatLng(_currentPosition.latitude!, _currentPosition.longitude!);


      });
    });
  }
  Future<void> getcurrentloc() async {
    LocationData _currentPosition = await location.getLocation();
    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target:
            LatLng(_currentPosition.latitude!, _currentPosition.longitude!),
            zoom: 15),
      ),
    );
  }
  double _value = 1.0;
  String _label = '';

  changed(value) {
    setState(() {
      _value = value;
      markers.clear();
      radius.add(value);
    });
    setState(() {
      _label = '${_value.toInt().toString()} kms';
    });
  }
}


