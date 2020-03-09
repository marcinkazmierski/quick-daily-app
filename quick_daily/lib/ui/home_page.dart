import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_daily/blocs/authentication_bloc.dart';
import 'package:quick_daily/models/team.dart';
import 'package:quick_daily/ui/call_page.dart';
import 'package:quick_daily/repositories/api_repository.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeState();
}

/// TODO: BLoC !!!!
///
///

class HomeState extends State<HomePage> {


  /// if channel textField is validated to have error
  bool _validateError = false;

  List<Team> teams = new List<Team>();

  @override
  void initState() {
    ApiRepository().getTeams().then((list) {
      setState(() {
        this.teams = list;
      });
    }).catchError((catchError) {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("API error"),
            content: Text(catchError.toString()),
          );
        },
      );
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                child: Center(
                    child: RaisedButton(
                  child: Text('logout'),
                  onPressed: () {
                    BlocProvider.of<AuthenticationBloc>(context)
                        .add(LoggedOut());
                  },
                )),
              ),
              ListView.builder(
                itemCount: teams.length,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemBuilder: _buildItemsForListView,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsForListView(BuildContext context, int index) {
    Team team = teams[index];
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(team.imageUrl),
      ),
      title: Text(team.name),
      subtitle: Text(team.description),
      trailing: Icon(Icons.keyboard_arrow_right),
      onTap: () {
        // do something
        /// TODO: new event -> new screen
        onJoin(team);
      },
      onLongPress: () {
        // do something else
      },
    );
  }

  Future<void> onJoin(Team team) async {
    // update input validation

    // await for camera and mic permissions before pushing video page
    await _handleMic();
    // push video page with given channel name

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallPage(
          team: team,
        ),
      ),
    );
  }

  Future<void> _handleMic() async {
    await PermissionHandler().requestPermissions(
      [PermissionGroup.microphone],
    );
  }
}
