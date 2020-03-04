import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_daily/blocs/authentication_bloc.dart';
import 'package:quick_daily/models/team.dart';
import 'package:quick_daily/repositories/api_repository.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<HomePage> {
  /// create a channelController to retrieve text value
  final _channelController = TextEditingController();

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
      },
      onLongPress: (){
        // do something else
      },
    );
  }
}
