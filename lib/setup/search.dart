//import 'dart:html';

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';



class search extends StatefulWidget {
  const search({Key? key, required this.name})
      : super(key: key);
  final String name;
  @override
  _searchState createState() => _searchState();
}

class _searchState extends State<search> {

  late String name;
  List<String> _usernames =<String>[];
  List<String> _selectedusernames= <String>[];
  Map<String,bool> _selectedusernamesbool = <String,bool>{};
    late bool _isLoading=false;
  TextEditingController _groupnamecontroller = new TextEditingController();
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       // title: Text('Search username'),
        backgroundColor: Colors.pink,
        leading: _isSearching ? const BackButton() : null,
        title: _isSearching ? _buildSearchField() : _buildTitle(context),
        actions: _buildActions(),
      ),
     body: _isLoading
        ?  Center(child: CircularProgressIndicator())
      : Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('$searchQuery',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 29,
              letterSpacing: 2,

            ),
          ),
          Padding(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Wrap(
                  spacing: 6.0,
                  runSpacing: 6.0,
                  children: _selectedusernames
                      .map((item) => _buildChip(item,Colors.blueGrey)).toList().cast<Widget>()),

                  
                ),

              ),
          Container(
              child: _selectedusernames.isEmpty
                  ? null
                  : Divider(thickness: 1.0)),
          ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: _usernames.length,
            itemBuilder: (context, index) {
              return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 1.0, horizontal: 4.0),
                  child: Card(
                      color: _selectedusernamesbool[_usernames[index]]!


                          ? Colors.black12
                          : Colors.white,
                      child: ListTile(
                          onTap: () {
                            setState(() {
                              if (!_selectedusernamesbool[
                              _usernames[index]]!) {
                                _selectedusernames.insert(
                                    _selectedusernames.length,
                                    _usernames[index]);
                                _selectedusernamesbool.update(
                                    _usernames[index], (value) => true,
                                    ifAbsent: () => true);
                              } else {
                                _deleteselected(_usernames[index]);
                              }
                            });
                          },
                          leading: CircleAvatar(
                            backgroundColor: Colors.black,
                            child: Text(
                                _usernames[index][0].toUpperCase()),
                          ),
                          title: Text(_usernames[index]),
                          trailing:
                          _selectedusernamesbool[_usernames[index]]!
                              ? Icon(Icons.check)
                              : null)));
            },
          ),
        ],
     ),





      floatingActionButton: FloatingActionButton(
        onPressed: createGroup,
        backgroundColor: Colors.pink,
        child: const Icon(Icons.check),

      ),
    );
  }
  void _startSearch() {
    print("open search box");
    ModalRoute
        .of(context)!
        .addLocalHistoryEntry(new LocalHistoryEntry(onRemove: _stopSearching));

    setState(() {
      _isSearching = true;
    });
  }
  Widget _buildSearchField() {
    return new TextField(
      controller: _searchQuery,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Search...',
        border: InputBorder.none,
        hintStyle: const TextStyle(color: Colors.white30),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: (text){
        int i=0;
        _usernames.clear();
        FirebaseFirestore.instance.collection('data').where('name',isEqualTo: text).get().then((snapshot){
          setState(() {
            snapshot.docs.forEach((element) {
              if(element['name']!=name)
                {
                  if(!_usernames.contains(element['name']))
                    {
                      _usernames.insert(i, element['name']);
                      if(_selectedusernames.contains(element['name'])){
                        _selectedusernamesbool.update(element['name'], (value) => true,
                        ifAbsent: ()=>true);}
                        else
                          {
                            _selectedusernamesbool.update(element['name'], (value) => false,
                            ifAbsent: () => false);
                        
                      }
                    }i++;
                }
            });
          });
        });
      }
    );
  }
  void updateSearchQuery(String newQuery) {

    setState(() {
      searchQuery = newQuery;
    });
    print("search query " + newQuery);

  }
  List<Widget> _buildActions() {

    if (_isSearching) {
      return <Widget>[
        new IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchQuery.text.isEmpty) {
              Navigator.pop(context);
              return;
            }
            _clearSearchQuery();
          },
        ),
      ];
    }

    return <Widget>[
      new IconButton(
        icon: const Icon(Icons.search),
        onPressed: _startSearch,
      ),
    ];
  }
  late TextEditingController _searchQuery;
  bool _isSearching = false;
  String searchQuery = "Search query";

  @override
  void initState() {
    super.initState();
    _searchQuery = new TextEditingController();
    setState(() {

    });
  }



  void _stopSearching() {
    _clearSearchQuery();

    setState(() {
      _isSearching = false;
    });
  }

  void _clearSearchQuery() {
    print("close search box");
    setState(() {
      _searchQuery.clear();
      updateSearchQuery("Search query");
    });
  }
  createGroup() async{
    if(_selectedusernames.isEmpty){
      return 'Select user(s)';
    }
    else{
      setState(() {
        _isLoading = true;
      });
      await groupName(context);
    }
  }
  Future<dynamic> groupName(BuildContext context) async{
    return showDialog(context: context,builder:(BuildContext context)
    {
      child:
      return AlertDialog(
        title: Text('Enter a group name', style: TextStyle(
          color: Colors.black,
          letterSpacing: 2,
        ),),
        content: TextField(
          controller: _groupnamecontroller,
          decoration: InputDecoration(
              labelText: 'Group Name'
          ),
        ),
        actions: <Widget>[
          ElevatedButton(onPressed: () async {
            Navigator.of(context).pop();
            if (_groupnamecontroller.text.length != 0) {
              await createcollectiongroup();
            }
            setState(() {
              _isLoading = false;
            });
          }, child: Text('Create Group'),),
          ElevatedButton(onPressed: () async {
            setState(() {
              _isLoading = false;
            });
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            _groupnamecontroller.clear();
          }, child: Text('Cancel'),),
        ],
      );
    }
    );
  }


  Widget _buildTitle(BuildContext context) {
    var horizontalTitleAlignment =
    Platform.isIOS ? CrossAxisAlignment.center : CrossAxisAlignment.start;

    return new InkWell(
      //onTap: () => scaffoldKey.currentState.openDrawer(),
      child: new Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: horizontalTitleAlignment,
          children: <Widget>[
            const Text('Search box'),
          ],
        ),
      ),
    );

  }

  Future<void> createcollectiongroup()async {
   // var username;
    _selectedusernames.insert(_selectedusernames.length, widget.name);
    Map<String, dynamic> mapgroups = {
      'groupname': _groupnamecontroller.text,
      'name' : _selectedusernames
    };
    try{
      await FirebaseFirestore.instance.collection('groups').add(mapgroups);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Group Created')));
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      // Navigator.of(context).pop();
      setState(() {
        _selectedusernames.clear();
        _selectedusernamesbool.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to create group ${e}')));
    }

  }








}





_buildChip(String label, MaterialColor pink) {
  return Chip(labelPadding: EdgeInsets.all(2.0),
  avatar: CircleAvatar(
  backgroundColor: Colors.black,
  child: Text(label[0].toUpperCase()),
  ), label: Text(
  label,
  style: TextStyle(
  color: Colors.white,
  ),
  ),
  deleteIcon: Icon(
  Icons.close,
  ),
  onDeleted: () => _deleteselected(label),
  backgroundColor: Colors.pink,
  elevation: 6.0,
  shadowColor: Colors.grey[60],
  padding: EdgeInsets.all(8.0),
  
);}



_deleteselected(String label) {

}




