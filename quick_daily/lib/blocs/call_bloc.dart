import 'dart:async';

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

class LeaveChannel extends CallEvent {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'LeaveChannel {}';
}

class UserJoined extends CallEvent {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'UserJoined {}';
}

class UserOffline extends CallEvent {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'UserOffline {}';
}

/// BLOC
class CallBloc extends Bloc<CallEvent, CallState> {
  final Team team;

  CallBloc({this.team});

  @override
  CallState get initialState => CallNotConnected();

  @override
  Stream<CallState> mapEventToState(CallEvent event) async* {
    if (event is InitialCall) {
      try {
        if (this.team.externalAppId.isEmpty) {
          throw new ValidatorException("Team externalAppId is empty!");
        }

        yield CallConnecting();
        //todo
        yield CallConnected();
      } catch (error) {
        yield CallError(error: error.toString());
      }
    }

    if (event is LeaveChannel) {
      try {
        yield CallDisconnecting();
        //todo
        yield CallDisconnected();
      } catch (error) {
        yield CallError(error: error.toString());
      }
    }

    if (event is UserJoined) {
      yield CallParticipantJoined();
    }

    if (event is UserOffline) {
      yield CallParticipantLeft();
    }
  }
}
