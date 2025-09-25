import 'package:flutter/material.dart';
import '../controllers/login_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late LoginController _loginController;

  @override
  void initState() {
    super.initState();
    _loginController = LoginController(
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _loginController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Company Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey[700]!,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        'assets/images/company_logo.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.inventory,
                            size: 60,
                            color: Colors.white,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Title
                  const Text(
                    'SHN Mobile',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Inventory Management System',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Login Form
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey[800]!,
                        width: 1,
                      ),
                    ),
                    child: Form(
                      key: _loginController.formKey,
                      child: Column(
                        children: [
                                                     // Username Field
                           TextFormField(
                             controller: _loginController.usernameController,
                             style: const TextStyle(color: Colors.white),
                             cursorColor: Colors.white,
                             decoration: InputDecoration(
                               labelText: 'Username',
                               labelStyle: const TextStyle(color: Colors.white70),
                               prefixIcon: const Icon(Icons.person, color: Colors.white70),
                               border: OutlineInputBorder(
                                 borderRadius: BorderRadius.circular(12),
                                 borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                               ),
                               enabledBorder: OutlineInputBorder(
                                 borderRadius: BorderRadius.circular(12),
                                 borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                               ),
                               focusedBorder: OutlineInputBorder(
                                 borderRadius: BorderRadius.circular(12),
                                 borderSide: const BorderSide(color: Colors.white, width: 2),
                               ),
                             ),
                            validator: _loginController.validateUsername,
                          ),
                          const SizedBox(height: 16),
                          
                                                     // Password Field
                           TextFormField(
                             controller: _loginController.passwordController,
                             obscureText: _loginController.obscurePassword,
                             style: const TextStyle(color: Colors.white),
                             cursorColor: Colors.white,
                             decoration: InputDecoration(
                               labelText: 'Password',
                               labelStyle: const TextStyle(color: Colors.white70),
                               prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                               suffixIcon: IconButton(
                                 icon: Icon(
                                   _loginController.obscurePassword ? Icons.visibility : Icons.visibility_off,
                                   color: Colors.white70,
                                 ),
                                 onPressed: _loginController.togglePasswordVisibility,
                               ),
                               border: OutlineInputBorder(
                                 borderRadius: BorderRadius.circular(12),
                                 borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                               ),
                               enabledBorder: OutlineInputBorder(
                                 borderRadius: BorderRadius.circular(12),
                                 borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                               ),
                               focusedBorder: OutlineInputBorder(
                                 borderRadius: BorderRadius.circular(12),
                                 borderSide: const BorderSide(color: Colors.white, width: 2),
                               ),
                             ),
                            validator: _loginController.validatePassword,
                          ),
                          const SizedBox(height: 24),
                          
                                                     // Login Button
                           SizedBox(
                             width: double.infinity,
                             height: 50,
                             child: ElevatedButton(
                               onPressed: _loginController.isLoading ? null : () => _loginController.login(context),
                               style: ElevatedButton.styleFrom(
                                 backgroundColor: Colors.grey[800],
                                 foregroundColor: Colors.white,
                                 shape: RoundedRectangleBorder(
                                   borderRadius: BorderRadius.circular(12),
                                 ),
                                 elevation: 2,
                               ),
                              child: _loginController.isLoading
                                                                     ? const SizedBox(
                                       width: 20,
                                       height: 20,
                                       child: CircularProgressIndicator(
                                         strokeWidth: 2,
                                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                       ),
                                     )
                                  : const Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 