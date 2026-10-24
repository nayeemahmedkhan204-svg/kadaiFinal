import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/expense_model.dart';
import '../providers/expense_provider.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<ExpenseProvider>(context, listen: false);
      prov.fetchCategories();
      prov.fetchExpenses();
    });
  }

  void _onCategorySelected(String? cat) {
    setState(() => _selectedCategory = cat);
    Provider.of<ExpenseProvider>(context, listen: false).fetchExpenses(category: cat);
  }

  void _showAddExpenseModal() {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    String category = 'Miscellaneous';
    String mode = 'cash';

    final expProv = Provider.of<ExpenseProvider>(context, listen: false);
    final categories = expProv.categories.isNotEmpty
        ? expProv.categories
        : ['Rent', 'Electricity', 'Salary', 'Transport', 'Packaging', 'Tea & Snacks', 'Miscellaneous'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Record Expense / செலவு பதிவு',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    const SizedBox(height: 14),
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: 'Expense Title * (e.g. Shop Rent)', prefixIcon: Icon(Icons.description)),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: amountCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Amount ₹ *', prefixIcon: Icon(Icons.currency_rupee)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: category,
                            decoration: const InputDecoration(labelText: 'Category / வகை'),
                            items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                            onChanged: (val) => setModalState(() => category = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: mode,
                      decoration: const InputDecoration(labelText: 'Payment Mode / முறை', prefixIcon: Icon(Icons.payment)),
                      items: const [
                        DropdownMenuItem(value: 'cash', child: Text('Cash / ரொக்கம்')),
                        DropdownMenuItem(value: 'upi', child: Text('UPI (GPay / PhonePe)')),
                        DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer / NEFT')),
                      ],
                      onChanged: (val) => setModalState(() => mode = val!),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: noteCtrl,
                      decoration: const InputDecoration(labelText: 'Notes / குறிப்பு (Optional)', prefixIcon: Icon(Icons.note_alt)),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final title = titleCtrl.text.trim();
                        final amount = double.tryParse(amountCtrl.text) ?? 0.0;
                        if (title.isEmpty || amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter valid title and amount.')),
                          );
                          return;
                        }

                        final data = {
                          'title': title,
                          'amount': amount,
                          'category': category,
                          'payment_method': mode,
                          'expense_date': DateTime.now().toIso8601String().substring(0, 10),
                          'description': noteCtrl.text.trim().isNotEmpty ? noteCtrl.text.trim() : null,
                        };

                        final ok = await expProv.addExpense(data);
                        if (context.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(ok ? 'Expense recorded successfully!' : 'Failed to record expense.'),
                              backgroundColor: ok ? AppColors.success : AppColors.error,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: const Text('Save Expense / சேமி',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final expProv = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses / செலவுகள்'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => expProv.fetchExpenses(category: _selectedCategory)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddExpenseModal,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Expense', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Total Expenses Header Card
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade700, Colors.purple.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Shop Expenses / மொத்த செலவுகள்',
                        style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      '₹${expProv.totalExpenses.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 36),
              ],
            ),
          ),

          // Categories Filter Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All Categories'),
                  selected: _selectedCategory == null,
                  onSelected: (sel) {
                    if (sel) _onCategorySelected(null);
                  },
                ),
                const SizedBox(width: 8),
                ...expProv.categories.map((c) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(c),
                        selected: _selectedCategory == c,
                        onSelected: (sel) => _onCategorySelected(sel ? c : null),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Expenses List
          Expanded(
            child: expProv.isLoading
                ? const Center(child: CircularProgressIndicator())
                : expProv.expenses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.money_off, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            const Text('No expenses recorded', style: TextStyle(fontSize: 16, color: Colors.grey)),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _showAddExpenseModal,
                              child: const Text('Record First Expense'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: expProv.expenses.length,
                        itemBuilder: (context, index) {
                          final exp = expProv.expenses[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.purple.shade50,
                                child: const Icon(Icons.receipt_long, color: Colors.purple),
                              ),
                              title: Text(exp.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              subtitle: Row(
                                children: [
                                  Text(exp.category, style: TextStyle(color: Colors.purple.shade700, fontWeight: FontWeight.w600, fontSize: 12)),
                                  const SizedBox(width: 8),
                                  Text(exp.expenseDate, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                                  const SizedBox(width: 8),
                                  Text(exp.paymentMethod.toUpperCase(), style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
                                ],
                              ),
                              trailing: Text(
                                '₹${exp.amount.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.purple),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
