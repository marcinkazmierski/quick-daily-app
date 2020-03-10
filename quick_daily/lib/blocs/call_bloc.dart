import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
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

class JoinChannelSuccess extends CallEvent{
  @override
  List<Object> get props => [];

  @override
  String toString() => 'JoinChannelSuccess {}';
}

/// BLOC
