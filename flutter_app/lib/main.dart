import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<ApiService>(
      create: (_) => ApiService(),    // Global API service instance
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Med AI Assistant',
        
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: Colors.grey[100],
          appBarTheme: AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.indigo,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 3,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),

        home: HomeScreen(),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import 'screens/home_screen.dart';
// import 'services/api_service.dart';
// import 'screens/login_screen.dart'; // make sure path matches your project

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Provider<ApiService>(
//       create: (_) => ApiService(), // Global API service instance
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         title: 'Med AI Assistant',
//         theme: ThemeData(
//           primarySwatch: Colors.indigo,
//           scaffoldBackgroundColor: Colors.grey[100],
//           appBarTheme: const AppBarTheme(
//             elevation: 0,
//             centerTitle: true,
//             backgroundColor: Colors.indigo,
//             titleTextStyle: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           cardTheme: const CardThemeData(
//             elevation: 3,
//             margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//           ),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//           ),
//         ),
//         home: const Landing(),
//       ),
//     );
//   }
// }

// /// Landing widget: listens to Firebase auth state and shows LoginPage or HomeScreen.
// class Landing extends StatelessWidget {
//   const Landing({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         // while waiting for auth state, show progress
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(body: Center(child: CircularProgressIndicator()));
//         }

//         final user = snapshot.data;
//         if (user == null) {
//           return const LoginScreen(); // not signed in
//         } else {
//           return const HomeScreen(); // signed in
//         }
//       },
//     );
//   }
// }
