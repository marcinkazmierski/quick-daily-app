import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:quick_daily/blocs/call_bloc.dart';
import 'package:quick_daily/models/team.dart';
import 'package:quick_daily/models/user.dart';
import 'package:quick_daily/repositories/api_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_daily/ui/teams_page.dart';

class CallPage extends StatelessWidget {
  final Team team;
  final ApiRepository apiRepository;

  const CallPage({Key key, this.team, this.apiRepository})
      : assert(apiRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    CallBloc callBloc = CallBloc(apiRepository: this.apiRepository);

    return Scaffold(
      body: BlocProvider(
        create: (context) {
          return callBloc;
        },
        child: CallView(team: this.team, apiRepository: this.apiRepository),
      ),
    );
  }
}

class CallView extends StatefulWidget {
  final Team team;
  final ApiRepository apiRepository;

  const CallView({Key key, this.team, this.apiRepository})
      : assert(apiRepository != null),
        super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallView> {
  Map users = LinkedHashMap<String, User>();

  User currentUser;

  /// Video layout wrapper
  Widget _viewRows() {
    if (users.isEmpty) {
      return Container(
        padding: const EdgeInsets.only(bottom: 130),
        child: Center(
          child: Text(
            "Jeszcze nikt nie dołączył do tej konwersacji... 😢",
            // todo: translation
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.only(bottom: 130),
      child: Container(
        color: Colors.white,
        child: ListView.builder(
          itemCount: users.length,
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemBuilder: _buildItemsForListView,
        ),
      ),
    );
  }

  Widget _buildItemsForListView(BuildContext context, int index) {
    User user = users.values.toList()[index];

    Color micColor = Colors.grey;
    if (user.speakingVolume > 0 && user.speakingVolume < 200) {
      micColor = Colors.blue;
    } else if (user.speakingVolume >= 200) {
      micColor = Colors.red;
    }
    print("user.ext: " + user.externalId);
    print("user.speakingVolume: " + user.speakingVolume.toString());

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(user.imageUrl),
      ),
      title: Text(user.name),
      subtitle: Text(user.state == "active"
          ? "External ID: " + user.externalId
          : user.state),
      trailing: Icon(Icons.mic, color: micColor),
    );
  }

  /// Toolbar layout
  Widget _toolbar(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: () {
              BlocProvider.of<CallBloc>(context).add(ToggleMute());
            },
            child: Icon(
              this.currentUser.muted ? Icons.mic : Icons.mic_off,
              color: this.currentUser.muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor:
                this.currentUser.muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () {
              BlocProvider.of<CallBloc>(context).add(UserLeftChannel());
            },
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<CallBloc>(context).add(InitialCall(team: this.widget.team));

    return BlocListener<CallBloc, CallState>(
      listener: (context, state) {
        if (state is CallError) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<CallBloc, CallState>(
        builder: (context, state) {
          if (state is CallConnected) {
            this.users = state.users;
            this.currentUser = state.currentUser;
            return Scaffold(
              // backgroundColor: Colors.black,
              body: Center(
                child: Stack(
                  children: <Widget>[
                    _viewRows(),
                    _toolbar(context),
                  ],
                ),
              ),
            );
          }

          if (state is CallDisconnected) {
            return TeamsPage(apiRepository: this.widget.apiRepository);
          }

          return Scaffold(); //empty
        },
      ),
    );
  }
}
