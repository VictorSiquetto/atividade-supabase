import 'package:supabase/supabase.dart';

const String tabela = 'veiculos';

Future<Map<String, dynamic>> cadastrarVeiculo(
  SupabaseClient cliente,
  String marca,
  String modelo,
  int ano,
  double valor,
  int quilometragem,
) async {
  final registro = await cliente
      .from(tabela)
      .insert({
        'marca': marca,
        'modelo': modelo,
        'ano': ano,
        'valor': valor,
        'quilometragem': quilometragem,
      })
      .select()
      .single();

  return registro;
}

Future<List<Map<String, dynamic>>> listarVeiculos(
    SupabaseClient cliente) async {
  final registros =
      await cliente.from(tabela).select().order('id', ascending: true);

  return registros;
}

Future<Map<String, dynamic>?> atualizarVeiculo(
  SupabaseClient cliente,
  int id,
  String marca,
  String modelo,
  int ano,
  double valor,
  int quilometragem,
) async {
  final registros = await cliente
      .from(tabela)
      .update({
        'marca': marca,
        'modelo': modelo,
        'ano': ano,
        'valor': valor,
        'quilometragem': quilometragem,
      })
      .eq('id', id)
      .select();

  if (registros.isEmpty) return null;
  return registros.first;
}

Future<Map<String, dynamic>?> excluirVeiculo(
    SupabaseClient cliente, int id) async {
  final registros = await cliente.from(tabela).delete().eq('id', id).select();

  if (registros.isEmpty) return null;
  return registros.first;
}
