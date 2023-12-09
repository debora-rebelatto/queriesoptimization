# Banco de Dados II - 2023/2

# Relatório Otimização de Queries

Aluna: Débora Rebelatto

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

Para isso, utilizamos o Dojo-SQL com 20.000 tuplas.

| **Query** | **Tempo de Planejamento (ms)** | **Tempo de Execução (ms)** |
| --------- | ------------------------------ | -------------------------- |
| Query 1   | 331.927 ms                     | 57.669 ms                  |
| Query 2   | 691.619 ms                     | 274.008 ms                 |
| Query 3   | 199.448 ms                     | 78.898 ms                  |
| Query 4   | 191.976 ms                     | 73.981 ms                  |
| Query 5   | 214.081 ms                     | 76.328 ms                  |
| Query 6   | 398.698 ms                     | 246.799 ms                 |
| Query 7   | 582.382 ms                     | 269.430 ms                 |
| Query 8   | 284.178 ms                     | 7601.813 ms                |
| Query 9   | 168.346 ms                     | 156.394 ms                 |
| Query 10  | 240.525 ms                     | 151.855 ms                 |

Ordenado por tempo de Execução:
| **Query** | **Tempo de Planejamento (ms)** | **Tempo de Execução (ms)** |
| --------- | ------------------------------ | -------------------------- |
| Query 8 | 284.178 ms | 7601.813 ms |
| Query 2 | 691.619 ms | 274.008 ms |
| Query 7 | 582.382 ms | 269.430 ms |
| Query 6 | 398.698 ms | 246.799 ms |
| Query 10 | 240.525 ms | 151.855 ms |
| Query 9 | 168.346 ms | 156.394 ms |
| Query 3 | 199.448 ms | 78.898 ms |
| Query 5 | 214.081 ms | 76.328 ms |
| Query 4 | 191.976 ms | 73.981 ms |
| Query 1 | 331.927 ms | 57.669 ms |

Irei levar em conta apenas o tempo de execução para a análise de otimização, pois o tempo de planejamento não é algo que podemos otimizar diretamente, e sim indiretamente através da otimização da query. Então, temos que as consultas mais lentas são: 8, 2 e 7.

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

# Query 7

**Descrição:**
Listar os nomes dos departamentos com o total de salários pagos (sliding windows function)

```sql
EXPLAIN ANALYZE SELECT d.dep_id, d.nome AS departamento, SUM(e.salario) AS "Salario total"
FROM departamentos d
LEFT OUTER JOIN empregados e ON d.dep_id = e.dep_id
GROUP BY d.dep_id, d.nome;
```

| **Query** | **Tempo de Planejamento (ms)** | **Tempo de Execução (ms)** |
| --------- | ------------------------------ | -------------------------- |
| 1         | 582.382                        | 269.430                    |
| 2         | 0.487                          | 11.590                     |
| 3         | 0.482                          | 14.615                     |
| 4         | 0.501                          | 10.677                     |
| 5         | 0.436                          | 10.649                     |

|                            | **Média** | **Desvio Padrão** |
| -------------------------- | --------- | ----------------- |
| Tempo de Planejamento (ms) | 116.458   | 232.984           |
| Tempo de Execução (ms)     | 63.392    | 86.462            |

**Otimizando a Query**:

# Query 2

**Descrição:**

Listar o maior salario de cada departamento (usa o group by)]

```sql
EXPLAIN ANALYZE
SELECT d.dep_id as x, max(salario) as y
FROM departamentos d JOIN empregados e
ON e.dep_id = d.dep_id
GROUP BY d.dep_id;
```

| **Query** | **Tempo de Planejamento (ms)** | **Tempo de Execução (ms)** |
| --------- | ------------------------------ | -------------------------- |
| 1         | 691.619                        | 274.008                    |
| 2         | 0.305                          | 7.058                      |
| 3         | 0.383                          | 6.973                      |
| 4         | 0.308                          | 6.931                      |
| 5         | 0.306                          | 6.980                      |

|                            | **Média** | **Desvio Padrão** |
| -------------------------- | --------- | ----------------- |
| Tempo de Planejamento (ms) | 138.385   | 282.124           |
| Tempo de Execução (ms)     | 60.590    | 91.025            |

**Otimizando a Query**:

Crie um index:

```sql
CREATE INDEX dep_id_index ON departamentos (dep_id);
```

# Query 8

**Descrição:**
Listar os nomes dos colaboradores com salario maior que a média do seu departamento (dica: usar subconsultas);

```sql
EXPLAIN ANALYZE select emp_id,nome, dep_id, salario
from empregados e1
where salario > (select avg(salario)
from empregados e2
where e1.dep_id = e2.dep_id);
```

| **Query** | **Tempo de Planejamento (ms)** | **Tempo de Execução (ms)** |
| --------- | ------------------------------ | -------------------------- |
| 1         | 258.138                        | 85.826                     |
| 2         | 0.342                          | 7.024                      |
| 3         | 0.539                          | 17.619                     |
| 4         | 0.512                          | 12.550                     |
| 5         | 0.344                          | 7.457                      |

|                            | **Média** | **Desvio Padrão** |
| -------------------------- | --------- | ----------------- |
| Tempo de Planejamento (ms) | 51.975    | 102.935           |
| Tempo de Execução (ms)     | 26.495    | 36.598            |

**Otimizando a Query**:

```sql
EXPLAIN ANALYSE SELECT e1.emp_id, e1.nome, e1.dep_id, e1.salario
FROM empregados e1
JOIN (
    SELECT dep_id, AVG(salario) AS salario_medio
    FROM empregados
    GROUP BY dep_id
) s ON e1.dep_id = s.dep_id
WHERE e1.salario > s.salario_medio;
```

```sql
                                                           QUERY PLAN
--------------------------------------------------------------------------------------------------------------------------------
 Hash Join  (cost=435.15..824.91 rows=6667 width=19) (actual time=28.547..34.940 rows=9958 loops=1)
   Hash Cond: (e1.dep_id = empregados.dep_id)
   Join Filter: ((e1.salario)::numeric > (avg(empregados.salario)))
   Rows Removed by Join Filter: 10042
   ->  Seq Scan on empregados e1  (cost=0.00..334.00 rows=20000 width=19) (actual time=15.589..16.586 rows=20000 loops=1)
   ->  Hash  (cost=434.74..434.74 rows=33 width=36) (actual time=12.931..12.932 rows=33 loops=1)
         Buckets: 1024  Batches: 1  Memory Usage: 10kB
         ->  HashAggregate  (cost=434.00..434.41 rows=33 width=36) (actual time=12.907..12.920 rows=33 loops=1)
               Group Key: empregados.dep_id
               Batches: 1  Memory Usage: 24kB
               ->  Seq Scan on empregados  (cost=0.00..334.00 rows=20000 width=8) (actual time=0.007..5.307 rows=20000 loops=1)
 Planning Time: 212.886 ms
 Execution Time: 43.724 ms
(13 rows)
```

| **Query** | **Tempo de Planejamento (ms)** | **Tempo de Execução (ms)** |
| --------- | ------------------------------ | -------------------------- |
| 1         | 212.886                        | 43.724                     |
| 2         | 0.415                          | 11.368                     |
| 3         | 0.404                          | 11.286                     |
| 4         | 0.404                          | 11.286                     |
| 5         | 0.435                          | 11.518                     |
| 6         | 0.435                          | 11.518                     |
| 7         | 0.403                          | 11.195                     |

|                            | **Média** | **Desvio Padrão** |
| -------------------------- | --------- | ----------------- |
| Tempo de Planejamento (ms) | 35.575    | 76.084            |
| Tempo de Execução (ms)     | 13.974    | 14.598            |

A partir dos valores de média entre os tempos de Execução, percebemos que as alterações feitas permitiram uma redução de 52.74% no tempo, uma diferença de 12,52ms entre as execuções.
