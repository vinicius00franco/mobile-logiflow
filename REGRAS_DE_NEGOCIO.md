# Regras de Negócio

## Como Documentar
- Descrever cada regra de forma clara e objetiva
- Usar verbos no infinitivo (Validar, Permitir, Bloquear, Calcular)
- Incluir condições e exceções quando aplicável
- Referenciar módulo ou funcionalidade relacionada

## Identidade Visual (Branding)
- O aplicativo utiliza a marca **LogiFlow**.
- Todas as moedas devem ser exibidas com o símbolo **R$**.
- Informações críticas como ID do motorista devem manter tamanho de fonte acessível (mínimo 12px).

## Monitor de Logística em Tempo Real

### Deslocamento de Motoristas
- Simular movimento progressivo entre origem e destino com interpolação linear de coordenadas
- Atualizar posição a cada 1 segundo com progresso de 2% do trajeto
- Gerar automaticamente nova rota quando motorista atingir 100% do trajeto
- Aplicar deslocamento apenas para motoristas com status "Em Entrega"
- Calcular tempo estimado usando velocidade média de 20km/h (distância * 3 minutos)

### Status dos Motoristas
- **Disponível**: Motorista sem entrega ativa, visível em verde, contabilizado no raio de 5km
- **Em Entrega**: Motorista em trajeto ativo, visível em azul, exibindo rota no mapa
- **Offline**: Motorista indisponível, visível em cinza, não recebe novas entregas
- **Emergência**: Situação crítica, visível em vermelho, dispara alerta automático no console

### Cálculos de Distância
- Utilizar fórmula de Haversine para cálculo preciso entre coordenadas
- Raio de busca padrão de 5km para motoristas disponíveis
- Considerar localização do usuário fixa em São Paulo (-23.5505, -46.6333)

### Visualização no Mapa
- Exibir 3 markers por motorista: posição atual, origem (verde) e destino (vermelho)
- Desenhar polyline tracejada conectando origem-posição-destino para motoristas em entrega
- Atualizar markers e polylines automaticamente a cada atualização de posição
- Permitir centralizar câmera ao tocar em motorista na lista

### Interface de Motoristas
- Exibir cards com nome, veículo, status, tempo estimado, distância e preço
- Utilizar ícones circulares com cores dinâmicas baseadas no status do motorista
- Exibir cabeçalho informativo com saudação e resumo em tempo real da frota (Total, Em Rota, Livres)
- Permitir expansão via dropdown nos cards compactos (na tela de mapa) para visualizar detalhes completos
- Mostrar no card expandido: posição atual, origem, destino, distância, tempo estimado e preço
- Fechar automaticamente outros cards ao navegar entre motoristas
- Sincronizar barra de progresso com scroll horizontal dos cards
- Usar cache de endereços para evitar requisições repetidas ao servidor de geocoding
- Limitar altura do container de cards para maximizar área do mapa

### Performance e Otimizações
- Usar RepaintBoundary em widgets independentes (mapa, barra de progresso, cards)
- Implementar ValueNotifier para estados locais evitando rebuilds de StatefulWidget
- Aplicar const constructors em widgets estáticos
- Usar AnimatedSize e AnimatedContainer para transições suaves
- Cache de endereços com chave baseada em coordenadas arredondadas
- Timeout de 5 segundos em requisições de geocoding para não bloquear UI

### Geração de Rotas
- Utilizar localizações reais de São Paulo para origens iniciais
- Gerar destinos aleatórios dentro de raio de 0.2 graus (~22km) ao completar entrega
- Manter 4 motoristas ativos simultaneamente com nomes e veículos fixos

## Validações

### [Exemplo] Autenticação
- Validar formato de e-mail antes de submeter
- Exigir senha com mínimo de 8 caracteres
- Bloquear conta após 3 tentativas falhas

## Fluxos de Processo

### [Exemplo] Cadastro de Usuário
- Verificar se e-mail já está cadastrado
- Enviar e-mail de confirmação após registro
- Ativar conta somente após confirmação

## Cálculos e Lógicas

### [Exemplo] Sistema de Pontos
- Calcular pontos baseado em valor da compra
- Aplicar multiplicador para clientes premium
- Expirar pontos após 12 meses de inatividade

## Permissões e Acessos

### [Exemplo] Controle de Acesso
- Permitir edição apenas para usuários autenticados
- Restringir exclusão para administradores
- Registrar todas as ações de modificação
