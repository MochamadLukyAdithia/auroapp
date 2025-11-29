import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../blocs/onboarding/onboarding_cubit.dart';
import '../../../../blocs/onboarding/onboarding_state.dart';
import '../../../../core/theme/theme.dart';
import '../../../../data/repositories/company_repository.dart';
import '../../../../route/route.dart';
import '../../../widgets/image_picker.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingCubit(
        context.read<CompanyRepository>(),
      ),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatelessWidget {
  const _OnboardingView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state.status == OnboardingStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Setup toko berhasil!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );

          Future.delayed(const Duration(milliseconds: 500), () {
            if (context.mounted) {
              Navigator.pushReplacementNamed(context, AppRoutes.homepage);
            }
          });
        } else if (state.status == OnboardingStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Gagal menyimpan data'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );

          context.read<OnboardingCubit>().resetStatus();
        }
      },
      child: const PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    _OnboardingHeader(),
                    SizedBox(height: 40),
                    _StoreLogoSection(),
                    SizedBox(height: 32),
                    _StoreNameField(),
                    SizedBox(height: 24),
                    _StoreAddressField(),
                    SizedBox(height: 24),
                    _StorePhoneField(),
                    SizedBox(height: 40),
                    _SubmitButton(),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- Header Section ----------------
class _OnboardingHeader extends StatelessWidget {
  const _OnboardingHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: SizedBox(
            height: 80,
            width: 80,
            child: Image.asset(
              'assets/icon/auropay_logo.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Setup Toko Anda',
          style: TextStyle(
            fontFamily: fontType,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Lengkapi informasi toko Anda untuk melanjutkan',
          style: TextStyle(
            fontFamily: fontType,
            fontSize: 15,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

// ---------------- Store Logo Section ----------------
// ---------------- Store Logo Section ----------------
class _StoreLogoSection extends StatelessWidget {
  const _StoreLogoSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        return Column(
          children: [
            const Text(
              'Logo Toko',
              style: TextStyle(
                fontFamily: fontType,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ImagePickerWidget(
                imageFile: state.storeLogo,
                onImagePicked: (file) {
                  context.read<OnboardingCubit>().storeLogoChanged(file);
                },
                width: 120,
                height: 120,
                uploadText: 'Tambah Logo',
                helperText: 'Opsional',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Opsional',
              style: TextStyle(
                fontFamily: fontType,
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------- Store Name Field ----------------
class _StoreNameField extends StatelessWidget {
  const _StoreNameField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nama Toko',
              style: TextStyle(
                fontFamily: fontType,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              onChanged: (value) {
                context.read<OnboardingCubit>().storeNameChanged(value);
              },
              style: const TextStyle(
                fontFamily: fontType,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: 'Contoh: Toko Kopi Mantap',
                hintStyle: TextStyle(
                  fontFamily: fontType,
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                errorText: state.storeNameError,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: primaryGreenColor,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------- Store Address Field ----------------
class _StoreAddressField extends StatelessWidget {
  const _StoreAddressField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alamat Toko',
              style: TextStyle(
                fontFamily: fontType,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              onChanged: (value) {
                context.read<OnboardingCubit>().storeAddressChanged(value);
              },
              maxLines: 3,
              style: const TextStyle(
                fontFamily: fontType,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: 'Jl. Contoh No. 123, Kota',
                hintStyle: TextStyle(
                  fontFamily: fontType,
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                errorText: state.storeAddressError,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: primaryGreenColor,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------- Store Phone Field ----------------
class _StorePhoneField extends StatelessWidget {
  const _StorePhoneField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nomor Telepon Toko',
              style: TextStyle(
                fontFamily: fontType,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              onChanged: (value) {
                context.read<OnboardingCubit>().storePhoneChanged(value);
              },
              keyboardType: TextInputType.phone,
              style: const TextStyle(
                fontFamily: fontType,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: '081234567890',
                hintStyle: TextStyle(
                  fontFamily: fontType,
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                errorText: state!.storePhoneError,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: primaryGreenColor,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------- Submit Button ----------------
class _SubmitButton extends StatelessWidget {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        final isLoading = state.status == OnboardingStatus.loading;

        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreenColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
              textStyle: const TextStyle(
                fontFamily: fontType,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: isLoading
                ? null
                : () {
              context.read<OnboardingCubit>().submitCompany();
            },
            child: isLoading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Text('Lanjutkan'),
          ),
        );
      },
    );
  }
}