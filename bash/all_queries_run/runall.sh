#!/bin/bash

# Function to execute queries and log output to the same file
execute_query() {
    query="$1"
    output_file="$2"

    sudo service postgresql stop
    sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
    sudo service postgresql start
    
    psql -d dojo -c "$query" >> "$output_file" 2>&1
}

# File to store all query outputs
output_file="all_queries_output-5.txt"

# Queries to be executed
queries=(
"EXPLAIN ANALYZE
SELECT e.nome as "empregado", e2.nome as "chefe" , e.salario as "empsal" , e2.salario as "chefsal"
FROM empregados e
JOIN empregados e2 ON e.supervisor_id = e2.emp_id
WHERE e2.salario < e.salario;"
    "EXPLAIN ANALYZE
SELECT d.dep_id as x, max(salario) as y
FROM departamentos d JOIN empregados e
ON e.dep_id = d.dep_id
GROUP BY d.dep_id;"
# 3
"EXPLAIN ANALYZE SELECT dep_id, nome, salario
FROM empregados
WHERE (dep_id,salario)
IN (SELECT dep_id, MAX(salario)
FROM empregados
GROUP BY dep_id);
"
# 4
"EXPLAIN ANALYZE select d.nome
from empregados e
join departamentos d
on e.dep_id=d.dep_id
group by d.nome
HAVING count(*)>3;
"
# 5

"EXPLAIN ANALYZE select d.nome, count(e.emp_id)
from departamentos d
join empregados e on d.dep_id=e.dep_id
group by d.nome;"

# 6
"EXPLAIN ANALYZE select e1.nome, e1.dep_id from empregados e1 join
empregados e2 on e1.supervisor_id=e2.emp_id
where e1.dep_id!=e2.dep_id;
"

"EXPLAIN ANALYZE SELECT d.dep_id, d.nome AS departamento, SUM(e.salario) AS "Salariototal"
FROM departamentos d
LEFT OUTER JOIN empregados e ON d.dep_id = e.dep_id
GROUP BY d.dep_id, d.nome;"

"EXPLAIN ANALYZE select emp_id,nome, dep_id, salario
from empregados e1
where salario > (select avg(salario)
from empregados e2
where e1.dep_id = e2.dep_id);
"
"EXPLAIN ANALYZE SELECT emp_id, nome, dep_id, salario, AVG(salario)
OVER (PARTITION BY dep_id)
FROM empregados;
"

"EXPLAIN ANALYZE SELECT e.nome, e.dep_id, e.salario, AVG(e.salario)
OVER (PARTITION BY e.dep_id) AS media_salario_departamento
FROM empregados e
JOIN (SELECT dep_id, AVG(salario) AS media_salario
FROM empregados GROUP BY dep_id) AS t
ON e.dep_id = t.dep_id
WHERE e.salario >= t.media_salario;
"
)

# Loop through queries and execute them, appending output to the same file
echo "" > "$output_file"  # Clear contents of the output file
for ((i=0; i<${#queries[@]}; i++)); do
    query="${queries[$i]}"
    
    echo "Running query $((i+1))..."
    execute_query "$query" "$output_file"
    echo "Query $((i+1)) completed. Output appended to $output_file"
    echo ""
done
