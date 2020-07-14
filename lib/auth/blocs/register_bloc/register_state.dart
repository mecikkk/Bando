part of 'register_bloc.dart';


@immutable
class RegisterState {
  final bool isEmailValid;
  final bool isPasswordValid;
  final bool isUsernameValid;
  final bool isGroupNameValid;
  final bool isRegistrationSubmitting;
  final bool isRegistrationSuccess;
  final bool isJoiningToExistingGroup;
  final bool isNewGroupCreating;
  final bool isGroupSubmitting;
  final bool isGroupConfigurationSuccess;
  final bool isFailure;
  String groupId;

  bool get isFormValid => isEmailValid && isPasswordValid && isUsernameValid;

  RegisterState({
    @required this.isEmailValid,
    @required this.isPasswordValid,
    @required this.isUsernameValid,
    @required this.isGroupNameValid,
    @required this.isRegistrationSubmitting,
    @required this.isRegistrationSuccess,
    @required this.isGroupSubmitting,
    @required this.isNewGroupCreating,
    @required this.isJoiningToExistingGroup,
    @required this.isGroupConfigurationSuccess,
    @required this.isFailure,
    this.groupId
  });

  factory RegisterState.initial() {
    return RegisterState(
      isEmailValid: true,
      isPasswordValid: true,
      isUsernameValid: true,
      isGroupNameValid: true,
      isRegistrationSubmitting: false,
      isRegistrationSuccess: false,
      isGroupSubmitting: false,
      isJoiningToExistingGroup: false,
      isNewGroupCreating: false,
      isGroupConfigurationSuccess: false,
      isFailure: false,
    );
  }

  factory RegisterState.registrationSubmitting() {
    return RegisterState(
      isEmailValid: true,
      isPasswordValid: true,
      isUsernameValid: true,
      isGroupNameValid: true,
      isRegistrationSubmitting: true,
      isRegistrationSuccess: false,
      isGroupSubmitting: false,
      isJoiningToExistingGroup: false,
      isGroupConfigurationSuccess: false,
      isNewGroupCreating: false,
      isFailure: false,
    );
  }

  factory RegisterState.failure() {
    return RegisterState(
      isEmailValid: true,
      isPasswordValid: true,
      isUsernameValid: true,
      isGroupNameValid: true,
      isRegistrationSubmitting: false,
      isRegistrationSuccess: false,
      isGroupSubmitting: false,
      isJoiningToExistingGroup: false,
      isNewGroupCreating: false,
      isGroupConfigurationSuccess: false,
      isFailure: true,
    );
  }

  factory RegisterState.registered() {
    return RegisterState(
      isEmailValid: true,
      isPasswordValid: true,
      isUsernameValid: true,
      isGroupNameValid: true,
      isRegistrationSubmitting: false,
      isRegistrationSuccess: true,
      isGroupSubmitting: false,
      isJoiningToExistingGroup: false,
      isNewGroupCreating: false,
      isGroupConfigurationSuccess: false,
      isFailure: false,
    );
  }

  factory RegisterState.joiningToExistingGroup() {
    return RegisterState(
      isEmailValid: true,
      isPasswordValid: true,
      isUsernameValid: true,
      isGroupNameValid: true,
      isRegistrationSubmitting: false,
      isRegistrationSuccess: true,
      isGroupSubmitting: false,
      isJoiningToExistingGroup: true,
      isNewGroupCreating: false,
      isGroupConfigurationSuccess: false,
      isFailure: false,
    );
  }

  factory RegisterState.newGroupCreating() {
    return RegisterState(
      isEmailValid: true,
      isPasswordValid: true,
      isUsernameValid: true,
      isGroupNameValid: true,
      isRegistrationSubmitting: false,
      isRegistrationSuccess: true,
      isGroupSubmitting: false,
      isJoiningToExistingGroup: false,
      isNewGroupCreating: true,
      isGroupConfigurationSuccess: false,
      isFailure: false,
    );
  }

  factory RegisterState.joinToGroupSubmitting() {
    return RegisterState(
      isEmailValid: true,
      isPasswordValid: true,
      isUsernameValid: true,
      isGroupNameValid: true,
      isRegistrationSubmitting: false,
      isRegistrationSuccess: true,
      isGroupSubmitting: true,
      isJoiningToExistingGroup: true,
      isNewGroupCreating: false,
      isGroupConfigurationSuccess: false,
      isFailure: false,
    );
  }

  factory RegisterState.newGroupSubmitting() {
    return RegisterState(
      isEmailValid: true,
      isPasswordValid: true,
      isUsernameValid: true,
      isGroupNameValid: true,
      isRegistrationSubmitting: false,
      isRegistrationSuccess: true,
      isGroupSubmitting: true,
      isJoiningToExistingGroup: false,
      isNewGroupCreating: true,
      isGroupConfigurationSuccess: false,
      isFailure: false,
    );
  }

  factory RegisterState.newGroupConfigured(String groupId) {
    return RegisterState(
      isEmailValid: true,
      isPasswordValid: true,
      isUsernameValid: true,
      isGroupNameValid: true,
      isRegistrationSubmitting: false,
      isRegistrationSuccess: false,
      isGroupSubmitting: false,
      isNewGroupCreating: true,
      isJoiningToExistingGroup: false,
      isGroupConfigurationSuccess: true,
      isFailure: false,
      groupId : groupId,
    );
  }
  factory RegisterState.joiningToGroupConfigured() {
    return RegisterState(
      isEmailValid: true,
      isPasswordValid: true,
      isUsernameValid: true,
      isGroupNameValid: true,
      isRegistrationSubmitting: false,
      isRegistrationSuccess: false,
      isGroupSubmitting: false,
      isNewGroupCreating: false,
      isJoiningToExistingGroup: true,
      isGroupConfigurationSuccess: true,
      isFailure: false,
    );
  }


  RegisterState update({
    bool isEmailValid,
    bool isPasswordValid,
    bool isUsernameValid,
    bool isGroupNameValid
  }) {
    return copyWith(
      isEmailValid: isEmailValid,
      isPasswordValid: isPasswordValid,
      isUsernameValid: isUsernameValid,
      isGroupNameValid: isGroupNameValid,
      isSubmitEnabled : false,
      isRegistrationSubmitting : false,
      isRegistrationSuccess : false,
      isConfigurationSubmitting : false,
      isGroupSubmitting: false,
      isFailure: false,
    );
  }

  RegisterState copyWith({
    bool isEmailValid,
    bool isPasswordValid,
    bool isUsernameValid,
    bool isGroupNameValid,
    bool isSubmitEnabled,
    bool isRegistrationSubmitting,
    bool isRegistrationSuccess,
    bool isConfigurationSubmitting,
    bool isJoinedToExistingGroup,
    bool isNewGroupCreating,
    bool isGroupSubmitting,
    bool isFailure,
  }) {
    return RegisterState(
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      isUsernameValid: isUsernameValid ?? this.isUsernameValid,
      isGroupNameValid: isGroupNameValid ?? this.isUsernameValid,
      isRegistrationSubmitting: isRegistrationSubmitting ?? this.isRegistrationSubmitting,
      isRegistrationSuccess: isRegistrationSuccess ?? this.isRegistrationSuccess,
      isGroupConfigurationSuccess: isGroupConfigurationSuccess ?? this.isGroupConfigurationSuccess,
      isJoiningToExistingGroup: isJoinedToExistingGroup ?? this.isJoiningToExistingGroup,
      isNewGroupCreating: isNewGroupCreating ?? this.isNewGroupCreating,
      isGroupSubmitting: isGroupSubmitting ?? this.isGroupSubmitting,
      isFailure: isFailure ?? this.isFailure,
    );
  }

}
