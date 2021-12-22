import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class LocationApp extends StatefulWidget {
  //const LocationApp({Key key}) : super(key: key);

  @override
  _LocationAppState createState() => _LocationAppState();
}

class _LocationAppState extends State<LocationApp> {
  bool mapToggle = false;
  var currentLocation;
  var clients=[];
  late GoogleMapController mapController;
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
  @override
  /*void initstate(){
    super.initState();
    allMarkers.add(Marker(markerId: MarkerId('my marker'),
    draggable: false,
    onTap: () {
      print('marker tapped');
    },
    position: LatLng(currentLocation.latitude,currentLocation.longitude)
    ));
  }*/

  void initState(){
    super.initState();
    Geolocator.getCurrentPosition().then((currloc) {
      setState(() {
        currentLocation = currloc;
        mapToggle = true;
        _addMarker(currentLocation.latitude, currentLocation.longitude, 'loc');
      });
    });
  }

  PopulateClients()
  {
    clients=[];
    FirebaseFirestore.instance.collection('markers').get().then((docs) {
      if(docs.docs.isNotEmpty){
        for(int i=0;i<docs.docs.length;++i)
          {
            clients.add(docs.docs[i].data);
           //initMarker(docs.docs[i].data);
          }
      }
    });
  }






  var locationMessage ="";
  void getCurrentLocation () async{
    var position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    var lastPosition = await Geolocator.getLastKnownPosition();
    print(lastPosition);
    setState(() {
      locationMessage="$position";
    });
  }
  @override

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         title:Text('Location services'),
        backgroundColor: Colors.pink,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on,
              size: 46.0,
              color: Colors.deepPurple,
            ),
            SizedBox(height: 30.0,),
            Text('GET USER LOCATION',style: TextStyle(fontSize: 24.0,fontWeight: FontWeight.bold),),
            SizedBox(height: 20.0,),
            Text(locationMessage),
            ElevatedButton(onPressed: (){
              getCurrentLocation();
            }, child: Text('GET CURRENT LOCATION'),
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.pink)),),
            Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height-80.0,
                  width: double.infinity,
                  child: mapToggle ?
                      GoogleMap(
                          onMapCreated: onMapCreated,
                          initialCameraPosition: CameraPosition(target: LatLng(currentLocation.latitude,currentLocation.longitude) ,
                            zoom: 8.0,
                           // markers: Set<Marker>.of(markers.values),

                          ),
                        //markers: Set.from(allMarkers),
                      ):
                      Center(child:
                        Text('Loading.. Please wait..',
                       style: TextStyle(
                         fontSize: 24.0,
                       ), ),
                      )

                )
              ],
            )
          ],

        ),
      ),
      );
  }
  void onMapCreated(controller) {
    setState(() {
      mapController = controller;
    });
  }

}
