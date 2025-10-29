import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/privy_wallet_service.dart';
import '../theme/app_theme.dart';

/// Privy Login Screen
/// 
/// Allows users to login with email and create an embedded Solana wallet
class PrivyLoginScreen extends StatefulWidget {
  const PrivyLoginScreen({super.key});

  @override
  State<PrivyLoginScreen> createState() => _PrivyLoginScreenState();
}

class _PrivyLoginScreenState extends State<PrivyLoginScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _codeSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Wallet with Privy'),
        backgroundColor: AppTheme.primaryPink,
        foregroundColor: Colors.white,
      ),
      body: Consumer<PrivyWalletService>(
        builder: (context, privyService, child) {
          // If authenticated, show wallet creation
          if (privyService.isAuthenticated) {
            return _buildWalletCreation(context, privyService);
          }
          
          // Show login form
          return _buildLoginForm(context, privyService);
        },
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context, PrivyWalletService privyService) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // Logo/Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryPink, AppTheme.primaryPurple],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Title
              Text(
                'Create Your Wallet',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                'Enter your email to create a secure Solana wallet',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Email field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'your@email.com',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: !privyService.isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Send code button
              ElevatedButton(
                onPressed: privyService.isLoading || _codeSent
                    ? null
                    : () => _handleSendCode(context, privyService),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: privyService.isLoading && !_codeSent
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Send Verification Code',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              
              // Show verification code input if code was sent
              if (_codeSent) ...[
                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 30),
                
                // Code field
                TextFormField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    labelText: 'Verification Code',
                    hintText: 'Enter 6-digit code',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  enabled: !privyService.isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the verification code';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Verify and login button
                ElevatedButton(
                  onPressed: privyService.isLoading
                      ? null
                      : () => _handleLogin(context, privyService),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: privyService.isLoading && _codeSent
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Verify & Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Error message
              if (privyService.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          privyService.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletCreation(BuildContext context, PrivyWalletService privyService) {
    // Check if wallet already exists
    final hasWallet = privyService.solanaAddress != null;
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Success icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.pastelGreen, AppTheme.moodHappy],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasWallet ? Icons.check_circle : Icons.account_balance_wallet,
                size: 50,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Title
            Text(
              hasWallet ? 'Wallet Ready!' : 'Create Your Wallet',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            if (hasWallet) ...[
              // Wallet address display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Your Solana Address',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      privyService.solanaAddress!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Done button
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, privyService.solanaAddress);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ] else ...[
              // Create wallet button
              Text(
                'Click below to create your Solana wallet',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: privyService.isLoading
                    ? null
                    : () => _handleCreateWallet(context, privyService),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: privyService.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Create Solana Wallet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Logout button
            TextButton(
              onPressed: () async {
                await privyService.logout();
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSendCode(BuildContext context, PrivyWalletService privyService) async {
    if (!_formKey.currentState!.validate()) return;
    
    privyService.clearError();
    final success = await privyService.sendCode(_emailController.text.trim());
    
    if (success && context.mounted) {
      setState(() {
        _codeSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Verification code sent! Check your email.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  void _handleLogin(BuildContext context, PrivyWalletService privyService) async {
    if (!_formKey.currentState!.validate()) return;
    
    privyService.clearError();
    final success = await privyService.loginWithCode(
      email: _emailController.text.trim(),
      code: _codeController.text.trim(),
    );
    
    if (success && context.mounted) {
      // Success! User is now authenticated
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Login successful!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _handleCreateWallet(BuildContext context, PrivyWalletService privyService) async {
    final success = await privyService.createSolanaWallet();
    
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Wallet created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

