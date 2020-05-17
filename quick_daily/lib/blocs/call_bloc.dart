import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:quick_daily/common/exceptions/validator_exception.dart';
import 'package:quick_daily/models/team.dart';
import 'package:quick_daily/models/user.dart';
import 'package:quick_daily/repositories/api_repository.dart';

///STATES
abstract class CallState extends Equatable {
  const CallState();

  @override
  List<Object> get props => [];
}

class CallNotConnected extends CallState {}

class CallConnecting extends CallState {}

class CallConnected extends CallState {
  final Map users;
  final Team team;
  final User currentUser;

  const CallConnected({this.users, this.team, this.currentUser});

  @override
  List<Object> get props => [this.users, this.team, this.currentUser];

  @override
  String toString() => 'CallConnected {team: ' + this.team.name + '}';
}

class CallDisconnecting extends CallState {}

class CallDisconnected extends CallState {}

class CallParticipantJoined extends CallConnected {
  final Map users;
  final Team team;
  final User currentUser;

  CallParticipantJoined({this.users, this.team, this.currentUser})
      : super(users: users, team: team, currentUser: currentUser);
}

class CallParticipantLeft extends CallConnected {
  final Map users;
  final Team team;
  final User currentUser;

  CallParticipantLeft({this.users, this.team, this.currentUser})
      : super(users: users, team: team, currentUser: currentUser);
}

class CallMuteOnChanged extends CallConnected {
  final Map users;
  final Team team;
  final User currentUser;

  CallMuteOnChanged({this.users, this.team, this.currentUser})
      : super(users: users, team: team, currentUser: currentUser);
}

class CallMuteOffChanged extends CallConnected {
  final Map users;
  final Team team;
  final User currentUser;

  CallMuteOffChanged({this.users, this.team, this.currentUser})
      : super(users: users, team: team, currentUser: currentUser);
}

class AudioVolumeChanged extends CallConnected {
  final Map users;
  final Team team;
  final User currentUser;
  final int volume;

  AudioVolumeChanged({this.users, this.team, this.currentUser, this.volume})
      : super(users: users, team: team, currentUser: currentUser);
}

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
  final String userId;

  const UserJoined({this.userId});

  @override
  List<Object> get props => [this.userId];

  @override
  String toString() => 'UserJoined {$userId}';
}

class ParticipantJoined extends CallEvent {
  final String userId;

  const ParticipantJoined({this.userId});

  @override
  List<Object> get props => [this.userId];

  @override
  String toString() => 'ParticipantJoined {$userId}';
}

class ParticipantOffline extends CallEvent {
  final String userId;

  const ParticipantOffline({this.userId});

  @override
  List<Object> get props => [this.userId];

  @override
  String toString() => 'ParticipantOffline {$userId}';
}

class ToggleMute extends CallEvent {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'ToggleMute {}';
}

class OnCallError extends CallEvent {
  final String error;

  const OnCallError({this.error});

  @override
  List<Object> get props => [this.error];

  @override
  String toString() => 'OnCallError {}';
}

class AudioVolumeIndication extends CallEvent {
  final List<AudioVolumeInfo> speakers;

  const AudioVolumeIndication({this.speakers});

  @override
  List<Object> get props => [this.speakers];

  @override
  String toString() => 'AudioVolumeIndication {}';
}

/// BLOC
class CallBloc extends Bloc<CallEvent, CallState> {
  final ApiRepository apiRepository;

  CallBloc({this.apiRepository}) : assert(apiRepository != null);

  Map users = LinkedHashMap<String, User>();

  Team team;
  User currentUser;

  int volume = 0;

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
        this.team = event.team;
        await AgoraRtcEngine.create(event.team.externalAppId);
        await AgoraRtcEngine.enableAudio();
        await AgoraRtcEngine.disableVideo(); // without video

        await AgoraRtcEngine.enableWebSdkInteroperability(true);
        await AgoraRtcEngine.joinChannel(null, event.team.name, null, 0);
        await AgoraRtcEngine.enableAudioVolumeIndication(200, 3, false);

        _addAgoraEventHandlers();
      } catch (error) {
        yield CallError(error: error.toString());
      }
    }

    if (event is UserJoined) {
      try {
        await apiRepository.initCall(this.team, event.userId);
        this.currentUser = await apiRepository.getUserByUid(event.userId);
        this.users = await apiRepository.getUsersByTeam(this.team);
        this.users[this.currentUser.id.toString()].state =
            "current: " + this.currentUser.externalId;

        yield CallConnected(
            users: this.users, team: this.team, currentUser: this.currentUser);
      } catch (error) {
        yield CallError(error: error.toString());
      }
    }

    if (event is UserLeftChannel) {
      try {
        yield CallDisconnecting();
        // clear users
        this.users.clear();
        // destroy sdk
        AgoraRtcEngine.leaveChannel();
        AgoraRtcEngine.destroy();
        yield CallDisconnected();
      } catch (error) {
        yield CallError(error: error.toString());
      }
    }

    if (event is ParticipantJoined) {
      try {
        final User user = await apiRepository.getUserByUid(event.userId);
        this.users[user.id.toString()].state = "active";
        yield CallParticipantJoined(
            users: this.users, team: this.team, currentUser: this.currentUser);
      } catch (error) {
        yield CallError(error: error.toString());
      }
    }

    if (event is ParticipantOffline) {
      try {
        final User user = await apiRepository.getUserByUid(event.userId);
        // this.users.removeWhere((key, value) => key == user.id.toString());
        this.users[user.id.toString()].state = "inactive";
        yield CallParticipantLeft(
            users: this.users, team: this.team, currentUser: this.currentUser);
      } catch (error) {
        yield CallError(error: error.toString());
      }
    }

    if (event is ToggleMute) {
      this.currentUser.muted = !this.currentUser.muted;
      AgoraRtcEngine.muteLocalAudioStream(this.currentUser.muted);
      if (this.currentUser.muted) {
        yield CallMuteOnChanged(
            users: this.users, team: this.team, currentUser: this.currentUser);
      } else {
        yield CallMuteOffChanged(
            users: this.users, team: this.team, currentUser: this.currentUser);
      }
    }

    if (event is AudioVolumeIndication) {
      bool updated = false;
      int volume = 0;
      this.users.forEach((key, user) {
        user.speakingVolume = 0;
      });

      for (var i = 0; i < event.speakers.length; i++) {
        AudioVolumeInfo info = event.speakers[i];
        String externalUserId = info.uid.toString();

        this.users.forEach((key, user) {
          if (externalUserId == user.externalId) {
            updated = true;
            user.speakingVolume = info.volume;
            volume += user.speakingVolume;
            print("userId: " +
                info.uid.toString() +
                ", volume: " +
                info.volume.toString());
          }
        });
      }

      if (updated || volume == 0 && this.volume > 0) {
        print("UPDATED!!!!! " + volume.toString());
        yield AudioVolumeChanged(
            users: this.users,
            team: this.team,
            currentUser: this.currentUser,
            volume: volume);
        this.volume = volume;
      }

      yield CallConnected(
          users: this.users, team: this.team, currentUser: this.currentUser);
    }
    if (event is OnCallError) {
      yield CallError(error: event.error);
    }
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    AgoraRtcEngine.onError = (dynamic code) {
      final info = 'AgoraRtcEngine: onError: $code';
      print(info);
      // destroy sdk
      AgoraRtcEngine.leaveChannel();
      AgoraRtcEngine.destroy();
      this.add(OnCallError(error: info));
    };

    AgoraRtcEngine.onJoinChannelSuccess = (
      String channel,
      int uid,
      int elapsed,
    ) {
      //todo: get team by channel name!
      this.add(UserJoined(userId: uid.toString()));
    };

    AgoraRtcEngine.onLeaveChannel = () {
      this.add(UserLeftChannel());
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      this.add(ParticipantJoined(userId: uid.toString()));
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      this.add(ParticipantOffline(userId: uid.toString()));
    };

    AgoraRtcEngine.onAudioVolumeIndication =
        (int totalVolume, List<AudioVolumeInfo> speakers) {
      if (speakers.length > 0 || this.volume > 0) {
        /// Total volume after audio mixing. The value ranges between 0 (lowest volume) and 255 (highest volume).
        this.add(AudioVolumeIndication(speakers: speakers));
      }
    };
  }
}
