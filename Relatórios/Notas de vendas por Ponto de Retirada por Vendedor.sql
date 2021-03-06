/*SELECT * FROM ESTOQUE_ANALITICO ea WHERE IDPLANILHA = 7798840
SELECT * FROM CLIENTE_FORNECEDOR cf WHERE IDCLIFOR = 5006553
*/
SELECT
	LR.IDLOCALRETIRADA,
	LR.DESCRLOCALRETIRADA,
	EA.IDVENDEDOR,
	CF.NOME,
	SUM(VALTOTLIQUIDO) VALORTOTAL,
	COUNT(DISTINCT IDPLANILHA) TOTALNOTAS,
	COUNT(EA.IDSUBPRODUTO) TOTALPRODUTOS
FROM
	ESTOQUE_ANALITICO EA LEFT JOIN LOCAL_RETIRADA LR ON
	EA.IDLOCALRETIRADA = LR.IDLOCALRETIRADA LEFT JOIN 
	CLIENTE_FORNECEDOR CF ON EA.IDVENDEDOR = CF.IDCLIFOR 
WHERE
	EA.IDOPERACAO IN (1001, 3001, 1300, 1150) AND
	EA.IDVENDEDOR = :RA_VENDEDOR AND
	EA.DTMOVIMENTO BETWEEN :RA_DTINI AND :RA_DTFIM
GROUP BY
	LR.IDLOCALRETIRADA,
	LR.DESCRLOCALRETIRADA,
	EA.IDVENDEDOR,
	CF.NOME
ORDER BY
	CF.NOME