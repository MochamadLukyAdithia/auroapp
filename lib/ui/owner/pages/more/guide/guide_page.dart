import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../../../blocs/auth/login/login_bloc.dart';
import '../../../../../blocs/auth/login/login_state.dart';
import '../../../../widgets/custom_app_bar.dart';

class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Panduan Pengguna'),
      body: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          final role = state.role;


          if (state.status == LoginStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }


          if (role == null) {
            return const Center(
              child: Text('Role pengguna tidak ditemukan'),
            );
          }


          final String pdfUrl = role == 'owner'

              ? "https://drive.google.com/uc?export=download&id=1ArqEciWpUMm9OcoF0xIDPyujPwMgn79m" :
          "https://drive.google.com/uc?export=download&id=1BmRPurFOkglDCbj8CKgkAWvWlqOwspXQ";

          return SfPdfViewer.network(
            pdfUrl,


            canShowScrollHead: true,
            canShowScrollStatus: true,


            onDocumentLoaded: (details) {
              debugPrint("PDF berhasil dimuat: ${details.document.pages.count} halaman");
            },


            onDocumentLoadFailed: (details) {
              debugPrint("ERROR PDF:");
              debugPrint(details.error);
              debugPrint(details.description);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Gagal memuat PDF\n${details.description}',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            },
          );
        },
      ),
    );
  }
}