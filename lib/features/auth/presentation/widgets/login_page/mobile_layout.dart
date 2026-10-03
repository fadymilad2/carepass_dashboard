part of '../../pages/login_page.dart';

class _MobileLayout extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final bool obscure;
  final bool loading;
  final String? error;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  const _MobileLayout({
    required this.formKey,
    required this.emailCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.loading,
    required this.error,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Mini brand header
            const SizedBox(height: 32),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: DColors.cardGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'CarePass Admin',
              style: DTextStyles.h2.copyWith(color: DColors.primary),
            ),
            const SizedBox(height: 40),

            _LoginForm(
              formKey: formKey,
              emailCtrl: emailCtrl,
              passCtrl: passCtrl,
              obscure: obscure,
              loading: loading,
              error: error,
              onToggleObscure: onToggleObscure,
              onSubmit: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Brand Panel (Desktop Left)
// ─────────────────────────────────────────────
