import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/app_data_manager.dart';
import '../models/order_model.dart';
import '../models/book_model.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int _selectedTab = 0;
  final dataManager = AppDataManager();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _genreController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _coverImageUrlController = TextEditingController();
  Book? _editingBook;

  @override
  void initState() {
    super.initState();
    // Refresh orders when admin panel opens
    _refreshOrders();
  }

  Future<void> _refreshOrders() async {
    await dataManager.loadHeavyData();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _genreController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _coverImageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (dataManager.currentUser == null || !dataManager.currentUser!.isAdmin) {
      return Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: const Center(
          child: Text(
            'Access Denied',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Admin Panel',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildTabButton('Books', 0),
                const SizedBox(width: 8),
                _buildTabButton('Users', 1),
                const SizedBox(width: 8),
                _buildTabButton('Orders', 2),
              ],
            ),
          ),
          Expanded(
            child: _selectedTab == 0
                ? _buildBooksTab()
                : _selectedTab == 1
                ? _buildUsersTab()
                : _buildOrdersTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: ElevatedButton(
        onPressed: () => setState(() => _selectedTab = index),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? AppColors.indigoPrimary
              : AppColors.darkCard,
          foregroundColor: isSelected ? Colors.white : AppColors.textSecondary,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildBooksTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => _showAddBookDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add New Book'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.indigoPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dataManager.allBooks.length,
            itemBuilder: (context, index) {
              final book = dataManager.allBooks[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.darkCard.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        book.coverImageUrl,
                        width: 60,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 60,
                          height: 80,
                          color: AppColors.darkSurface,
                          child: const Icon(Icons.book, size: 30),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            book.author,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          Text(
                            '\$${book.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppColors.purpleAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: AppColors.indigoPrimary,
                      ),
                      onPressed: () {
                        _editingBook = book;
                        _titleController.text = book.title;
                        _authorController.text = book.author;
                        _genreController.text = book.genre;
                        _priceController.text = book.price.toString();
                        _descriptionController.text = book.description;
                        _coverImageUrlController.text = book.coverImageUrl;
                        _showAddBookDialog(isEditing: true);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppColors.darkCard,
                            title: const Text(
                              'Delete Book',
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                            content: Text(
                              'Are you sure you want to delete "${book.title}"?',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final dialogContext = context;
                                  final isDefaultBook = dataManager
                                      .isDefaultBook(book.id);
                                  if (isDefaultBook) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(
                                      dialogContext,
                                    ).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Default books cannot be deleted. You can only delete books you added.',
                                        ),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                    Navigator.pop(dialogContext);
                                    return;
                                  }
                                  await dataManager.removeBook(book.id);
                                  if (!mounted) return;
                                  Navigator.pop(dialogContext);
                                  setState(() {});
                                  ScaffoldMessenger.of(
                                    dialogContext,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Book deleted successfully',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUsersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dataManager.registeredUsers.length,
      itemBuilder: (context, index) {
        final user = dataManager.registeredUsers[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkCard.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                user.email,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              if (user.isAdmin)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.indigoPrimary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Admin',
                    style: TextStyle(
                      color: AppColors.indigoPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrdersTab() {
    return RefreshIndicator(
      onRefresh: _refreshOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dataManager.orderHistory.length,
        itemBuilder: (context, index) {
          final order = dataManager.orderHistory[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkCard.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order.orderId,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    DropdownButton<OrderStatus>(
                      value: order.status,
                      dropdownColor: AppColors.darkCard,
                      style: const TextStyle(color: AppColors.textPrimary),
                      items: OrderStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(_getStatusText(status)),
                        );
                      }).toList(),
                      onChanged: (newStatus) async {
                        if (newStatus != null) {
                          final dialogContext = context;
                          try {
                            await dataManager.updateOrderStatus(
                              order.orderId,
                              newStatus,
                            );
                            if (!mounted) return;
                            setState(() {
                              order.status = newStatus;
                            });
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Order status updated to ${_getStatusText(newStatus)}',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to update order status'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'User: ${order.userId}',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                Text(
                  'Date: ${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                Text(
                  'Total: \$${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.purpleAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _downloadOrderPDF(order),
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Download PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purpleAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddBookDialog({bool isEditing = false}) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: AppColors.darkCard,
          title: Text(
            isEditing ? 'Edit Book' : 'Add New Book',
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                TextField(
                  controller: _authorController,
                  decoration: const InputDecoration(
                    labelText: 'Author',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                TextField(
                  controller: _genreController,
                  decoration: const InputDecoration(
                    labelText: 'Genre',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _coverImageUrlController,
                  onChanged: (value) => setDialogState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Cover Image URL',
                    hintText: 'Enter image URL (e.g., https://...)',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    hintStyle: TextStyle(color: AppColors.textTertiary),
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                if (_coverImageUrlController.text.trim().isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _coverImageUrlController.text.trim(),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.darkSurface,
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: AppColors.textTertiary,
                              size: 40,
                            ),
                          ),
                        ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: AppColors.darkSurface,
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.indigoPrimary,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_titleController.text.trim().isEmpty ||
                    _authorController.text.trim().isEmpty ||
                    _genreController.text.trim().isEmpty ||
                    _priceController.text.trim().isEmpty) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all required fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final price = double.tryParse(_priceController.text.trim());
                if (price == null || price <= 0) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid price'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (isEditing && _editingBook != null) {
                  final updatedBook = Book(
                    id: _editingBook!.id,
                    title: _titleController.text.trim(),
                    author: _authorController.text.trim(),
                    genre: _genreController.text.trim(),
                    price: price,
                    rating: _editingBook!.rating,
                    reviewCount: _editingBook!.reviewCount,
                    coverImageUrl:
                        _coverImageUrlController.text.trim().isNotEmpty
                        ? _coverImageUrlController.text.trim()
                        : _editingBook!.coverImageUrl,
                    description: _descriptionController.text.trim(),
                    isBestseller: _editingBook!.isBestseller,
                    isNewArrival: _editingBook!.isNewArrival,
                    releaseDate: _editingBook!.releaseDate,
                  );
                  await dataManager.updateBook(updatedBook);
                  if (!mounted) return;
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Book updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  final newBook = Book(
                    id: DateTime.now().millisecondsSinceEpoch,
                    title: _titleController.text.trim(),
                    author: _authorController.text.trim(),
                    genre: _genreController.text.trim(),
                    price: price,
                    rating: 0.0,
                    reviewCount: 0,
                    coverImageUrl:
                        _coverImageUrlController.text.trim().isNotEmpty
                        ? _coverImageUrlController.text.trim()
                        : 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400&h=600&fit=crop',
                    description: _descriptionController.text.trim(),
                    isBestseller: false,
                    isNewArrival: true,
                    releaseDate: DateTime.now(),
                  );
                  await dataManager.addBook(newBook);
                  if (!mounted) return;
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Book added successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }

                _titleController.clear();
                _authorController.clear();
                _genreController.clear();
                _priceController.clear();
                _descriptionController.clear();
                _coverImageUrlController.clear();
                _editingBook = null;

                if (!mounted) return;
                Navigator.pop(dialogContext);
                setState(() {});
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadOrderPDF(Order order) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Order Invoice',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Order ID: ${order.orderId}'),
                    pw.Text(
                      'Date: ${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}',
                    ),
                    pw.Text('Status: ${_getStatusText(order.status)}'),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Customer: ${order.userId}'),
                    pw.Text('Total: \$${order.totalAmount.toStringAsFixed(2)}'),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Items:',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Book',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Quantity',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Price',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Total',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                ...order.items.map(
                  (item) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          '${item.book.title}\nby ${item.book.author}',
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('${item.quantity}'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          '\$${item.book.price.toStringAsFixed(2)}',
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          '\$${item.totalPrice.toStringAsFixed(2)}',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'Subtotal: \$${(order.totalAmount - 5.99 - (order.totalAmount * 0.08)).toStringAsFixed(2)}',
                  ),
                  pw.Text('Shipping: \$5.99'),
                  pw.Text(
                    'Tax: \$${(order.totalAmount * 0.08).toStringAsFixed(2)}',
                  ),
                  pw.Divider(),
                  pw.Text(
                    'Total: \$${order.totalAmount.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Shipping Address:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(order.shippingAddress),
            if (order.trackingNumber.isNotEmpty) ...[
              pw.SizedBox(height: 10),
              pw.Text(
                'Tracking Number: ${order.trackingNumber}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}
