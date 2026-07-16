import 'package:flutter/material.dart';

import '../../core/clients/http_client.dart';
import '../../di/service_locator.dart';
import '../../theme/app_colors.dart';

class PasswordResetRequest {
  const PasswordResetRequest({
    required this.id,
    required this.userName,
    required this.requestedAt,
    this.userId,
  });

  final String id;
  final String userName;
  final DateTime requestedAt;
  final int? userId;
}

class PasswordResetRequestsPage extends StatefulWidget {
  const PasswordResetRequestsPage({
    super.key,
    this.requestsLoader,
    this.resetPassword,
  });

  final Future<List<PasswordResetRequest>> Function()? requestsLoader;
  final Future<bool> Function(PasswordResetRequest request)? resetPassword;

  @override
  State<PasswordResetRequestsPage> createState() =>
      _PasswordResetRequestsPageState();
}

class _PasswordResetRequestsPageState extends State<PasswordResetRequestsPage> {
  late Future<List<PasswordResetRequest>> _requestsFuture;
  String? _feedbackMessage;

  @override
  void initState() {
    super.initState();
    _requestsFuture = widget.requestsLoader?.call() ?? Future.value(const []);
  }

  Future<void> _refresh() async {
    setState(() {
      _requestsFuture = widget.requestsLoader?.call() ?? Future.value(const []);
      _feedbackMessage = null;
    });
    await _requestsFuture;
  }

  Future<void> _handleResetPassword(PasswordResetRequest request) async {
    final resetPassword = widget.resetPassword;
    if (resetPassword == null) {
      setState(() {
        _feedbackMessage = 'لا توجد دالة إعادة تعيين متاحة حالياً';
      });
      return;
    }

    setState(() {
      _feedbackMessage = 'جارٍ إعادة تعيين كلمة المرور...';
    });

    final success = await resetPassword(request);
    if (!mounted) return;

    setState(() {
      _feedbackMessage = success
          ? 'تمت إعادة تعيين كلمة المرور بنجاح'
          : 'فشل في إعادة تعيين كلمة المرور';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: const Text(
          'طلبات إعادة تعيين كلمة المرور',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<PasswordResetRequest>>(
          future: _requestsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('حدث خطأ أثناء تحميل الطلبات: ${snapshot.error}'),
              );
            }

            final requests = snapshot.data ?? const <PasswordResetRequest>[];

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (_feedbackMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Text(
                      _feedbackMessage!,
                      style: const TextStyle(color: AppColors.primary),
                    ),
                  ),
                if (requests.isEmpty)
                  _buildEmptyState()
                else
                  ...requests.map(
                    (request) => _buildRequestCard(context, request),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: const Center(
        child: Text(
          'لا توجد طلبات حالياً',
          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, PasswordResetRequest request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary,
                child: Text(
                  request.userName.isNotEmpty ? request.userName[0] : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.userName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'تاريخ الطلب: ${request.requestedAt.toLocal().toString().split('.').first}',
                      style: const TextStyle(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _handleResetPassword(request),
              icon: const Icon(Icons.lock_reset),
              label: const Text('إعادة تعيين كلمة المرور'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
