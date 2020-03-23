import 'dart:async';
import 'dart:collection';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
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

  bool muted = false;

//  @override
//  void initState() {
//    super.initState();
//    // initialize agora sdk
//    // _addAgoraEventHandlers();
//  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    AgoraRtcEngine.onError = (dynamic code) {
      final info = 'onError: $code';
      this.showInSnackBar(info);
    };

    AgoraRtcEngine.onJoinChannelSuccess = (
      String channel,
      int uid,
      int elapsed,
    ) {
      final info = 'onJoinChannel: $channel, my uid: $uid';
      this.showInSnackBar(info);
      setState(() {
        ApiRepository().initCall(widget.team, uid.toString()).then((u) {
          ///
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
      });
    };

    AgoraRtcEngine.onLeaveChannel = () {
      this.showInSnackBar('onLeaveChannel');
      setState(() {
        users.clear();
      });
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      setState(() {
        ApiRepository().getUserByUid(uid.toString()).then((u) {
          setState(() {
            users.putIfAbsent(uid.toString(), () => u);
          });

          final info = 'userJoined: ' + u.name;
          this.showInSnackBar(info);
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
      });
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      User user = users[uid.toString()];
      final info = 'userOffline: ' + user.name;
      this.showInSnackBar(info);
      setState(() {
        users.removeWhere((key, value) => key == uid.toString());
      });
    };

    AgoraRtcEngine.onAudioVolumeIndication =
        (int totalVolume, List<AudioVolumeInfo> speakers) {
      /// Total volume after audio mixing. The value ranges between 0 (lowest volume) and 255 (highest volume).
      setState(() {
        users.forEach((key, user) {
          user.speakingVolume = 0;
        });

        for (var i = 0; i < speakers.length; i++) {
          AudioVolumeInfo info = speakers[i];

          if (users.containsKey(info.uid.toString())) {
            User user = users[info.uid.toString()];
            user.speakingVolume = info.volume;
            users[info.uid.toString()] = user;
          }
        }
      });
    };
  }

  /// Video layout wrapper
  Widget _viewRows() {
    if (users.isEmpty) {
      return Container(
        padding: const EdgeInsets.only(bottom: 130),
        child: Center(
          child: Text(
            "Jeszcze nikt nie dołączył do tej konwersacji... 😢",
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
    if (user.speakingVolume > 0 && user.speakingVolume < 100) {
      micColor = Colors.blue;
    } else if (user.speakingVolume >= 100) {
      micColor = Colors.red;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(user.imageUrl),
      ),
      title: Text(user.name),
      subtitle: Text("External ID: " + user.externalId),
      trailing: Icon(Icons.mic, color: micColor),
    );
  }

  /// Toolbar layout
  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic : Icons.mic_off,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
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

  void _onCallEnd(BuildContext context) {
    BlocProvider.of<CallBloc>(context).add(UserLeftChannel());
  }

  void _onToggleMute() {
    BlocProvider.of<CallBloc>(context).add(ToggleMute());
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
            this.muted = state.muted;
            return Scaffold(
              key: _scaffoldKey,
              // backgroundColor: Colors.black,
              body: Center(
                child: Stack(
                  children: <Widget>[
                    _viewRows(),
                    _toolbar(),
                  ],
                ),
              ),
            );
          }

          if (state is CallDisconnected) {
            return TeamsPage(apiRepository: this.widget.apiRepository);
          }

          return Scaffold(key: _scaffoldKey); //empty
        },
      ),
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }
}
