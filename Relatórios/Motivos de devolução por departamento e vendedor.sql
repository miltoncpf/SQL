/*--testes
SELECT * FROM NOTAS WHERE NUMNOTA = 202868
SELECT * FROM DEVOLUCAO_LOGISTICA_MOVIMENTO WHERE IDPLANILHADOCORI = 7354656
SELECT * FROM MOTIVO_DEVOLUCAO_LOGISTICA mdl 
SELECT * FROM ESTOQUE_ANALITICO WHERE IDPLANILHA = 7248843 AND IDVENDEDOR IS NOT NULL
SELECT * FROM NOTAS_ENTRADA_SAIDA WHERE IDPLANILHA = 7248843
SELECT * FROM CLIENTE_FORNECEDOR WHERE IDCLIFOR = 80
SELECT * FROM DEVOLUCAO_HISTORICO_LOG_MOV dhlm WHERE IDPLANILHA = 7390134*/

SELECT 
	*
FROM
	(SELECT
		IDPLANILHA,
		NUMNOTA,
		IDCLIFORENTREGA,
		CLIENTE,
		IDSUBPRODUTO,
		IDVENDEDOR VENDEDOR,
		NOME,
		IDDEPARTAMENTO,
		DESCRDEPARTAMENTO
	FROM	
		(SELECT 
			NES.IDPLANILHA,
			NF.NUMNOTA,
			NES.IDEMPRESA,
			NES.IDCLIFORENTREGA,
			CF2.NOME CLIENTE,
			NES.OBSNOTA,
			NES.IDOPERACAO,
			EA.IDVENDEDOR,
			EA.IDSUBPRODUTO
		FROM
			NOTAS_ENTRADA_SAIDA NES,
			ESTOQUE_ANALITICO EA,
			NOTAS NF,
			CLIENTE_FORNECEDOR CF2
		WHERE
			NES.IDEMPRESA = EA.IDEMPRESA AND
			NES.IDPLANILHA = EA.IDPLANILHA AND
			NES.IDPLANILHA = NF.IDPLANILHA AND
			NES.IDEMPRESA = NF.IDEMPRESA AND
			NES.IDCLIFORENTREGA = CF2.IDCLIFOR AND
			NES.IDOPERACAO IN (31, 39, 35, 30, 40, 36) AND
			NES.DTMOVIMENTO BETWEEN :RA_DTINI AND :RA_DTFIM) RESUMO_DEV LEFT JOIN
			
		(SELECT
			CF.IDCLIFOR,
			CF.NOME,
			DEP.IDDEPARTAMENTO,
			DEP.DESCRDEPARTAMENTO 
		FROM
			DEPARTAMENTOS DEP,
			CLIENTE_FORNECEDOR CF
		WHERE
			DEP.IDDEPARTAMENTO = CF.IDDEPARTAMENTO AND
			CF.TIPOCADASTRO = 'V') VENDEDOR ON RESUMO_DEV.IDVENDEDOR = VENDEDOR.IDCLIFOR) MAIN
	LEFT OUTER JOIN
		(SELECT
			DLM.IDPLANILHA,
			DLM.IDMOTIVO,
			MDL.DESCRMOTIVO,
			DLM.IDSUBPRODUTO,
			DLM.OBSERVACAO
		FROM
			DEVOLUCAO_LOGISTICA_MOVIMENTO DLM,
			MOTIVO_DEVOLUCAO_LOGISTICA MDL
		WHERE
			DLM.IDMOTIVO = MDL.IDMOTIVO) MOTIVO ON MAIN.IDPLANILHA = MOTIVO.IDPLANILHA AND 
												   MAIN.IDSUBPRODUTO = MOTIVO.IDSUBPRODUTO 
		
