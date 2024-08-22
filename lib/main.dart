import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Scopes required for Google Sign-In
const List<String> scopes = <String>['email'];

// Load Configuration Files (Initialize GoogleSignIn instance)
GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: scopes,
);

void main() {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize GoogleSignIn instance
  _googleSignIn = GoogleSignIn();
  
  // Run the app
  runApp(const MaterialApp(
    title: "Google Sign-in",
    home: GoogleSigninApp(),
  ));
}

// Main App Widget
class GoogleSigninApp extends StatefulWidget {
  const GoogleSigninApp({super.key});

  @override
  State<GoogleSigninApp> createState() => _GoogleSigninAppState();
}

class _GoogleSigninAppState extends State<GoogleSigninApp> {
  // Current signed-in user
  GoogleSignInAccount? _currentUser;
  // Flag indicating if user has granted permissions
  bool _isAuthorized = false;

  @override
  void initState() {
    super.initState();

    // Listen for changes in the signed-in user
    _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {
      bool isAuthorized = account != null;
      // Check authorization on web
      if (kIsWeb && account != null) {
        isAuthorized = await _googleSignIn.canAccessScopes(scopes);
      }

      setState(() {
        _currentUser = account;
        _isAuthorized = isAuthorized;
      });
    });

    // Sign in silently on web
    _googleSignIn.signInSilently();
  }

  // Handle sign-in button click
  Future<void> _handleSignIn() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      if (googleSignInAccount != null) {
        // Get the authentication object
        final GoogleSignInAuthentication googleAuth =
            await googleSignInAccount.authentication;

        // Retrieve the ID token
        final String? idToken = googleAuth.idToken;

        // Debug info
        if (kDebugMode) {
          print('Signed in as: ${googleSignInAccount.email}');
          print('Display name: ${googleSignInAccount.displayName}');
          if (idToken != null) {
            print('ID Token: $idToken');
          } else {
            print('ID Token is null');
          }
        }
      } else {
        // Debug info if sign-in fails
        if (kDebugMode) {
          print('Failed to sign in.');
        }
      }
    } catch (error) {
      // Debug info in case of error
      if (kDebugMode) {
        print('Error signing in: $error');
      }
    }
  }

  // Prompt user to authorize required scopes
  Future<void> _handleAuthorizeScopes() async {
    final bool isAuthorized = await _googleSignIn.requestScopes(scopes);

    if (mounted) {
      setState(() {
        _isAuthorized = isAuthorized;
      });

      if (isAuthorized) {
        // Display a message
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Authorization Successful"),
              content: const Text(
                  "You are now authorized to access the required scopes."),
              actions: <Widget>[
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  // Handle sign-out button click
  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  // Build the widget tree for the app body
  Widget _buildBody() {
    final user = _currentUser;
    if (user != null) {
      // User is authenticated
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          // Display user info
          ListTile(
            leading: GoogleUserCircleAvatar(
              identity: user,
            ),
            title: Text(user.displayName ?? ''),
            subtitle: Text(user.email),
          ),
          // Display sign-in success message
          const Text('Signed in successfully.'),
          // Display additional permissions or request button
          if (_isAuthorized)
            const CustomInfo(message: 'Permissions granted successfully')
          else
            ElevatedButton(
              onPressed: _handleAuthorizeScopes,
              child: const Text('REQUEST PERMISSIONS'),
            ),
          // Display sign-out button
          ElevatedButton(
            onPressed: _handleSignOut,
            child: const Text('SIGN OUT'),
          ),
        ],
      );
    } else {
      // User is not authenticated
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const Text('You are not currently signed in.'),
          // Display sign-in button
          buildSignInButton(onPressed: _handleSignIn),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Sign-In'),
      ),
      body: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: _buildBody(),
      ),
    );
  }
}

/// The type of the onClick callback for the (mobile) Sign In Button.
typedef HandleSignInFn = Future<void> Function();

/// Renders a SIGN IN button that calls `handleSignIn` onclick.
Widget buildSignInButton({HandleSignInFn? onPressed}) {
  return ElevatedButton(
    onPressed: onPressed,
    child: const Text('SIGN IN WITH GOOGLE'),
  );
}

// CustomInfo widget for displaying messages
class CustomInfo extends StatefulWidget {
  final String message;
  final Duration duration;

  const CustomInfo({
    super.key,
    required this.message,
    this.duration = const Duration(seconds: 3),
  });

  @override
  _CustomInfoState createState() => _CustomInfoState();
}

class _CustomInfoState extends State<CustomInfo> {
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _hideAfterDelay();
  }

  void _hideAfterDelay() {
    Future.delayed(widget.duration, () {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isVisible
        ? Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade800,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.message,
              style: const TextStyle(color: Colors.white),
            ),
          )
        : const SizedBox.shrink();
  }
}
