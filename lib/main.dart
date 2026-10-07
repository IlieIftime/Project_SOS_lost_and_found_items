// Importa os pacotes necessários.
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Para a inicialização do Firebase.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

// Importa os ecrãs e utilitários da aplicação.
import 'screens/login_screen.dart';
import 'utils/styles.dart';

// O ponto de entrada principal da aplicação.
void main() async {
  // Garante que a ligação (binding) do Flutter está inicializada antes de executar a aplicação.
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa os serviços do Firebase.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // FIX (web/Edge): o canal WebChannel do Firestore fica bloqueado/pendurado
  // (extensões, tracking prevention, proxies) -> leituras/escritas demoram ~20s
  // ou falham. Long-polling é fiável. Cache offline desligada para não
  // servir/guardar estado antigo durante a demo.
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
    webExperimentalForceLongPolling: true,
  );

  // Executa o widget principal da aplicação.
  runApp(const MyApp());
}

// O widget raiz da aplicação.
class MyApp extends StatelessWidget {
  // Construtor para o widget MyApp.
  const MyApp({super.key});

  // Este método constrói a árvore de widgets da aplicação.
  @override
  Widget build(BuildContext context) {
    // O MaterialApp é a raiz da árvore de widgets da aplicação.
    return MaterialApp(
      // O título da aplicação, usado pelo sistema operativo.
      title: 'SOS Perdidos e Achados',
      // Esconde a faixa de depuração no canto superior direito.
      debugShowCheckedModeBanner: false,
      // Define o tema global para a aplicação.
      theme: AppStyles.lightTheme,
      // O ecrã inicial da aplicação.
      home: const LoginScreen(),
    );
  }
}
