import 'package:chat_app/utils/authentication_repository.dart';
import 'package:equatable/equatable.dart';

class AuthenticationEvent extends Equatable{
  @override
  List<Object?> get props => [];
}

class AuthenticationStatusChanged extends AuthenticationEvent{
   AuthenticationStatusChanged(this.status);


  final AuthenticationStatus status;

  @override
  List<Object?> get props => [status];
}

class AuthenticationLogoutRequested extends AuthenticationEvent {}