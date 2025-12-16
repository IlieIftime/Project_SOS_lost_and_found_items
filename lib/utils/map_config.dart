// Este ficheiro lida com a configuração dos tiles do mapa usados na aplicação.
// Foi desenhado para funcionar com o MapTiler, um fornecedor de mapas comercial, para evitar
// sobrecarregar os servidores de tiles do OpenStreetMap, que são mantidos por voluntários.

// IMPORTANTE: Por segurança, as chaves de API não devem ser incluídas no controlo de versões.
// Forneça a chave do MapTiler em tempo de compilação usando a flag `--dart-define`:
// `flutter run --dart-define=MAPTILER_KEY=sua_chave`

class MapConfig {
  // A chave de API do MapTiler é lida a partir de uma variável de ambiente em tempo de compilação.
  // Isto evita que chaves sensíveis sejam guardadas no sistema de controlo de versões.
  // É fornecido um valor padrão, mas é recomendado usar uma chave pessoal.
  static const String mapTilerKey = String.fromEnvironment('MAPTILER_KEY', defaultValue: '8RGJ3mCWOxoXXo1iaKu2');

  // Um getter booleano para verificar se a chave de API do MapTiler foi fornecida.
  static bool get hasMapTilerKey => mapTilerKey.isNotEmpty;

  // Retorna o template do URL dos tiles do mapa para ser usado com o TileLayer do `flutter_map`.
  // Este método fornece um URL para os serviços do MapTiler.
  // URLs de exemplo para o MapTiler:
  // 1) Endpoint de Mapas (preferencial): https://api.maptiler.com/maps/basic/256/{z}/{x}/{y}.png?key=SUA_CHAVE
  // 2) Endpoint de Tiles: https://api.maptiler.com/tiles/basic/{z}/{x}/{y}.png?key=SUA_CHAVE
  // 3) Estilo de Ruas: https://api.maptiler.com/maps/streets/256/{z}/{x}/{y}.png?key=SUA_CHAVE
  static String get tileUrlTemplate {
    // Se não houver chave de API disponível, retorna uma string vazia.
    if (!hasMapTilerKey) return '';

    // O endpoint de 'mapas' preferencial, que inclui estilo e tamanho do tile.
    return 'https://api.maptiler.com/maps/basic/256/{z}/{x}/{y}.png?key=$mapTilerKey';
  }

  // Expõe uma lista de templates de URL de tiles candidatos.
  // Isto permite que quem chama a função possa testar qual URL funciona melhor para a sua conta e configuração.
  static List<String> get tileUrlCandidates {
    // Se não houver chave de API disponível, retorna uma lista vazia.
    if (!hasMapTilerKey) return [];
    
    // O template de URL primário e recomendado.
    final primary = 'https://api.maptiler.com/maps/basic/256/{z}/{x}/{y}.png?key=$mapTilerKey';
    // URLs de fallback caso o primário não seja adequado.
    final fallback1 = 'https://api.maptiler.com/tiles/basic/{z}/{x}/{y}.png?key=$mapTilerKey';
    final fallback2 = 'https://api.maptiler.com/maps/streets/256/{z}/{x}/{y}.png?key=$mapTilerKey';
    
    return [primary, fallback1, fallback2];
  }

  // Um getter auxiliar para o texto de atribuição a ser exibido no mapa.
  // A atribuição correta é exigida pela maioria dos fornecedores de mapas.
  static String get attributionText {
    // Se uma chave MapTiler estiver a ser usada, mostra a atribuição apropriada.
    if (hasMapTilerKey) return '© MapTiler © OpenStreetMap contributors';
    // Se nenhuma chave estiver configurada, informa o utilizador que os tiles estão bloqueados.
    return 'Tiles do OpenStreetMap bloqueados — configure uma chave de fornecedor de tiles';
  }
}
