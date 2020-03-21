import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:quick_daily/common/exceptions/validator_exception.dart';
import 'package:quick_daily/models/team.dart';

///STATES
abstract class CallState extends Equatable {
  const CallState();

  @override
  List<Object> get props => [];
}

class CallNotConnected extends CallState {}

class CallConnecting extends CallState {}

class CallConnected extends CallState {}

class CallDisconnecting extends CallState {}

class CallDisconnected extends CallState {}

class CallParticipantJoined extends CallState {}

class CallParticipantLeft extends CallState {}

class CallError extends CallState {
  final String error;

  const CallError({this.error});

  @override
  List<Object> get props => [error];

  @override
  String toString() => 'CallError { error: $error }';
}

/// EVENTS
abstract class CallEvent extends Equatable {
  const CallEvent();
}

class InitialCall extends CallEvent {
  final Team team;

  const InitialCall({this.team});

  @override
  List<Object> get props => [this.team];

  @override
  String toString() => 'InitialCall {team: ' + this.team.name + '}';
}

class UserLeftChannel extends CallEvent {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'UserLeftChannel {}';
}

class UserJoined extends CallEvent {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'UserJoined {}';
}

class ParticipantJoined extends CallEvent {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'ParticipantJoined {}';
}

class ParticipantOffline extends CallEvent {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'ParticipantOffline {}';
}

class OnCallError extends CallEvent {
  final String error;

  const OnCallError({this.error});

  @override
  List<Object> get props => [];

  @override
  String toString() => 'OnCallError {}';
}

/// BLOC
class CallBloc extends Bloc<CallEvent, CallState> {
  @override
  CallState get initialState => CallNotConnected();

  @override
  Stream<CallState> mapEventToState(CallEvent event) async* {
    if (event is InitialCall) {
      yield CallConnecting();

      try {
        if (event.team.externalAppId.isEmpty) {
          throw new ValidatorException("Team externalAppId is empty!");
        }

        await AgoraRtcEngine.create(event.team.externalAppId);
        await AgoraRtcEngine.enableAudio();
        await AgoraRtcEngine.disableVideo(); // without video

        await AgoraRtcEngine.enableWebSdkInteroperability(true);
        await AgoraRtcEngine.joinChannel(null, event.team.name, null, 0);
        await AgoraRtcEngine.enableAudioVolumeIndication(200, 3, false);

        _addAgoraEventHandlers();

        //todo
      } catch (error) {
        yield CallError(error: error.toString());
      }
    }

    if (event is UserJoined) {
      try {
        //todo
        yield CallConnected();
      } catch (error) {
        yield CallError(error: error.toString());
      }
    }

    if (event is UserLeftChannel) {
      try {
        yield CallDisconnecting();
        //todo
        yield CallDisconnected();
      } catch (error) {
        yield CallError(error: error.toString());
      }
    }

    if (event is ParticipantJoined) {
      yield CallParticipantJoined();
    }

    if (event is ParticipantOffline) {
      yield CallParticipantLeft();
    }

    if (event is OnCallError) {
      yield CallError(error: event.error);
    }
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    AgoraRtcEngine.onError = (dynamic code) {
      final info = 'BLoC: onError: $code';
      print(info);
      this.add(OnCallError(error: info));
    };

    AgoraRtcEngine.onJoinChannelSuccess = (
      String channel,
      int uid,
      int elapsed,
    ) {
      final info = 'BLoC: onJoinChannel: $channel, my uid: $uid';
      print(info);
      this.add(UserJoined());
      // todo: logic
    };

    AgoraRtcEngine.onLeaveChannel = () {
      final info = 'BLoC: onLeaveChannel';
      print(info);
      this.add(UserLeftChannel());
      // todo: logic
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      final info = 'BLoC: userJoined: ' + uid.toString();
      print(info);
      this.add(ParticipantJoined());
      // todo: logic
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      final info = 'BLoC: onUserOffline: ' + uid.toString();
      print(info);
      this.add(ParticipantOffline());
      // todo: logic
    };

    AgoraRtcEngine.onAudioVolumeIndication =
        (int totalVolume, List<AudioVolumeInfo> speakers) {
      final info =
          'BLoC: onAudioVolumeIndication: speakers: ' + speakers.toString();
      print(info);
      // todo: logic
    };
  }
}
