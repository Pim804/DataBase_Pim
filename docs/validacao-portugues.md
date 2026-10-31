# Validacao da renomeacao ? 31/10/2026

Verificacoes executadas em PostgreSQL 18 isolado, na porta 55439, com bases ficticias. O banco operacional nao foi alterado.

- Instalacao limpa pelo SQL idempotente e reaplicacao sem erros.
- Atualizacao do esquema anterior com usuario, categoria, peca e movimentacao existentes.
- Atualizacao com antigas views auxiliares em portugues presentes.
- Preservacao do cadastro, saldo e historico.
- Consultas nas duas views e nas funcoes de resumo e totais.
- Trigger da data de atualizacao, bloqueio de alteracao do historico e rejeicao de saldo negativo.
- Carga de demonstracao executada duas vezes.
- Reversao para AddStockDatabaseObjects e reaplicacao, preservando os dados.
- Leitura com relacionamentos e gravacao de peca pelo DbContext real do site, dentro de uma transacao revertida.
- Consultas de usuarios, perfis, comunicados e movimentacoes pelo Entity Framework.
- Modelo EF sem alteracoes pendentes.
- Compilacao da solucao completa: zero erros e zero avisos.
- Quatro testes existentes aprovados.

As migrations anteriores foram preservadas; a traducao e feita pela nova migration TraduzirNomesBanco.
