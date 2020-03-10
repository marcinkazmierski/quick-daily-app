import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';

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

class JoinChannelSuccess extends CallEvent {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'JoinChannelSuccess {}';
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
  @override
  CallState get initialState => CallNotConnected();

  @override
  Stream<CallState> mapEventToState(CallEvent event) async* {
    if (event is JoinChannelSuccess) {
      yield CallConnecting();
      try {
        //todo
      } catch (error) {
        yield CallError(error: error.toString());
      }
    }
    if (event is LeaveChannel) {
      //todo
    }
    if (event is UserJoined) {
      //todo
    }
    if (event is UserOffline) {
      //todo
    }
  }
}
