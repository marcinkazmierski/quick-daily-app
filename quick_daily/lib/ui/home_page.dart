import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_daily/models/team.dart';
import 'package:quick_daily/blocs/authentication_bloc.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<HomePage> {
  /// create a channelController to retrieve text value
  final _channelController = TextEditingController();

  /// if channel textField is validated to have error
  bool _validateError = false;

  List teams = [
    Team(
        id: 1,
        name: "Team A",
        description: "Work in Poznań",
        imageUrl:
            "https://d36tnp772eyphs.cloudfront.net/blogs/1/2018/02/Taj-Mahal.jpg"),
    Team(
        id: 2,
        name: "Team B",
        description: "Work in Home",
        imageUrl:
            "https://d36tnp772eyphs.cloudfront.net/blogs/1/2016/03/petra-jordan9.jpg"),
    Team(
        id: 3,
        name: "Team C",
        description: "Holidays",
        imageUrl:
            "https://d36tnp772eyphs.cloudfront.net/blogs/1/2018/02/Machu-Picchu-around-sunset.jpg"),
  ];

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
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Image.network(teams[index].imageUrl),
                    title: Text(teams[index].name),
                    subtitle: Text(teams[index].description),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
