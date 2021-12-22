import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class MAP extends StatefulWidget {
  //const MAP({Key key}) : super(key: key);

  @override
  _MAPState createState() => _MAPState();
}

 class _MAPState extends State<MAP> {
  bool mapToggle = false;
  var currentLocation;
  late GoogleMapController mapController;
  List <Marker> allMarkers=[];
  List <Marker> markers=[];
  void _addMarker(double lat,double lang,String name){
    var _marker = Marker(
        markerId: MarkerId(UniqueKey().toString()),
        position: LatLng(lat,lang ),
        icon:  BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        infoWindow: InfoWindow(title: name, snippet: '${lat},${lang}'));
    setState(() {
      markers.add(_marker);
    });}

  void initstate(){
    super.initState();
    allMarkers.add(Marker(markerId: MarkerId('my marker'),
        draggable: false,
        onTap: () {
          print('marker tapped');
        },
        position: LatLng(currentLocation.latitude,currentLocation.longitude)
    ));
  }
  //@override
  void initState() {
    super.initState();
    Geolocator.getCurrentPosition().then((currloc) {
      setState(() {
        currentLocation = currloc;
        mapToggle = true;
        _addMarker(currentLocation.latitude, currentLocation.longitude, 'loc');
      });
    });
    void onMapCreated(controller) {
      setState(() {
        mapController = controller;
      });
    }
  }
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('map'),
        ),
        body: Column(
          children: [
            Stack(
              children: [
                Container(
                    height: MediaQuery
                        .of(context)
                        .size
                        .height - 80.0,
                    width: double.infinity,
                    child: mapToggle ?
                    GoogleMap(
                      onMapCreated: onMapCreated,
                      initialCameraPosition: CameraPosition(target: LatLng(
                          currentLocation.latitude, currentLocation.longitude),
                        zoom: 8.0,

                      ),
                      markers: Set.from(allMarkers),
                    ) :
                    Center(child:
                    Text('Loading.. Please wait..',
                      style: TextStyle(
                        fontSize: 24.0,
                      ),),
                    )
                )
              ],
            )
          ],
        ),
      );
    }
 void onMapCreated(controller) {
    setState(() {
      mapController = controller;

    });
  }


}

