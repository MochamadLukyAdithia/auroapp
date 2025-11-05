import 'package:flutter/material.dart';
import 'package:pos_mobile/ui/owner/pages/products_categories/products/add_product.dart';
import '../../../../core/theme/theme.dart';
import '../../../widgets/custom_app_bar.dart';
import 'categories/add_category_page.dart';

class ProductCategoryPage extends StatelessWidget {
  const ProductCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2, // jumlah tab = Produk & Kategori
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Produk & Kategori',
          tabs: ['Produk', 'Kategori'],
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: EmptyProductSection(),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: EmptyCategorySection(),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyProductSection extends StatelessWidget {
  const EmptyProductSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 300),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Belum ada produk',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: primaryGreenColor,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Silahkan tambahkan produk mu, ya!',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreenColor,
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Tambah Produk',
                style: TextStyle(
                  fontFamily: 'Segoe',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddProductPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyCategorySection extends StatelessWidget {
  const EmptyCategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 300),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Belum ada kategori',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: primaryGreenColor,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Silahkan tambahkan kategori mu, ya!',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreenColor,
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Tambah Kategori',
                style: TextStyle(
                  fontFamily: 'Segoe',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddCategoryPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}