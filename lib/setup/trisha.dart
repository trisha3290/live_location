import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_done/setup/groups.dart';
import 'package:flutter/material.dart';


class AddUsers extends StatefulWidget {
  const AddUsers({Key? key,
    required this.username,
    required this.userid,
    required this.users,
    required this.grpid,})
      : super(key: key);
  final List users;
  final String username;
  final String grpid;
  final String userid;

  @override
  _AddUsersState createState() => _AddUsersState();
}




class _AddUsersState extends State<AddUsers>
    with SingleTickerProviderStateMixin {
  static final GlobalKey<ScaffoldState> scaffoldKey =
  new GlobalKey<ScaffoldState>();

  late TextEditingController _searchQuery;
  bool _isSearching = false;
  String searchQuery = "Search query";

  // late String _username;
  List<String> _usernames = <String>[];
  List<String> _selectedusernames = <String>[];
  bool _isLoading = false;
  Map<String, bool> _selectedusernamesbool = <String, bool>{};
  TextEditingController _groupnamecontroller = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchQuery = new TextEditingController();
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
      updateSearchQuery("Search query",);
    });
  }


  Widget _buildTitle(BuildContext context) {
    var horizontalTitleAlignment =
    Platform.isIOS ? CrossAxisAlignment.center : CrossAxisAlignment.start;

    return new InkWell(
      onTap: () => scaffoldKey.currentState!.openDrawer(),
      child: new Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: horizontalTitleAlignment,
          children: <Widget>[
            const Text('Seach box', style: TextStyle(
                color: Colors.amber,
                letterSpacing: 2,
                fontStyle: FontStyle.italic
            )),
          ],
        ),
      ),
    );
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
        onChanged: (text) {
          int i = 0;
          _usernames.clear();
          FirebaseFirestore.instance
              .collection('data')
              .where('name', isEqualTo: text)
              .get()
              .then((snapshot) {
            setState(() {
              snapshot.docs.forEach((element) {
                if (element['name'] != widget.username) {
                  if (!_usernames.contains(element['name'])) {
                    _usernames.insert(i, element['name']);
                    if (_selectedusernames.contains(element['name'])) {
                      _selectedusernamesbool.update(
                          element['name'], (value) => true,
                          ifAbsent: () => true
                      );
                      // print(widget.username);

                    } else {
                      _selectedusernamesbool.update(
                          element['name'], (value) => false,
                          ifAbsent: () => false
                      );
                    }
                  }
                  i++;
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
            if (_searchQuery == null || _searchQuery.text.isEmpty) {
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.grey[900],
        appBar: new AppBar(
          leading: _isSearching ? const BackButton() : null,
          title: _isSearching ? _buildSearchField() : _buildTitle(context),
          actions: _buildActions(),
          centerTitle: true,
          backgroundColor: Colors.brown,
        ),
        // body: new Center(
        //   child: new Column(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: <Widget>[
        //       new Text(
        //         '$searchQuery',
        //           style: TextStyle(
        //             color: Colors.grey,
        //             fontSize: 29,
        //             letterSpacing: 2,
        //           )
        //       ),
        //     ],
        //   ),
        // ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('$searchQuery',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 29,
                  letterSpacing: 2,

                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 1.0, horizontal: 4.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Wrap(
                      spacing: 6.0,
                      runSpacing: 6.0,
                      children: _selectedusernames
                          .map((item) => _buildChip(item, Color(0xFFff6666)))
                          .toList()
                          .cast<Widget>()),
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
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.check),
          onPressed: modifiedGroup,
        )
    );
    //
    //



  }
  Widget _buildChip(String label, Color color) {
    return Chip(
      labelPadding: EdgeInsets.all(2.0),
      avatar: CircleAvatar(
        backgroundColor: Colors.black,
        child: Text(label[0].toUpperCase()),
      ),
      label: Text(
        label,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      deleteIcon: Icon(
        Icons.close,
      ),
      onDeleted: () => _deleteselected(label),
      backgroundColor: color,
      elevation: 6.0,
      shadowColor: Colors.grey[60],
      padding: EdgeInsets.all(8.0),
    );
  }
  void _deleteselected(String label) {
    setState(
          () {
        _selectedusernamesbool.update(label, (value) => false,
            ifAbsent: () => false);
        _selectedusernames.removeAt(_selectedusernames.indexOf(label));
      },
    );
  }
  modifiedGroup() async{
    if(_selectedusernames.isEmpty){
      return 'Select user(s)';
    }
    else{
      setState(() {
        _isLoading = true;
      });
      final doc = await FirebaseFirestore.instance.collection('groups').doc(widget.grpid).get();
      Map data = doc.data() as Map<String,dynamic>;
      var oldUserList = data["users"] as List;
      oldUserList.addAll(_selectedusernames);
      await FirebaseFirestore.instance.collection('groups').doc(widget.grpid).update({
        'users' : oldUserList as List,
      });
      setState(() {
        _isLoading = false;
      });
    }
  }
}
