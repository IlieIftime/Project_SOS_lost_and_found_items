// Importa o pacote Material do Flutter.
import 'package:flutter/material.dart';
// Importa a lista de imagens de exemplo pré-definidas.
import '../utils/assets.dart';

// Uma função auxiliar para construir um widget de Imagem a partir de um caminho de asset, com verificações de segurança.
//
// Esta função verifica se o [assetPath] fornecido é válido e existe na lista pré-definida
// [assetImages] antes de tentar exibi-lo. Se o caminho for nulo, vazio,
// ou não for encontrado na lista, retorna um SizedBox vazio, prevenindo erros em tempo de execução.
Widget buildAssetImageIfExists(String? assetPath, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
  // Se o caminho do asset for nulo ou vazio, retorna um widget vazio.
  if (assetPath == null || assetPath.isEmpty) return const SizedBox.shrink();
  // Se o caminho do asset não estiver na lista de assets conhecidos, retorna um widget vazio.
  if (!assetImages.contains(assetPath)) return const SizedBox.shrink();
  
  // Tenta criar um widget Image.asset.
  try {
    return Image.asset(assetPath, width: width, height: height, fit: fit);
  } catch (_) {
    // Se ocorrer algum erro (ex: ficheiro não encontrado, embora improvável com a verificação acima),
    // retorna um widget vazio para evitar que a aplicação falhe.
    return const SizedBox.shrink();
  }
}
