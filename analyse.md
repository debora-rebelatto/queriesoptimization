Claro, aqui estão as consultas separadas e prontas para serem copiadas individualmente, cada uma com o comando `EXPLAIN ANALYZE` no início:

1. Listar os empregados (nomes) que têm salário maior que seu chefe (usar o join):

```sql
EXPLAIN ANALYZE
SELECT e.nome as "empregado", e2.nome as "chefe", e.salario as "emp sal", e2.salario as "chef sal"
FROM empregados e
JOIN empregados e2 ON e.supervisor_id = e2.emp_id
WHERE e2.salario < e.salario;
```

2. Listar o maior salário de cada departamento (usa o group by):

```sql
EXPLAIN ANALYZE
SELECT d.dep_id as x, max(salario) as y
FROM departamentos d JOIN empregados e
ON e.dep_id = d.dep_id
GROUP BY d.dep_id;
```

3. Listar o dep_id, nome e o salário do funcionário com maior salário dentro de cada departamento (usar o with):

```sql
EXPLAIN ANALYZE
WITH max_salarios AS (
    SELECT dep_id, MAX(salario) AS max_salario
    FROM empregados
    GROUP BY dep_id
)
SELECT e.dep_id, e.nome, e.salario
FROM empregados e
JOIN max_salarios m ON e.dep_id = m.dep_id AND e.salario = m.max_salario;
```

4. Listar os nomes departamentos que têm menos de 3 empregados:

```sql
EXPLAIN ANALYZE
SELECT d.nome
FROM departamentos d
LEFT JOIN empregados e ON d.dep_id = e.dep_id
GROUP BY d.nome
HAVING COUNT(e.emp_id) < 3;
```

5. Listar os departamentos com o número de colaboradores:

```sql
EXPLAIN ANALYZE
SELECT d.nome, COUNT(e.emp_id) AS "Numero de colaboradores"
FROM departamentos d
LEFT JOIN empregados e ON d.dep_id = e.dep_id
GROUP BY d.nome;
```

6. Listar os empregados que não possuem o seu chefe no mesmo departamento:

```sql
EXPLAIN ANALYZE
SELECT e1.nome, e1.dep_id
FROM empregados e1
JOIN empregados e2 ON e1.supervisor_id = e2.emp_id
WHERE e1.dep_id != e2.dep_id;
```

7. Listar os nomes dos departamentos com o total de salários pagos (sliding windows function):

```sql
EXPLAIN ANALYZE
SELECT d.dep_id, d.nome AS departamento, SUM(e.salario) AS "Salario total"
FROM departamentos d
LEFT JOIN empregados e ON d.dep_id = e.dep_id
GROUP BY d.dep_id, d.nome;
```

8. Listar os nomes dos colaboradores com salário maior que a média do seu departamento (dica: usar subconsultas):

```sql
EXPLAIN ANALYZE
SELECT emp_id, nome, dep_id, salario
FROM empregados e1
WHERE salario > (
    SELECT AVG(salario)
    FROM empregados e2
    WHERE e1.dep_id = e2.dep_id
);
```

9. Consulta capaz de listar os dep_id, nome, salario e as médias de cada departamento utilizando o windows function:

```sql
EXPLAIN ANALYZE
SELECT emp_id, nome, dep_id, salario, AVG(salario) OVER (PARTITION BY dep_id)
FROM empregados;
```

10. Encontre os empregados com salário maior ou igual à média do seu departamento. Deve ser reportado o salário do empregado e a média do departamento (dica: usar window function com subconsulta):

```sql
EXPLAIN ANALYZE
SELECT e.nome, e.dep_id, e.salario, AVG(e.salario) OVER (PARTITION BY e.dep_id) AS media_salario_departamento
FROM empregados e
JOIN (
    SELECT dep_id, AVG(salario) AS media_salario
    FROM empregados
    GROUP BY dep_id
) AS t ON e.dep_id = t.dep_id
WHERE e.salario >= t.media_salario;
```

Cada uma dessas consultas pode ser copiada individualmente e executada no seu banco de dados, fornecendo informações detalhadas sobre o tempo de execução e o plano de execução de cada consulta.
