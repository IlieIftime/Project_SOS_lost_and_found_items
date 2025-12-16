# SOS Perdidos e Achados

## Visão Geral

O **SOS Perdidos e Achados** é uma aplicação móvel desenvolvida em Flutter, criada para facilitar o reporte e a busca por itens perdidos. A plataforma funciona como um ponto central onde utilizadores podem publicar informações sobre objetos que perderam ou encontraram, com o objetivo de ajudar a devolvê-los aos seus respetivos donos. A aplicação inclui um sistema de autenticação, um painel de administração para moderação de conteúdo, e funcionalidades de geolocalização para visualizar a localização dos itens num mapa.

## Funcionalidades

### Utilizador Padrão
- **Autenticação**: Registo e login de novas contas de utilizador.
- **Visualização de Itens**: Acesso a uma lista de itens perdidos e achados que já foram aprovados.
- **Filtro por Categoria**: Capacidade de filtrar os itens por categorias como "Acessórios", "Chaves", "Documentos", etc.
- **Reportar um Item**: Formulário completo para reportar um item, incluindo descrição, categoria, fotografia (via câmara ou galeria) e localização.
- **Seleção de Localização**: Múltiplas formas de definir a localização de um item:
    - Utilizar a localização GPS atual do dispositivo.
    - Pesquisar por um endereço.
    - Selecionar um ponto diretamente num mapa interativo.
- **Visualização no Mapa**: Ver a localização de todos os itens reportados num mapa.

### Administrador
- **Painel de Administração**: Dashboard exclusivo para a gestão de todos os itens reportados.
- **Moderação de Conteúdo**: Capacidade de aprovar ou remover itens que estão pendentes de revisão.
- **Visão Geral**: Acesso a todos os itens da plataforma, incluindo os pendentes e os já aprovados.

## Arquitetura do Projeto

O projeto segue uma arquitetura simples e organizada, separando as responsabilidades em diferentes diretórios:

- `lib/`
  - `main.dart`: Ponto de entrada da aplicação.
  - `models/`: Define as estruturas de dados da aplicação (ex: `ItemModel`, `UserModel`).
  - `screens/`: Contém todos os ecrãs (interfaces de utilizador) da aplicação.
    - `admin/`: Ecrãs específicos para a área de administração.
  - `services/`: Centraliza a lógica de negócio, como a autenticação (`AuthService`) e a gestão de itens (`ItemService`).
  - `utils/`: Ficheiros utilitários, como paleta de cores (`colors.dart`), estilos (`styles.dart`) e configurações de mapa (`map_config.dart`).
  - `widgets/`: Componentes de UI reutilizáveis (ex: `CustomButton`, `CustomTextField`).

## Requisitos

- **Flutter SDK**: Versão 3.9.2 ou superior.
- **IDE**: Android Studio ou Visual Studio Code.
- **Dispositivo**: Emulador Android/iOS ou um dispositivo físico.
- **Chave de API (Mapas)**: Para a funcionalidade do mapa, é necessária uma chave de API do [MapTiler](https://www.maptiler.com/).

## Como Executar

1.  **Clonar o Repositório:**
    ```bash
    git clone <url-do-seu-repositorio>
    cd projeto_prog_mob
    ```

2.  **Instalar Dependências:**
    Execute o comando abaixo para descarregar todas as dependências listadas no ficheiro `pubspec.yaml`.
    ```bash
    flutter pub get
    ```

3.  **Executar a Aplicação:**
    Para executar a aplicação, utilize o seguinte comando. Para que os mapas funcionem corretamente, é recomendado fornecer a sua chave da API do MapTiler.

    ```bash
    flutter run --dart-define=MAPTILER_KEY=SUA_CHAVE_AQUI
    ```
    Substitua `SUA_CHAVE_AQUI` pela sua chave de API do MapTiler.

## Comandos Úteis

- **Executar sem chave de mapa (funcionalidades limitadas):**
  ```bash
  flutter run
  ```
- **Executar com chave de mapa:**
  ```bash
  flutter run --dart-define=MAPTILER_KEY=SUA_CHAVE_AQUI
  ```

## Credenciais de Teste

Para facilitar a exploração da aplicação, pode usar as seguintes contas:

-   **Administrador**:
    -   **Email**: `admin@sos.com`
    -   **Senha**: `admin123`
-   **Utilizador Comum**:
    -   **Email**: `user@sos.com`
    -   **Senha**: `user123`

## Limitações

- **Backend**: A aplicação está conectada ao Firebase (Auth, Firestore), mas o upload de imagens para o Firebase Storage não está completamente implementado; as URLs de imagem são simuladas.
- **Serviços Duplicados**: O ficheiro `lost_items_service.dart` tem funcionalidades redundantes com `item_service.dart` e deve ser consolidado ou removido.
- **Geocodificação de Endereços**: A funcionalidade de pesquisa de endereço no formulário de reporte retorna resultados genéricos ("Location 1", "Location 2") e precisa de ser melhorada para exibir os nomes dos locais retornados pela API de geocodificação.

## Licença

Este projeto foi desenvolvido para fins educacionais. É livre para ser utilizado como referência, modificado e distribuído.
