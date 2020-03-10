import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_daily/blocs/authentication_bloc.dart';
import 'package:quick_daily/blocs/teams_bloc.dart';
import 'package:quick_daily/models/team.dart';
import 'package:quick_daily/models/user.dart';
import 'package:quick_daily/ui/call_page.dart';
import 'package:quick_daily/repositories/api_repository.dart';
import 'package:permission_handler/permission_handler.dart';

class TeamsPage extends StatelessWidget {
  final ApiRepository apiRepository;

  TeamsPage({Key key, this.apiRepository})
      : assert(apiRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) {
          return TeamsBloc(
            apiRepository: apiRepository,
          );
        },
        child: TeamsList(),
      ),
    );
  }
}

class TeamsList extends StatefulWidget {
  @override
  State<TeamsList> createState() => _TeamsState();
}

class _TeamsState extends State<TeamsList> {
  List<Team> teams = new List<Team>();

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<TeamsBloc>(context)
        .add(FetchTeams(user: new User(name: "test")));

    return BlocListener<TeamsBloc, TeamsState>(
      listener: (context, state) {
        if (state is TeamsError) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<TeamsBloc, TeamsState>(
        builder: (context, state) {
          if (state is TeamsLoaded) {
            this.teams = state.teams;
            return Scaffold(
              body: ListView(
                children: <Widget>[
                  Container(
                    alignment: Alignment.topRight,
                    child: PopupMenuButton<String>(
                      onSelected: (result) {
                        if (result == 'logout') {
                          BlocProvider.of<AuthenticationBloc>(context)
                              .add(LoggedOut());
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuItem<String>>[
                        PopupMenuItem<String>(
                          value: 'logout',
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.exit_to_app),
                              Text("Logout")
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: <Widget>[
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

          return Scaffold(
            body: ListView(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    _logoutContainer(context),
                    Container(
                      padding: EdgeInsets.only(top: 20),
                      child: CircularProgressIndicator(),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _logoutContainer(BuildContext context) {
    return Container(
      child: Center(
        child: RaisedButton(
          child: Text('logout'),
          onPressed: () {
            BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut());
          },
        ),
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
        onJoin(team);
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
