// Importa o pacote Material do Flutter.
import 'package:flutter/material.dart';

// Um widget de barra de pesquisa desenhado especificamente para ecrãs de mapa.
class MapSearchBar extends StatefulWidget {
  // Uma função de callback que é chamada quando o utilizador submete uma consulta de pesquisa.
  final Function(String) onSubmitted;

  // Construtor para o widget MapSearchBar.
  const MapSearchBar({super.key, required this.onSubmitted});

  @override
  State<MapSearchBar> createState() => _MapSearchBarState();
}

// O estado para o widget MapSearchBar.
class _MapSearchBarState extends State<MapSearchBar> {
  // O controlador para o campo de texto.
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _textController,
        decoration: InputDecoration(
          hintText: 'Pesquisar...',
          // Um botão de ícone para acionar a pesquisa.
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Chama o callback onSubmitted com o texto atual.
              widget.onSubmitted(_textController.text);
            },
          ),
        ),
        // Também aciona a pesquisa quando o utilizador submete a partir do teclado.
        onSubmitted: widget.onSubmitted,
      ),
    );
  }
}
