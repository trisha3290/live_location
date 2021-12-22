import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class Markers extends StatefulWidget {
  //const Markers({Key key}) : super(key: key);

  @override
  _MarkersState createState() => _MarkersState();
}
var position,_lat,_long;
late GoogleMapController mapController;
bool mapToggle=false;
class _MarkersState extends State<Markers> {
  void getCurrentLocation() async{
    Position res= await Geolocator.getCurrentPosition();
    setState(() {
      position = res;
      _lat= position.latitude;
      _long=position.longitude;
    });

  }
  Set<Marker> _createMarker(){
    return<Marker>[
      Marker(markerId: MarkerId('home'),
      position: LatLng(position.latitude,position.longitude),
     icon:BitmapDescriptor.defaultMarker,
      infoWindow: InfoWindow(title:"home",snippet: position),)
    ].toSet();
  }
  var clients=[];
  PopulateClients()
  {
    clients=[];
    FirebaseFirestore.instance.collection('markers').get().then((docs) {
      if(docs.docs.isNotEmpty){
        for(int i=0;i<docs.docs.length;++i)
        {
          clients.add(docs.docs[i].data);
          initMarker(docs.docs[i].data,docs.docs[i].id);
        }
      }
    });
  }
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  void initMarker(request, requestId){
    var markerIdval= requestId;
    final MarkerId markerId=MarkerId(markerIdval,
    );
    final Marker marker=Marker(markerId: markerId,
    position: LatLng(request['location'].latitude,request['location'].longitude),
      infoWindow: InfoWindow(title: "fetched markers",snippet: request['user']),
    );
    setState(() {
      markers[markerId]=marker;
      print(markerId);
    });

  }
  @override
  void initState(){
    CircularProgressIndicator;
    getCurrentLocation();
    PopulateClients();
    super.initState();
  }
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('map with markers'),
      ),
    );
  }
  Widget mapWidget(){
    return GoogleMap(
        mapType: MapType.normal,
        markers: Set<Marker>.of(markers.values),
        initialCameraPosition: CameraPosition(
    target: LatLng(position.latitude,position.longitude),
    ));
  }
  void onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;

    });
  }
}


