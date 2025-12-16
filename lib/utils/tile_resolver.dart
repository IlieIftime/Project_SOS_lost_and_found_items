// Este ficheiro contém uma classe singleton `TileResolver` responsável por encontrar e guardar em cache
// um template de URL de tiles de mapa funcional a partir de uma lista de candidatos.

import 'package:http/http.dart' as http; // Usado para fazer pedidos HTTP.
import 'map_config.dart'; // Importa a configuração do mapa, incluindo chaves de API e URLs candidatos.

/// Uma classe singleton para testar e guardar em cache um template de URL de tiles funcional.
///
/// Este resolver verifica uma lista de potenciais URLs de servidores de tiles do `MapConfig`
/// para encontrar um que esteja a responder e retorne um tile de imagem válido.
/// O primeiro URL funcional é então guardado em cache durante a sessão da aplicação.
/// Chame `TileResolver.getActiveTemplate()` antes de construir mapas que dependem de um
/// endpoint de tiles funcional. Retorna `null` se nenhum template funcional for encontrado.
class TileResolver {
  // O template de URL ativo guardado em cache. É `null` até que um template funcional seja encontrado.
  static String? _activeTemplate;
  // Uma flag para prevenir testes concorrentes de múltiplos chamadores.
  static bool _probing = false;

  /// Testa os URLs candidatos, se necessário, e retorna o template ativo ou `null`.
  ///
  /// Se um template já estiver em cache, é retornado imediatamente.
  /// Se não, itera através dos candidatos do `MapConfig` e testa cada um.
  static Future<String?> getActiveTemplate() async {
    // Se um template já estiver em cache, retorna-o imediatamente.
    if (_activeTemplate != null) return _activeTemplate;
    // Se nenhuma chave MapTiler estiver configurada, nenhum tile pode ser obtido.
    if (!MapConfig.hasMapTilerKey) return null;
    
    // Se outra chamada já estiver a testar um template funcional, espera que termine.
    if (_probing) {
      int attempts = 0;
      // Espera por um máximo de 5 segundos (50 tentativas * 100ms).
      while (_probing && attempts < 50) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }
      // Retorna o template que pode ter sido encontrado pelo outro processo.
      return _activeTemplate;
    }

    // Define a flag de teste como verdadeira para bloquear outras chamadas concorrentes.
    _probing = true;
    try {
      final candidates = MapConfig.tileUrlCandidates;
      // Itera através de cada URL candidato.
      for (final template in candidates) {
        try {
          // Cria um URL de teste substituindo os placeholders por valores de exemplo.
          final testUrl = template
              .replaceAll('{z}', '0')
              .replaceAll('{x}', '0')
              .replaceAll('{y}', '0');
          final uri = Uri.parse(testUrl);

          // Faz um pedido HTTP GET para o URL de teste.
          // Fornece um User-Agent e um cabeçalho Accept conservadores para evitar rejeição.
          final resp = await http
              .get(uri, headers: {
                'User-Agent': 'projeto_prog_mob/1.0',
                'Accept': 'image/*',
              })
              .timeout(const Duration(seconds: 5)); // Define um timeout de 5 segundos.

          // Verifica se o pedido foi bem-sucedido e retornou uma imagem.
          if (resp.statusCode == 200 && resp.headers['content-type']?.startsWith('image/') == true) {
            // Se funcionar, guarda o template em cache e retorna-o.
            _activeTemplate = template;
            return _activeTemplate;
          }
        } catch (_) {
          // Se ocorrer um erro (ex: timeout, erro de rede), ignora-o e tenta o próximo candidato.
        }
      }
    } finally {
      // Repõe a flag de teste assim que o processo estiver concluído.
      _probing = false;
    }
    // Se nenhum template funcional for encontrado após verificar todos os candidatos, retorna null.
    return null;
  }
}
