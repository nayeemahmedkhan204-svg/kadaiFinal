import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/category_model.dart';
import '../providers/product_provider.dart';

class ProductCategoriesScreen extends StatefulWidget {
  const ProductCategoriesScreen({super.key});

  @override
  State<ProductCategoriesScreen> createState() => _ProductCategoriesScreenState();
}

class _ProductCategoriesScreenState extends State<ProductCategoriesScreen> {
  final ApiClient _api = ApiClient();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchCategories();
    });
  }

  void _showAddCategoryDialog([CategoryModel? category]) {
    final nameCtrl = TextEditingController(text: category?.name ?? '');
    final descCtrl = TextEditingController(text: category?.description ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(category == null ? 'Add Category / வகை சேர்க்க' : 'Edit Category / வகை திருத்து'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Category Name * / பெயர்', prefixIcon: Icon(Icons.category)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description / விவரம்', prefixIcon: Icon(Icons.notes)),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;

                Navigator.pop(ctx);
                setState(() => _isLoading = true);

                if (category == null) {
                  await _api.post(ApiEndpoints.categories, {
                    'name': name,
                    'description': descCtrl.text.trim(),
                  });
                } else {
                  await _api.put('${ApiEndpoints.categories}/${category.id}', {
                    'name': name,
                    'description': descCtrl.text.trim(),
                  });
                }

                if (mounted) {
                  await Provider.of<ProductProvider>(context, listen: false).fetchCategories();
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Category saved successfully!'), backgroundColor: AppColors.success),
                  );
                }
              },
              child: const Text('Save / சேமி'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final prodProv = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Categories / வகைகள்'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => prodProv.fetchCategories(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategoryDialog(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Category', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : prodProv.categories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.category_outlined, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text('No categories found', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _showAddCategoryDialog(),
                        child: const Text('Create First Category'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: prodProv.categories.length,
                  itemBuilder: (context, index) {
                    final cat = prodProv.categories[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                          child: Text(
                            cat.name.isNotEmpty ? cat.name[0].toUpperCase() : 'C',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                        title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: cat.description != null && cat.description!.isNotEmpty
                            ? Text(cat.description!)
                            : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.grey),
                          onPressed: () => _showAddCategoryDialog(cat),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
