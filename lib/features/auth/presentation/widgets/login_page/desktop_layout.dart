part of '../../pages/login_page.dart';

class _DesktopLayout extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final bool obscure;
  final bool loading;
  final String? error;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  const _DesktopLayout({
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
    return Row(
      children: [
        // ── Left Panel ─────────────────────────
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: DColors.cardGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const _BrandPanel(),
          ),
        ),

        // ── Right Panel (Form) ──────────────────
        Container(
          width: 480,
          height: double.infinity,
          color: DColors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
          child: Center(
            child: SingleChildScrollView(
              child: _LoginForm(
                formKey: formKey,
                emailCtrl: emailCtrl,
                passCtrl: passCtrl,
                obscure: obscure,
                loading: loading,
                error: error,
                onToggleObscure: onToggleObscure,
                onSubmit: onSubmit,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Mobile Layout
// ─────────────────────────────────────────────
