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

Foi utilizado o dataset fornecido no repositório do Dojo-SQL com 20.000 para realizar os testes de otimização. Para encontrar as queries mais lentas, iremos executar cada uma delas 5 vezes e tirar a média dos tempos de planejamento e execução para cada uma. Ordenamos a saída de forma decrescente para facilitar a visualização sobre quais consultas são mais lentas para selecionar as três mais lentas para a análise de otimização.

| **Query** | **Média Planning Time (ms)** | **Média Execution Time (ms)** |
| --------- | ---------------------------- | ----------------------------- |
| 8         | 194.181                      | 20210.965                     |
| 6         | 240.118                      | 142.855                       |
| 1         | 344.514                      | 136.114                       |
| 2         | 277.056                      | 116.720                       |
| 4         | 198.352                      | 116.376                       |
| 5         | 187.177                      | 116.145                       |
| 7         | 184.350                      | 116.288                       |
| 3         | 190.267                      | 101.806                       |
| 9         | 167.627                      | 108.156                       |
| 10        | 184.397                      | 107.856                       |

Será levado em conta apenas o tempo de execução para a análise de otimização, pois o tempo de planejamento não é algo que podemos otimizar diretamente, e sim indiretamente através da otimização da query. Então, temos que as consultas mais lentas, em média, são: 8, 6 e 1.

## Query 1

**Descrição:**

Listar os empregados (nomes) que tem salário maior que seu chefe (usar o join)

```sql
EXPLAIN ANALYZE
SELECT e.nome as "empregado", e2.nome as "chefe" , e.salario as "empsal" , e2.salario as "chefsal"
FROM empregados e
JOIN empregados e2 ON e.supervisor_id = e2.emp_id
WHERE e2.salario < e.salario;
```

| **Query** | **Planning Time (ms)** | **Execution Time (ms)** |
| --------- | ---------------------- | ----------------------- |
| 1         | 307.795                | 178.536                 |
| 2         | 0.345                  | 10.060                  |
| 3         | 0.357                  | 10.399                  |
| 4         | 0.354                  | 17.137                  |
| 5         | 0.354                  | 10.088                  |

### Planejamento (ms)

- Média: 61.841 ms
- Desvio Padrão: 206.392 ms

### Execução (ms)

- Média: 45.244 ms
- Desvio Padrão: 57.253 ms

```sql
                                                          QUERY PLAN
-------------------------------------------------------------------------------------------------------------------------------
 Hash Join  (cost=584.00..1243.00 rows=6667 width=22) (actual time=142.709..147.534 rows=9409 loops=1)
   Hash Cond: (e.supervisor_id = e2.emp_id)
   Join Filter: (e2.salario < e.salario)
   Rows Removed by Join Filter: 10591
   ->  Seq Scan on empregados e  (cost=0.00..334.00 rows=20000 width=15) (actual time=19.619..20.656 rows=20000 loops=1)
   ->  Hash  (cost=334.00..334.00 rows=20000 width=15) (actual time=122.923..122.924 rows=20000 loops=1)
         Buckets: 32768  Batches: 1  Memory Usage: 1218kB
         ->  Seq Scan on empregados e2  (cost=0.00..334.00 rows=20000 width=15) (actual time=0.009..96.151 rows=20000 loops=1)
 Planning Time: 307.795 ms
 Execution Time: 178.536 ms
(10 rows)
```

**Otimização da query**

```sql
CREATE INDEX idx_empregados_emp_id ON empregados (emp_id);
CREATE INDEX idx_empregados_supervisor_id_salario ON empregados (supervisor_id, salario);
```

| Planning Time | Execution Time |
| ------------- | -------------- |
| 503.566 ms    | 115.228 ms     |
| 0.668 ms      | 11.800 ms      |
| 0.613 ms      | 9.151 ms       |
| 0.614 ms      | 9.099 ms       |
| 0.604 ms      | 9.003 ms       |

### Planejamento (ms)

- Média: 101.2134 ms
- Desvio Padrão: 127.7033 ms

### Execução (ms)

- Média: 30.6562 ms
- Desvio Padrão: 38.3963 ms

```sql
                                                                     QUERY PLAN
----------------------------------------------------------------------------------------------------------------------------------------------------
 Nested Loop  (cost=0.30..1172.76 rows=6667 width=22) (actual time=96.850..106.488 rows=9409 loops=1)
   ->  Seq Scan on empregados e  (cost=0.00..334.00 rows=20000 width=15) (actual time=29.013..40.519 rows=20000 loops=1)
   ->  Memoize  (cost=0.30..0.36 rows=1 width=15) (actual time=0.003..0.003 rows=0 loops=20000)
         Cache Key: e.salario, e.supervisor_id
         Cache Mode: binary
         Hits: 19108  Misses: 892  Evictions: 0  Overflows: 0  Memory Usage: 83kB
         ->  Index Scan using idx_empregados_emp_id on empregados e2  (cost=0.29..0.35 rows=1 width=15) (actual time=0.066..0.066 rows=0 loops=892)
               Index Cond: (emp_id = e.supervisor_id)
               Filter: (salario < e.salario)
               Rows Removed by Filter: 1
 Planning Time: 503.566 ms
 Execution Time: 115.228 ms
(12 rows)
```

Sem alterações na query, apenas com a criação de índices, já conseguimos uma melhora significativa no tempo de execução.
Apesar do tempo no Nested Loop ainda ser alto, a média geral de tempo da query foi reduzida o que já é um bom resultado.

## Query 6

**Descrição:**

Listar os empregados que não possue o seu chefe no mesmo departamento/

```sql
EXPLAIN ANALYZE select e1.nome, e1.dep_id from empregados e1 join
empregados e2 on e1.supervisor_id=e2.emp_id
where e1.dep_id!=e2.dep_id;
```

### Tempo de Planejamento e Execução

| Execução | Planning Time | Execution Time |
| -------- | ------------- | -------------- |
| 1        | 1663.542 ms   | 733.195 ms     |
| 2        | 0.443 ms      | 11.909 ms      |
| 3        | 0.573 ms      | 24.900 ms      |
| 4        | 0.554 ms      | 22.959 ms      |
| 5        | 0.567 ms      | 23.572 ms      |

### Planejamento (ms)

- Média: 767.1358 ms
- Desvio Padrão: 696.8528 ms

### Execução (ms)

- Média: 16.781 ms
- Desvio Padrão: 8.9797 ms

```sql
                                                          QUERY PLAN
------------------------------------------------------------------------------------------------------------------------------
 Hash Join  (cost=584.00..1243.00 rows=19393 width=11) (actual time=87.019..91.961 rows=19402 loops=1)
   Hash Cond: (e1.supervisor_id = e2.emp_id)
   Join Filter: (e1.dep_id <> e2.dep_id)
   Rows Removed by Join Filter: 598
   ->  Seq Scan on empregados e1  (cost=0.00..334.00 rows=20000 width=15) (actual time=19.617..20.613 rows=20000 loops=1)
   ->  Hash  (cost=334.00..334.00 rows=20000 width=8) (actual time=67.236..67.237 rows=20000 loops=1)
         Buckets: 32768  Batches: 1  Memory Usage: 1038kB
         ->  Seq Scan on empregados e2  (cost=0.00..334.00 rows=20000 width=8) (actual time=0.009..42.091 rows=20000 loops=1)
 Planning Time: 207.864 ms
 Execution Time: 100.965 ms
(10 rows)
```

O plano de consulta indicado mostra um custo alto devido à execução de duas varreduras sequenciais (Seq Scan) nas tabelas de empregados. É possível otimizar essa consulta criando índices apropriados para melhorar o desempenho.

```sql
CREATE INDEX idx_e1_supervisor_id ON empregados(supervisor_id);
CREATE INDEX idx_e2_dep_id ON empregados(dep_id);
CREATE INDEX idx_e2_emp_id ON empregados(emp_id);
```

| **Planejamento (ms)** | **Execução (ms)** |
| --------------------- | ----------------- |
| 187.652               | 196.599           |
| 12.598                | 13.377            |
| 9.551                 | 10.261            |
| 11.672                | 12.414            |
| 15.658                | 16.650            |

```sql
                                                                QUERY PLAN
-------------------------------------------------------------------------------------------------------------------------------------------
 Nested Loop  (cost=0.30..959.82 rows=19393 width=11) (actual time=75.127..187.652 rows=19402 loops=1)
   ->  Seq Scan on empregados e1  (cost=0.00..334.00 rows=20000 width=15) (actual time=75.078..179.466 rows=20000 loops=1)
   ->  Memoize  (cost=0.30..0.36 rows=1 width=8) (actual time=0.000..0.000 rows=1 loops=20000)
         Cache Key: e1.dep_id, e1.supervisor_id
         Cache Mode: binary
         Hits: 19668  Misses: 332  Evictions: 0  Overflows: 0  Memory Usage: 36kB
         ->  Index Scan using idx_e2_emp_id on empregados e2  (cost=0.29..0.35 rows=1 width=8) (actual time=0.001..0.001 rows=1 loops=332)
               Index Cond: (emp_id = e1.supervisor_id)
               Filter: (e1.dep_id <> dep_id)
               Rows Removed by Filter: 0
 Planning Time: 448.074 ms
 Execution Time: 196.599 ms
(12 rows)
```

```sql
EXPLAIN ANALYZE SELECT e1.nome, e1.dep_id
FROM empregados e1
LEFT JOIN empregados e2 ON e1.supervisor_id = e2.emp_id AND e1.dep_id <> e2.dep_id
WHERE e2.emp_id IS NOT NULL;
```

| Planejamento (ms) | Execução (ms) |
| ----------------- | ------------- |
| 336.746           | 73.970        |
| 0.683             | 25.207        |
| 0.671             | 11.280        |
| 0.642             | 11.669        |
| 0.511             | 9.692         |

```sql
                                                                QUERY PLAN
-------------------------------------------------------------------------------------------------------------------------------------------
 Nested Loop  (cost=0.30..960.73 rows=19393 width=11) (actual time=19.606..64.817 rows=19402 loops=1)
   ->  Seq Scan on empregados e1  (cost=0.00..334.00 rows=20000 width=15) (actual time=19.559..55.383 rows=20000 loops=1)
   ->  Memoize  (cost=0.30..0.36 rows=1 width=8) (actual time=0.000..0.000 rows=1 loops=20000)
         Cache Key: e1.dep_id, e1.supervisor_id
         Cache Mode: binary
         Hits: 19668  Misses: 332  Evictions: 0  Overflows: 0  Memory Usage: 36kB
         ->  Index Scan using idx_e2_emp_id on empregados e2  (cost=0.29..0.35 rows=1 width=8) (actual time=0.001..0.001 rows=1 loops=332)
               Index Cond: ((emp_id = e1.supervisor_id) AND (emp_id IS NOT NULL))
               Filter: (e1.dep_id <> dep_id)
               Rows Removed by Filter: 0
 Planning Time: 336.746 ms
 Execution Time: 73.970 ms
(12 rows)
```

## Query 5

**Descrição:**

Listar os departamentos com o número de colaboradores

```sql
EXPLAIN ANALYZE select d.nome, count(e.emp_id)
from departamentos d
join empregados e on d.dep_id=e.dep_id
group by d.nome;
```

```sql

                                                           QUERY PLAN
--------------------------------------------------------------------------------------------------------------------------------
 HashAggregate  (cost=710.74..710.95 rows=21 width=22) (actual time=87.298..87.302 rows=21 loops=1)
   Group Key: d.nome
   Batches: 1  Memory Usage: 24kB
   ->  Hash Join  (cost=1.74..610.74 rows=20000 width=18) (actual time=52.511..84.236 rows=19409 loops=1)
         Hash Cond: (e.dep_id = d.dep_id)
         ->  Seq Scan on empregados e  (cost=0.00..334.00 rows=20000 width=8) (actual time=19.544..48.100 rows=20000 loops=1)
         ->  Hash  (cost=1.33..1.33 rows=33 width=18) (actual time=32.950..32.951 rows=33 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 10kB
               ->  Seq Scan on departamentos d  (cost=0.00..1.33 rows=33 width=18) (actual time=13.807..13.813 rows=33 loops=1)
 Planning Time: 199.195 ms
 Execution Time: 105.015 ms
(11 rows)
```

| Execução | Planejamento (ms) | Execução (ms) |
| -------- | ----------------- | ------------- |
| 1        | 199.195           | 105.015       |
| 2        | 0.330             | 7.444         |
| 3        | 0.352             | 7.443         |
| 4        | 0.356             | 7.411         |
| 5        | 0.346             | 7.422         |

### Planejamento (ms)

- Média: 120.916 ms
- Desvio Padrão: 134.222 ms

### Execução (ms)

- Média: 26.7476 ms
- Desvio Padrão: 42.7815 ms

## Query 8

**Descrição:**
Listar os nomes dos colaboradores com salario maior que a média do seu departamento (dica: usar subconsultas);

```sql
EXPLAIN ANALYZE select emp_id,nome, dep_id, salario
from empregados e1
where salario > (select avg(salario)
from empregados e2
where e1.dep_id = e2.dep_id);
```

```sql
                                                          QUERY PLAN
-------------------------------------------------------------------------------------------------------------------------------
 Seq Scan on empregados e1  (cost=0.00..7710984.00 rows=6667 width=19) (actual time=1236.394..16445.748 rows=10013 loops=1)
   Filter: ((salario)::numeric > (SubPlan 1))
   Rows Removed by Filter: 9987
   SubPlan 1
     ->  Aggregate  (cost=385.52..385.53 rows=1 width=32) (actual time=0.761..0.761 rows=1 loops=20000)
           ->  Seq Scan on empregados e2  (cost=0.00..384.00 rows=606 width=4) (actual time=0.002..0.730 rows=607 loops=20000)
                 Filter: (e1.dep_id = dep_id)
                 Rows Removed by Filter: 19393
 Planning Time: 182.612 ms
 JIT:
   Functions: 11
   Options: Inlining true, Optimization true, Expressions true, Deforming true
   Timing: Generation 86.439 ms, Inlining 427.239 ms, Optimization 358.254 ms, Emission 399.381 ms, Total 1271.314 ms
 Execution Time: 21019.391 ms
(14 rows)
```

| Query | Tempo de Planejamento (ms) | Tempo de Execução (ms) |
| ----- | -------------------------- | ---------------------- |
| 1     | 182.612                    | 21019.391              |
| 2     | 0.214                      | 16000.250              |
| 3     | 0.228                      | 19216.829              |
| 4     | 0.214                      | 16785.263              |
| 5     | 0.228                      | 17654.500              |

### Planejamento (ms)

- Média: 36.4992 ms
- Desvio Padrão: 81.2145 ms

### Execução (ms)

- Média: 18115.0466 ms
- Desvio Padrão: 1933.0646 ms

Percebemos facilmente que esta query não está bem construída então a primeira coisa que iremos fazer é reorganizar a consulta para que ela seja mais eficiente.

```sql
EXPLAIN ANALYZE
SELECT e1.emp_id, e1.nome, e1.dep_id, e1.salario
FROM empregados e1
JOIN (
    SELECT dep_id, AVG(salario) AS media_salario
    FROM empregados
    GROUP BY dep_id
) AS avg_salarios
ON e1.dep_id = avg_salarios.dep_id
WHERE e1.salario > avg_salarios.media_salario;
```

| Execução | Tempo de Planejamento (ms) | Tempo de Execução (ms) |
| -------- | -------------------------- | ---------------------- |
| 1        | 186.080                    | 91.072                 |
| 2        | 0.362                      | 11.217                 |
| 3        | 0.359                      | 11.204                 |
| 4        | 0.360                      | 20.632                 |
| 5        | 0.347                      | 11.264                 |

Só isso já reduziu significativamente o tempo de execução da query, mas ainda podemos melhorar mais.
