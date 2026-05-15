import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/profile_user.dart';
import '../../domain/usecases/profile_usecases.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetCurrentProfileUseCase getCurrentProfile;
  final RefreshProfileUseCase refreshProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final ChangePasswordUseCase changePasswordUseCase;
  final UpdateProfileImageUrlUseCase updateProfileImageUrlUseCase;

  ProfileCubit({
    required this.getCurrentProfile,
    required this.refreshProfileUseCase,
    required this.updateProfileUseCase,
    required this.changePasswordUseCase,
    required this.updateProfileImageUrlUseCase,
  }) : super(ProfileState.initial());

  Future<void> loadProfile() async {
    emit(state.copyWith(isLoading: true, clearMessages: true));

    try {
      final profile = await getCurrentProfile();
      if (profile == null) {
        emit(
          state.copyWith(
            isLoading: false,
            error:
                'لم يتم العثور على بيانات المستخدم. يرجى تسجيل الدخول مرة أخرى.',
          ),
        );
        return;
      }

      emit(state.copyWith(profile: profile, isLoading: false));
      await refreshProfile();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> refreshProfile() async {
    final profile = state.profile;
    if (profile == null) return;

    try {
      final refreshed = await refreshProfileUseCase(profile);
      emit(state.copyWith(profile: refreshed, clearMessages: true));
    } catch (_) {
      // Keep cached profile visible if the network refresh fails.
    }
  }

  Future<void> updateProfile({
    required String fullName,
    required String phoneNumber,
    required String address,
    required String birthDay,
  }) async {
    final profile = state.profile;
    if (profile == null) {
      emit(state.copyWith(error: 'لا توجد بيانات مستخدم محملة.'));
      return;
    }
    if (fullName.trim().isEmpty) {
      emit(state.copyWith(error: 'يرجى إدخال اسم المستخدم.'));
      return;
    }

    emit(state.copyWith(isSavingProfile: true, clearMessages: true));

    try {
      final updated = await updateProfileUseCase(
        ProfileUser(
          id: profile.id,
          fullName: fullName.trim(),
          phoneNumber: phoneNumber.trim(),
          birthDay: birthDay.trim(),
          employeDate: profile.employeDate,
          address: address.trim(),
          role: profile.role,
          isActive: profile.isActive,
          profileImageUrl: profile.profileImageUrl,
        ),
      );
      emit(
        state.copyWith(
          profile: updated,
          isSavingProfile: false,
          successMessage: 'تم تحديث بيانات الملف الشخصي بنجاح.',
        ),
      );
    } catch (e) {
      emit(state.copyWith(isSavingProfile: false, error: e.toString()));
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final profile = state.profile;
    if (profile == null) {
      emit(state.copyWith(error: 'لا توجد بيانات مستخدم محملة.'));
      return;
    }
    if (currentPassword.trim().isEmpty) {
      emit(state.copyWith(error: 'يرجى إدخال كلمة المرور الحالية.'));
      return;
    }
    if (newPassword.trim().length < 6) {
      emit(
        state.copyWith(
          error: 'كلمة المرور الجديدة يجب أن تكون 6 أحرف على الأقل.',
        ),
      );
      return;
    }
    if (newPassword != confirmPassword) {
      emit(state.copyWith(error: 'تأكيد كلمة المرور غير مطابق.'));
      return;
    }

    emit(state.copyWith(isSavingPassword: true, clearMessages: true));

    try {
      await changePasswordUseCase(
        profile: profile,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      emit(
        state.copyWith(
          isSavingPassword: false,
          successMessage: 'تم تغيير كلمة المرور بنجاح.',
        ),
      );
    } catch (e) {
      emit(state.copyWith(isSavingPassword: false, error: e.toString()));
    }
  }

  Future<void> updateProfileImageUrl(String? imageUrl) async {
    emit(state.copyWith(clearMessages: true));

    try {
      final updated = await updateProfileImageUrlUseCase(imageUrl);
      if (updated != null) {
        emit(
          state.copyWith(
            profile: updated,
            successMessage: 'تم تحديث صورة الملف الشخصي.',
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
