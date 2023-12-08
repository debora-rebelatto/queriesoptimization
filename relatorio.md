# Banco de Dados II - 2023/2

# Relatório Otimização de Queries

Aluna: Débora Rebelatto

- O que é otimização de queries?
- Porque otimizar queries?
- Como o postgres otimiza queries?
- O que é um plano de execução?
- Como ler um plano de execução?
- Como otimizar queries?
- Quais queries foram utilizadas para o relatório?
- Quais foram os resultados obtidos?
- Como foi feita a análise dos resultados?
- Quais foram as conclusões obtidas?

## Introdução

Otimizar queries é importante para que o banco de dados tenha um melhor desempenho, pois quanto mais rápido as queries são executadas, mais rápido o banco de dados responde ao usuário.

## Objetivo

Neste relatório, iremos analisar o desempenho de algumas queries e tentar otimizá-las para que elas sejam executadas mais rapidamente.

## Queries

As queries utilizadas no seguinte relatório foram feitas com base em um trabalho da disciplina de Banco de Dados II, onde o objetivo era criar um banco de dados para uma empresa fictícia e realizar consultas sobre o mesmo. E podem ser encontradas no arquivo `queries.sql` deste repositório.

## O comando EXPLAIN ANALYZE

O postgres tenta encontrar a melhor forma de otimizar uma query, no entanto, muitas vezes o problema pode se encontrar em como a query foi escrita, e não no plano de execução. Por isso, é importante analisar o plano de execução para entender o que está acontecendo e como podemos otimizar a query.

O `ANALYZE` é uma opção do comando `EXPLAIN` que nos permite executar a query e ver os resultados reais de cada nó do plano de execução, juntamente com as estimativas do planner, assim tendo valores mais confiáveis para analisar o desempenho da query.

## Resultados da primeira execução

A seguir temos os resultados da primeira execução do comando de `EXPLAIN ANALYZE` para cada uma das 10 consultas fornecidas, onde analisamos o tempo de planejamento e de execução para cada uma limpando o buffer antes para evitar que o cache do sistema influencie nos resultados.

Ordenando pelo tempo de total de forma decrescente, podemos facilitar a visualização sobre quais consultas são mais lentas para selecionar as três mais lentas para a análise de otimização.

| Query    | Tempo de Planejamento (ms) | Tempo de Execução (ms) |
| -------- | -------------------------- | ---------------------- |
| Query 2  | 60.442                     | 35.730                 |
| Query 9  | 85.155                     | 32.442                 |
| Query 3  | 160.001                    | 32.058                 |
| Query 4  | 60.226                     | 24.391                 |
| Query 5  | 60.297                     | 24.311                 |
| Query 1  | 27.843                     | 24.542                 |
| Query 6  | 118.544                    | 21.278                 |
| Query 7  | 52.424                     | 21.002                 |
| Query 8  | 52.617                     | 21.252                 |
| Query 10 | 52.263                     | 20.959                 |

Irei levar em conta apenas o tempo de execução para a análise de otimização, pois o tempo de planejamento não é algo que podemos otimizar diretamente, e sim indiretamente através da otimização da query. Então, temos que as consultas mais lentas são: 2, 9 e 3

O resultado para a saída do comando de `EXPLAIN ANALYZE` pode ser encontrado na pasta `resultados` deste repositório.

Os cálculos para média e desvio não serão demonstrados, porém eles podem ser encontrados ao final de todas as tabelas de valores e foram obtidos a partir das seguintes fórmulas:

- Média: soma de todos os tempos dividido pelo número de execuções

  $$
  \frac{\sum_{i=1}^{n}x_i}{n}
  $$

- Desvio: raiz quadrada da soma de todos os tempos de menos a média elevado ao quadrado dividido pelo número de execuções

  $$
  \sqrt{\frac{\sum_{i=1}^{n}(x_i-\bar{x})^2}{n}}
  $$

## [Query 2]()

**Descrição:**

Encontre os empregados com salario maior ou igual a média do seu departamento. Deve ser reportado o salario do empregado e a média do departamento (dica: usar window function com subconsulta)

```sql
                                                         QUERY PLAN                                                          
-----------------------------------------------------------------------------------------------------------------------------
 HashAggregate  (cost=5.62..5.95 rows=33 width=8) (actual time=17.296..17.300 rows=31 loops=1)
   Group Key: d.dep_id
   Batches: 1  Memory Usage: 24kB
   ->  Hash Join  (cost=1.74..5.12 rows=100 width=8) (actual time=17.246..17.270 rows=98 loops=1)
         Hash Cond: (e.dep_id = d.dep_id)
         ->  Seq Scan on empregados e  (cost=0.00..2.00 rows=100 width=8) (actual time=7.075..7.081 rows=100 loops=1)
         ->  Hash  (cost=1.33..1.33 rows=33 width=4) (actual time=10.147..10.148 rows=33 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 10kB
               ->  Seq Scan on departamentos d  (cost=0.00..1.33 rows=33 width=4) (actual time=0.270..0.276 rows=33 loops=1)
 Planning Time: 195.144 ms
 Execution Time: 48.203 ms
(11 rows)
```

```sql
EXPLAIN ANALYZE
SELECT d.dep_id as x, max(salario) as y
FROM departamentos d JOIN empregados e
ON e.dep_id = d.dep_id
GROUP BY d.dep_id;
```


| Query | Planning Time (ms) | Execution Time (ms) |
|-------|---------------------|---------------------|
| 1     | 195.144              | 0.174               |
| 2     | 0.286               | 0.174               |
| 2     | 0.279               | 0.176               |
| 4     | 0.286               | 0.178               |
| 5     | 0.304               | 0.175               |


## [Query 9]()

Descrição:
Faça uma consulta capaz de listar os dep_id, nome, salario, e as médias de cada departamento utilizando o windows function;

```sql
EXPLAIN ANALYZE SELECT emp_id, nome, dep_id, salario, AVG(salario)
OVER (PARTITION BY dep_id)
FROM empregados;
```

| Query | Planning Time (ms) | Execution Time (ms) |
|-------|---------------------|----------------------|
| 1 | 290.809 | 317.745 |
| 2 | 0.276 | 0.211 |
| 3 | 0.247 | 0.210 |
| 4 | 0.363 | 0.207 |
| 5 | 0.502 | 0.377 |

## [Query 3](./resultados/output8.txt)

Descrição:
Listar o dep_id, nome e o salario do funcionario com maior salario dentro de cada departamento (usar o with)

```sql
EXPLAIN ANALYZE SELECT dep_id, nome, salario
FROM empregados
WHERE (dep_id,salario)
IN (SELECT dep_id, MAX(salario)
FROM empregados
GROUP BY dep_id);
```

|Query| Planning Time (ms) | Execution Time (ms) |
|---|---|
|1| 227.560 | 49.098 |
| 2|0.316 | 0.179 |
| 3|0.610 | 0.343 |
| 4|0.345 | 0.186 |
| 5|0.320 | 0.180 |
