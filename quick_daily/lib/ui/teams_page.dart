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
        child: TeamsList(apiRepository: this.apiRepository),
      ),
    );
  }
}

class TeamsList extends StatefulWidget {
  final ApiRepository apiRepository;

  const TeamsList({Key key, this.apiRepository})
      : assert(apiRepository != null),
        super(key: key);

  @override
  State<TeamsList> createState() => _TeamsState();
}

class _TeamsState extends State<TeamsList> {
  List<Team> teams = new List<Team>();
  User currentUser;

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<TeamsBloc>(context).add(FetchTeams());

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
            this.currentUser = state.user;
            return Scaffold(
              body: ListView(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.only(left: 20),
                          child: Text(this.currentUser.name,
                              style: TextStyle(fontStyle: FontStyle.italic))),
                      Container(
                        alignment: Alignment.topRight,
                        child: PopupMenuButton<String>(
                          onSelected: (result) {
                            if (result == 'logout') {
                              BlocProvider.of<AuthenticationBloc>(context)
                                  .add(LoggedOut());
                            } else {
                              Scaffold.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Feature is not implemented yet'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuItem<String>>[
                            PopupMenuItem<String>(
                              value: 'profile',
                              child: Row(
                                children: <Widget>[
                                  Image.network(this.currentUser.imageUrl,
                                      width: 25),
                                  Text(this.currentUser.name)
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'logout',
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.exit_to_app),
                                  Text("Logout")
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              child: Row(
                                children: <Widget>[
                                  Text("ver: 0.4-dev",
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

          if (state is TeamsLoading) {
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
          }

          if (state is TeamCallInitializing) {
            return CallPage(
              apiRepository: this.widget.apiRepository,
              team: state.team,
            );
          }

          return Scaffold(
            body: _logoutContainer(context),
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
        onJoin(context, team);
      },
    );
  }

  // todo: cleanup,
  // @deprecated
  Future<void> onJoin(BuildContext context, Team team) async {
    // await for camera and mic permissions before pushing video page
    await _handleMic();
    BlocProvider.of<TeamsBloc>(context).add(JoinToTeamCall(team: team));
  }

  Future<void> _handleMic() async {
    await PermissionHandler().requestPermissions(
      [PermissionGroup.microphone],
    );
  }
}
