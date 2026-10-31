\set ON_ERROR_STOP on
BEGIN;
SELECT pg_advisory_xact_lock(780130);
DO $$
DECLARE
 actor uuid;
 cat integer;
 supplier integer;
 part integer;
 i integer;
 j integer;
 balance integer;
 category_names text[] := ARRAY['Fixadores','Rolamentos','Correias','Filtros','Vedacoes','Ferramentas','Eletrica','Hidraulica','Lubrificantes','Transmissao'];
 item_names text[] := ARRAY['Parafuso sextavado','Rolamento blindado','Correia industrial','Filtro de oleo','Anel de vedacao','Chave combinada','Rele de comando','Conexao hidraulica','Graxa industrial','Engrenagem'];
BEGIN
 SELECT "Id" INTO actor FROM "AspNetUsers" WHERE "IsActive" ORDER BY "CreatedAtUtc", "Id" LIMIT 1;
 IF actor IS NULL THEN RAISE EXCEPTION 'Crie um usuario ativo pela aplicacao antes de executar a carga.'; END IF;
 FOR i IN 1..10 LOOP
  INSERT INTO "Categories" ("Name","Description","IsActive","CreatedAtUtc")
  VALUES ('Demo - ' || category_names[i], 'Categoria ficticia para demonstracao do estoque.',true,CURRENT_TIMESTAMP - interval '60 days')
  ON CONFLICT ("Name") DO NOTHING;
 END LOOP;
 FOR i IN 1..8 LOOP
  INSERT INTO "Suppliers" ("Name","TaxId","Phone","Email","Address","IsActive")
  SELECT 'Fornecedor Demo ' || i,NULL,NULL,'fornecedor' || i || '@example.invalid','Endereco ficticio para demonstracao',true
  WHERE NOT EXISTS (SELECT 1 FROM "Suppliers" WHERE "Email" = 'fornecedor' || i || '@example.invalid');
 END LOOP;
 FOR i IN 1..100 LOOP
  j := ((i-1) % 10)+1;
  SELECT "Id" INTO cat FROM "Categories" WHERE "Name" = 'Demo - ' || category_names[j];
  SELECT "Id" INTO supplier FROM "Suppliers" WHERE "Email" = 'fornecedor' || (((i-1)%8)+1) || '@example.invalid' ORDER BY "Id" LIMIT 1;
  balance := CASE WHEN i%10=0 THEN 0 WHEN i%5=0 THEN 5 ELSE 20+(i%50) END;
  part := NULL;
  INSERT INTO "Parts" ("Code","Name","Description","CategoryId","SupplierId","StockQuantity","MinimumStock","UnitPrice","WarehouseLocation","IsActive","CreatedAtUtc","UpdatedAtUtc","Version")
  VALUES ('DEMO-' || lpad(i::text,4,'0'),item_names[j] || ' - modelo ' || (((i-1)/10)+1), 'Peca ficticia para demonstracao e testes.',cat,supplier,balance,10,(5+i*3.75)::numeric(12,2),'Corredor ' || j || ' / Prateleira ' || (((i-1)/10)+1),i%17<>0,CURRENT_TIMESTAMP-interval '60 days',CURRENT_TIMESTAMP,1)
  ON CONFLICT ("Code") DO NOTHING RETURNING "Id" INTO part;
  IF part IS NOT NULL THEN
   INSERT INTO "StockMovements" ("PartId","Type","Quantity","PreviousBalance","NewBalance","Notes","OccurredAtUtc","UserId") VALUES
   (part,'Entry',balance+15,0,balance+15,'DEMO: recebimento inicial',CURRENT_TIMESTAMP-interval '45 days'+i*interval '1 minute',actor),
   (part,'Exit',10,balance+15,balance+5,'DEMO: consumo na manutencao',CURRENT_TIMESTAMP-interval '20 days'+i*interval '1 minute',actor),
   (part,'Exit',5,balance+5,balance,'DEMO: retirada para operacao',CURRENT_TIMESTAMP-interval '2 days'+i*interval '1 minute',actor);
  END IF;
 END LOOP;
 FOR i IN 1..6 LOOP
  INSERT INTO "Announcements" ("Title","Content","CreatedAtUtc","PublishedAtUtc","IsPublished","IsArchived","AuthorId")
  SELECT 'DEMO - ' || (ARRAY['Conferencia de estoque','Organizacao do deposito','Reposicao de itens','Uso de equipamentos','Inventario mensal','Rotina de recebimento'])[i],
  'Comunicado ficticio para demonstracao. Confira os registros e siga os procedimentos internos de estoque.',CURRENT_TIMESTAMP-i*interval '1 day',CASE WHEN i=6 THEN NULL ELSE CURRENT_TIMESTAMP-i*interval '1 day' END,i<>6,i=5,actor
  WHERE NOT EXISTS (SELECT 1 FROM "Announcements" WHERE "Title" = 'DEMO - ' || (ARRAY['Conferencia de estoque','Organizacao do deposito','Reposicao de itens','Uso de equipamentos','Inventario mensal','Rotina de recebimento'])[i]);
 END LOOP;
 IF EXISTS (
  SELECT 1 FROM "Parts" p JOIN LATERAL (SELECT "NewBalance" FROM "StockMovements" m WHERE m."PartId"=p."Id" ORDER BY "OccurredAtUtc" DESC,"Id" DESC LIMIT 1) m ON true
  WHERE p."Code" LIKE 'DEMO-%' AND p."StockQuantity"<>m."NewBalance"
 ) THEN RAISE EXCEPTION 'Saldo da peca divergente do historico.'; END IF;
END $$;
COMMIT;
SELECT 'categorias' AS entidade, count(*) FROM "Categories" WHERE "Name" LIKE 'Demo - %'
UNION ALL SELECT 'fornecedores',count(*) FROM "Suppliers" WHERE "Email" LIKE '%@example.invalid'
UNION ALL SELECT 'pecas',count(*) FROM "Parts" WHERE "Code" LIKE 'DEMO-%'
UNION ALL SELECT 'movimentacoes',count(*) FROM "StockMovements" WHERE "Notes" LIKE 'DEMO:%'
UNION ALL SELECT 'comunicados',count(*) FROM "Announcements" WHERE "Title" LIKE 'DEMO - %';
