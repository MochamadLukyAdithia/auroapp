// company_state.dart
part of 'company_cubit.dart';

abstract class CompanyState extends Equatable {
  const CompanyState();

  @override
  List<Object?> get props => [];
}

class CompanyInitial extends CompanyState {}

class CompanyLoading extends CompanyState {}

class CompanyEmpty extends CompanyState {} // User belum setup company

class CompanyLoaded extends CompanyState {
  final Company company;

  const CompanyLoaded(this.company);

  @override
  List<Object?> get props => [company];
}

class CompanySaved extends CompanyState {
  final Company company;

  const CompanySaved(this.company);

  @override
  List<Object?> get props => [company];
}

class CompanyError extends CompanyState {
  final String message;

  const CompanyError(this.message);

  @override
  List<Object?> get props => [message];
}