import 'dart:async';
import 'dart:collection';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:quick_daily/models/team.dart';
import 'package:quick_daily/models/user.dart';
import 'package:quick_daily/repositories/api_repository.dart';

class CallPage extends StatefulWidget {
  /// non-modifiable channel name of the page
  final Team team;

  /// Creates a call page with given channel name.
  const CallPage({Key key, this.team}) : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  Map users = LinkedHashMap<String, User>();

  bool muted = false;

  @override
  void dispose() {
    // clear users
    users.clear();
    // destroy sdk
    AgoraRtcEngine.leaveChannel();
    AgoraRtcEngine.destroy();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    initialize();
  }

  Future<void> initialize() async {
    if (widget.team.externalAppId.isEmpty) {
      Future.delayed(Duration.zero, () {
        this.showInSnackBar("Agora Engine is not starting - APP_ID missing.");
      });
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await AgoraRtcEngine.enableWebSdkInteroperability(true);
    await AgoraRtcEngine.joinChannel(null, widget.team.name, null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    await AgoraRtcEngine.create(widget.team.externalAppId);
    await AgoraRtcEngine.enableAudio();
    await AgoraRtcEngine.disableVideo(); // without video
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    AgoraRtcEngine.onError = (dynamic code) {
      setState(() {
        final info = 'onError: $code';
        this.showInSnackBar(info);
      });
    };

    AgoraRtcEngine.onJoinChannelSuccess = (
      String channel,
      int uid,
      int elapsed,
    ) {
      setState(() {
        final info = 'onJoinChannel: $channel, my uid: $uid';
        this.showInSnackBar(info);
      });
    };

    AgoraRtcEngine.onLeaveChannel = () {
      setState(() {
        this.showInSnackBar('onLeaveChannel');
        users.clear();
      });
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      setState(() {
        final info = 'userJoined: $uid';
        this.showInSnackBar(info);

        ApiRepository().getUserByUid(uid.toString()).then((u) {
          setState(() {
            users.putIfAbsent(uid.toString(), () => u);
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
      });
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      setState(() {
        final info = 'userOffline: $uid';
        this.showInSnackBar(info);
        users.removeWhere((key, value) => key == uid.toString());
      });
    };

    AgoraRtcEngine.onFirstRemoteVideoFrame = (
      int uid,
      int width,
      int height,
      int elapsed,
    ) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        this.showInSnackBar(info);
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

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(user.imageUrl),
      ),
      title: Text(user.name),
      subtitle: Text(user.externalId),
      trailing: Icon(Icons.mic),
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
    Navigator.pop(context);
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    AgoraRtcEngine.muteLocalAudioStream(muted);
  }

  @override
  Widget build(BuildContext context) {
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

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }
}
