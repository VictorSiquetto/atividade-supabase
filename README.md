# Cadastro de Veículos

Aplicação de terminal em Dart que faz o cadastro de veículos de uma concessionária usando o Supabase. Pelo menu é possível cadastrar, listar, atualizar e excluir veículos, tudo na mesma execução.

## Estrutura

- `bin/main.dart`: menu, leitura e validação dos dados digitados
- `lib/conexao.dart`: carrega o `.env` e cria a conexão com o Supabase
- `lib/veiculos.dart`: métodos do CRUD (`cadastrarVeiculo`, `listarVeiculos`, `atualizarVeiculo`, `excluirVeiculo`)
- `database/veiculos.sql`: script de criação da tabela

## Como configurar

1. No Supabase, abra o **SQL Editor**, cole o conteúdo de `database/veiculos.sql` e clique em **Run**.
2. Na raiz do projeto, crie um arquivo `.env` com a URL e a chave publishable do seu projeto:

```
SUPABASE_URL=https://SEU-PROJETO.supabase.co
SUPABASE_PUBLISHABLE_KEY=sb_publishable_SUA_CHAVE
```

## Como executar

Na raiz do projeto:

```
dart pub get
dart run bin/main.dart
```

## Menu

```
CADASTRO DE VEÍCULOS
1 - Cadastrar veículo
2 - Listar veículos
3 - Atualizar veículo
4 - Excluir veículo
0 - Sair
```

Os dados digitados são validados antes de gravar (marca e modelo não podem ficar vazios, o ano deve estar entre 1900 e o ano atual + 1, o valor deve ser maior que zero e a quilometragem não pode ser negativa). A exclusão pede confirmação S/N.

## Demonstração

Ciclo completo do CRUD em uma única execução, sem reiniciar o programa:

```
CADASTRO DE VEÍCULOS
1 - Cadastrar veículo
2 - Listar veículos
3 - Atualizar veículo
4 - Excluir veículo
0 - Sair
O que deseja fazer? 1
Marca: Chevrolet
Modelo: Onix
Ano: 2022
Valor: 65000
Quilometragem: 35000
Veículo cadastrado!
ID: 4 | Chevrolet Onix | Ano: 2022 | Valor: R$ 65000.00 | Quilometragem: 35000 km

O que deseja fazer? 2

ID: 4 | Marca: Chevrolet | Modelo: Onix
Ano: 2022 | Valor: R$ 65000.00
Quilometragem: 35000 km

O que deseja fazer? 3
ID do veículo: 4
Nova marca: Chevrolet
Novo modelo: Onix LT
Novo ano: 2022
Novo valor: 63000
Nova quilometragem: 35200
Veículo atualizado!
ID: 4 | Chevrolet Onix LT | Ano: 2022 | Valor: R$ 63000.00 | Quilometragem: 35200 km

O que deseja fazer? 4
ID do veículo: 4
Confirma a exclusão? S/N: n
Exclusão cancelada.

O que deseja fazer? 4
ID do veículo: 4
Confirma a exclusão? S/N: s
Veículo excluído!
ID: 4 | Chevrolet Onix LT

O que deseja fazer? 0
Sistema encerrado.
```

O menu aparece novamente após cada operação; ele foi omitido acima para facilitar a leitura.
