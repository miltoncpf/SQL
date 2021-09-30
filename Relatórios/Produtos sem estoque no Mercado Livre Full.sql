
SELECT 
	PGE.IDSUBPRODUTO,
	PG.DESCRRESPRODUTO,
	PPP.VALPRECOVAREJO,
	ESTOQUE_DISPONIVEL
FROM 
	PRODUTO_GRADE_ECOMMERCE PGE INNER JOIN ( --JUNTANDO O ESTOQUE DOS PRODUTOS A TABELA PRODUTO_GRADE_ECOMMERCE 
		SELECT IDSUBPRODUTO, SUM(QTDATUALESTOQUE) ESTOQUE_DISPONIVEL
		FROM ESTOQUE_SALDO_ATUAL WHERE IDLOCALESTOQUE IN (1, 21, 31)
		GROUP BY IDSUBPRODUTO) ESTOQUE ON PGE.IDSUBPRODUTO = ESTOQUE.IDSUBPRODUTO, 
	PRODUTO_GRADE PG,
	POLITICA_PRECO_PRODUTO PPP,
	ESTOQUE_SALDO_ATUAL ESA
WHERE
	PGE.IDPRODUTO = ESA.IDPRODUTO AND 
	PGE.IDSUBPRODUTO = ESA.IDSUBPRODUTO AND
	PGE.IDPRODUTO = PG.IDPRODUTO  AND
	PGE.IDSUBPRODUTO = PG.IDSUBPRODUTO AND
	ESA.IDPRODUTO = PG.IDPRODUTO AND
	PGE.IDSUBPRODUTO = ESA.IDSUBPRODUTO AND
	PPP.IDSUBPRODUTO = ESA.IDSUBPRODUTO AND
	PPP.IDSUBPRODUTO = PG.IDSUBPRODUTO AND 
	PPP.IDSUBPRODUTO = PGE.IDSUBPRODUTO AND
	PPP.IDEMPRESA = 1 AND
	PPP.VALPRECOVAREJO > 0 AND
	IDCONFIGECOMMERCE = 2 AND 
	DESCRICAO IS NOT NULL AND
	PGE.IDSUBPRODUTO NOT IN( --LISTA OS PRODUTOS QUE N�O TEM ESTOQUE NOS LOCAIS 19-MERCADO LIVRE FULL E 26-EM TRANSITO ML FULL
					SELECT IDSUBPRODUTO FROM ESTOQUE_SALDO_ATUAL 
					WHERE IDLOCALESTOQUE IN (19,26) AND QTDATUALESTOQUE > 0 
					GROUP BY IDSUBPRODUTO ) AND
	PGE.IDSUBPRODUTO IN( --LISTA OS PRODUTOS QUE TIVERAM PELO MENOS 1 VENDAS VIA MERCADO LIVRE FULL
					SELECT IDSUBPRODUTO FROM ESTOQUE_ANALITICO 
					WHERE IDOPERACAO = 1097 GROUP BY IDSUBPRODUTO )
GROUP BY
	PGE.IDSUBPRODUTO,
	PG.DESCRRESPRODUTO,
	PPP.VALPRECOVAREJO,
	ESTOQUE.ESTOQUE_DISPONIVEL