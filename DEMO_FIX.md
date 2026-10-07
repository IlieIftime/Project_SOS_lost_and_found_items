# Correções para a demo

## Causas
1. **Firestore web (Edge) pendurado ~20s** – o canal WebChannel é bloqueado/atrasado; `doc.get()` no login falhava (erro genérico) e o `set()` do registo dava erro mas acabava por gravar. -> `main.dart`: long-polling forçado + cache off; `auth_service.dart`: timeouts, perfil Firestore em melhor esforço (login/registo já não dependem dele).
2. **Convidado sem itens** – `firestore.rules` exigia `signedIn()` para ler. -> sessão anónima automática no preview + regras a permitir leitura pública de itens aprovados.

## Passos (obrigatório 1 e 2)
1. Publicar regras:  `firebase deploy --only firestore:rules`  (ou colar `firestore.rules` na consola > Firestore > Regras).
2. Consola Firebase > Authentication > Sign-in method: ativar **Email/Password** e **Anonymous**.
3. Confirmar que existem em Authentication os utilizadores `admin@sos.com` (admin123) e `user@sos.com` (user123); se não, criar.
4. Confirmar que os itens têm `status: "aprovado"`.
5. `flutter clean && flutter pub get && flutter run -d edge`
   (se persistir: desativar extensões/adblock no Edge ou usar `-d chrome`).
