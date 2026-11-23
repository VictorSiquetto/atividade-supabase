import 'dart:io';

import 'package:cadastro_veiculos/conexao.dart';
import 'package:cadastro_veiculos/veiculos.dart';
import 'package:supabase/supabase.dart';

final int anoMinimo = 1900;
final int anoMaximo = DateTime.now().year + 1;

const double valorMaximo = 10000000000;

Future<void> main() async {
  SupabaseClient? cliente;

  try {
    cliente = conectar();

    var executando = true;
    while (executando) {
      mostrarMenu();
      final opcao = lerTexto('O que deseja fazer? ');

      try {
        switch (opcao) {
          case '1':
            await opcaoCadastrar(cliente);
            break;
          case '2':
            await opcaoListar(cliente);
            break;
          case '3':
            await opcaoAtualizar(cliente);
            break;
          case '4':
            await opcaoExcluir(cliente);
            break;
          case '0':
            print('Sistema encerrado.');
            executando = false;
            break;
          default:
            print('Opção inválida. Tente novamente.');
        }
      } catch (e) {
        print('Erro ao executar a operação: $e');
      }
    }
  } catch (e) {
    print('Não foi possível conectar ao Supabase: $e');
  } finally {
    await cliente?.dispose();
  }
}

void mostrarMenu() {
  print('');
  print('CADASTRO DE VEÍCULOS');
  print('1 - Cadastrar veículo');
  print('2 - Listar veículos');
  print('3 - Atualizar veículo');
  print('4 - Excluir veículo');
  print('0 - Sair');
}

Future<void> opcaoCadastrar(SupabaseClient cliente) async {
  final marca = validarMarca(lerTexto('Marca: '));
  if (marca == null) return;

  final modelo = validarModelo(lerTexto('Modelo: '));
  if (modelo == null) return;

  final ano = validarAno(lerTexto('Ano: '));
  if (ano == null) return;

  final valor = validarValor(lerTexto('Valor: '));
  if (valor == null) return;

  final km = validarQuilometragem(lerTexto('Quilometragem: '));
  if (km == null) return;

  final veiculo =
      await cadastrarVeiculo(cliente, marca, modelo, ano, valor, km);

  print('Veículo cadastrado!');
  print(formatarResumo(veiculo));
}

Future<void> opcaoListar(SupabaseClient cliente) async {
  final veiculos = await listarVeiculos(cliente);

  if (veiculos.isEmpty) {
    print('Nenhum veículo cadastrado.');
    return;
  }

  for (final v in veiculos) {
    print('');
    print('ID: ${v['id']} | Marca: ${v['marca']} | Modelo: ${v['modelo']}');
    print('Ano: ${v['ano']} | Valor: ${formatarValor(v['valor'])}');
    print('Quilometragem: ${v['quilometragem']} km');
  }
}

Future<void> opcaoAtualizar(SupabaseClient cliente) async {
  final id = validarId(lerTexto('ID do veículo: '));
  if (id == null) return;

  final marca = validarMarca(lerTexto('Nova marca: '));
  if (marca == null) return;

  final modelo = validarModelo(lerTexto('Novo modelo: '));
  if (modelo == null) return;

  final ano = validarAno(lerTexto('Novo ano: '));
  if (ano == null) return;

  final valor = validarValor(lerTexto('Novo valor: '));
  if (valor == null) return;

  final km = validarQuilometragem(lerTexto('Nova quilometragem: '));
  if (km == null) return;

  final veiculo =
      await atualizarVeiculo(cliente, id, marca, modelo, ano, valor, km);

  if (veiculo == null) {
    print('Nenhum veículo encontrado com o ID $id. Nada foi alterado.');
    return;
  }

  print('Veículo atualizado!');
  print(formatarResumo(veiculo));
}

Future<void> opcaoExcluir(SupabaseClient cliente) async {
  final id = validarId(lerTexto('ID do veículo: '));
  if (id == null) return;

  final resposta = lerTexto('Confirma a exclusão? S/N: ');

  if (resposta == 'N' || resposta == 'n') {
    print('Exclusão cancelada.');
    return;
  }
  if (resposta != 'S' && resposta != 's') {
    print('Resposta inválida. Digite S ou N. Nenhum veículo foi excluído.');
    return;
  }

  final veiculo = await excluirVeiculo(cliente, id);

  if (veiculo == null) {
    print('Nenhum veículo encontrado com o ID $id. Nada foi excluído.');
    return;
  }

  print('Veículo excluído!');
  print('ID: ${veiculo['id']} | ${veiculo['marca']} ${veiculo['modelo']}');
}

String lerTexto(String mensagem) {
  stdout.write(mensagem);
  return (stdin.readLineSync() ?? '').trim();
}

String formatarValor(dynamic valor) {
  final numero = (valor as num).toDouble();
  return 'R\$ ${numero.toStringAsFixed(2)}';
}

String formatarResumo(Map<String, dynamic> v) {
  return 'ID: ${v['id']} | ${v['marca']} ${v['modelo']} | '
      'Ano: ${v['ano']} | Valor: ${formatarValor(v['valor'])} | '
      'Quilometragem: ${v['quilometragem']} km';
}

String? validarMarca(String texto) {
  if (texto.isEmpty) {
    print('Marca inválida: o campo não pode ficar vazio.');
    return null;
  }
  if (texto.length > 50) {
    print('Marca inválida: máximo de 50 caracteres.');
    return null;
  }
  return texto;
}

String? validarModelo(String texto) {
  if (texto.isEmpty) {
    print('Modelo inválido: o campo não pode ficar vazio.');
    return null;
  }
  if (texto.length > 100) {
    print('Modelo inválido: máximo de 100 caracteres.');
    return null;
  }
  return texto;
}

int? validarAno(String texto) {
  final ano = int.tryParse(texto);
  if (ano == null) {
    print('Ano inválido: digite um número inteiro.');
    return null;
  }
  if (ano < anoMinimo || ano > anoMaximo) {
    print('Ano inválido: deve estar entre $anoMinimo e $anoMaximo.');
    return null;
  }
  return ano;
}

double? validarValor(String texto) {
  final normalizado = texto.replaceAll(',', '.');

  if (!RegExp(r'^-?\d+(\.\d+)?$').hasMatch(normalizado)) {
    print('Valor inválido: use apenas números, com vírgula ou ponto '
        'para os centavos e sem separador de milhar.');
    return null;
  }

  final valor = double.tryParse(normalizado);
  if (valor == null || !valor.isFinite) {
    print('Valor inválido: digite um número.');
    return null;
  }
  if (valor <= 0) {
    print('Valor inválido: deve ser maior que zero.');
    return null;
  }
  if (RegExp(r'\.\d{3,}$').hasMatch(normalizado)) {
    print('Valor inválido: use no máximo duas casas decimais.');
    return null;
  }
  if (valor >= valorMaximo) {
    print('Valor inválido: deve ser menor que 10000000000.');
    return null;
  }
  return valor;
}

int? validarQuilometragem(String texto) {
  final km = int.tryParse(texto);
  if (km == null) {
    print('Quilometragem inválida: digite um número inteiro.');
    return null;
  }
  if (km < 0) {
    print('Quilometragem inválida: não pode ser negativa.');
    return null;
  }
  return km;
}

int? validarId(String texto) {
  final id = int.tryParse(texto);
  if (id == null || id <= 0) {
    print('ID inválido: digite um número inteiro positivo.');
    return null;
  }
  return id;
}
