# Meu Aplicativo de Locais

## Descrição
Este aplicativo permite aos usuários explorar, avaliar e gerenciar locais de interesse. Ele utiliza a API do Foursquare para buscar locais próximos e permite que os usuários adicionem seus próprios locais, avaliações e itinerários.

## Funcionalidades
- **Exploração de Locais**: Pesquise e explore locais próximos usando a API do Foursquare.
- **Avaliações**: Adicione e visualize avaliações de locais.
- **Favoritos**: Adicione locais aos seus favoritos para fácil acesso.
- **Itinerários**: Crie e gerencie itinerários personalizados.
- **Mapa Interativo**: Visualize locais e rotas em um mapa interativo.

## Estrutura do Projeto
- **lib/**: Contém o código-fonte do aplicativo.
  - **views/**: Contém as páginas do aplicativo.
  - **services/**: Contém os serviços para comunicação com APIs e Firestore.
  - **models/**: Contém os modelos de dados.
  - **widgets/**: Contém widgets reutilizáveis.
  - **controller/**: Contém os controladores de estado e lógica de negócios.

## Requisitos
- **Linguagem de Programação**: Dart
- **Framework**: Flutter
- **Banco de Dados**: Firebase Firestore
- **APIs**: Foursquare API e OpenStreetMap

## Instalação
1. Clone o repositório:
    ```bash
    git clone [URL do repositório]
    ```
2. Navegue até o diretório do projeto:
    ```bash
    cd dsi-grupo05
    ```
3. Instale as dependências:
    ```bash
    flutter pub get
    ```
4. Configure as variáveis de ambiente:
    - Crie um arquivo `.env` na raiz do projeto e adicione sua chave da API do Foursquare:
      ```
      FSQ_API_KEY=your_foursquare_api_key
      ```

## Uso
1. Execute o aplicativo:
    ```bash
    flutter run
    ```

## Contribuição
1. Faça um fork do projeto.
2. Crie uma nova branch:
    ```bash
    git checkout -b minha-feature
    ```
3. Faça as alterações e commit:
    ```bash
    git commit -m 'Minha nova feature'
    ```
4. Envie para o repositório remoto:
    ```bash
    git push origin minha-feature
    ```
5. Abra um Pull Request.

## Licença
Este projeto está licenciado sob a MIT License.

