import 'package:equatable/equatable.dart';
import '../../data/models/owner_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

// Initial state
class ProfileInitial extends ProfileState {}

// Loading states
class ProfileLoading extends ProfileState {}

class ProfileUpdating extends ProfileState {}

// Success states
class ProfileLoaded extends ProfileState {
  final Owner owner;

  const ProfileLoaded(this.owner);

  @override
  List<Object?> get props => [owner];
}

class ProfileUpdated extends ProfileState {
  final Owner owner;
  final String message;

  const ProfileUpdated(this.owner, this.message);

  @override
  List<Object?> get props => [owner, message];
}

class PasswordChanged extends ProfileState {
  final String message;

  const PasswordChanged(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileError extends ProfileState {
  final String message;
  final int? code;

  const ProfileError(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

class ProfileUpdateError extends ProfileState {
  final String message;
  final int? code;

  const ProfileUpdateError(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}