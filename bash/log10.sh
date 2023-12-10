#!/bin/bash

sudo service postgresql stop
sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
sudo service postgresql start


    psql -d dojo -c "EXPLAIN ANALYZE
SELECT e.nome as "empregado", e2.nome as "chefe" , e.salario as "empsal" , e2.salario as "chefsal"
FROM empregados e
JOIN empregados e2 ON e.supervisor_id = e2.emp_id
WHERE e2.salario < e.salario;
" >> output1.txt
done


sudo service postgresql stop
sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
sudo service postgresql start

for i in {1..5}
do
    psql -d dojo -c "EXPLAIN ANALYZE
SELECT d.dep_id as x, max(salario) as y
FROM departamentos d JOIN empregados e
ON e.dep_id = d.dep_id
GROUP BY d.dep_id;
" >> output2.txt
done

sudo service postgresql stop
sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
sudo service postgresql start

for i in {1..5}
do
    psql -d dojo -c "EXPLAIN ANALYZE
WITH MaxSalaries AS (
    SELECT dep_id, MAX(salario) AS max_salario
    FROM empregados
    GROUP BY dep_id
)
SELECT d.dep_id AS x, ms.max_salario AS y
FROM departamentos d
JOIN MaxSalaries ms ON d.dep_id = ms.dep_id;
" >> output2-optimized.txt
done

sudo service postgresql stop
sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
sudo service postgresql start

for i in {1..5}
do
    psql -d dojo -c "EXPLAIN ANALYZE SELECT dep_id, nome, salario
FROM empregados
WHERE (dep_id,salario)
IN (SELECT dep_id, MAX(salario)
FROM empregados
GROUP BY dep_id);
" >> output3.txt
done

sudo service postgresql stop
sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
sudo service postgresql start

for i in {1..5}
do
    psql -d dojo -c "EXPLAIN ANALYZE select d.nome
from empregados e
join departamentos d
on e.dep_id=d.dep_id
group by d.nome
HAVING count(*)>3;
" >> output4.txt
done

sudo service postgresql stop
sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
sudo service postgresql start

for i in {1..5}
do
    psql -d dojo -c "EXPLAIN ANALYZE select d.nome, count(e.emp_id)
from departamentos d
join empregados e on d.dep_id=e.dep_id
group by d.nome;
" >> output5.txt
done

sudo service postgresql stop
sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
sudo service postgresql start

for i in {1..5}
do
    psql -d dojo -c "EXPLAIN ANALYZE
SELECT d.nome, count(e.emp_id)
FROM departamentos d
JOIN empregados e ON d.dep_id = e.dep_id
GROUP BY d.nome;" >> output5-nested.txt
done


sudo service postgresql stop
sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
sudo service postgresql start

for i in {1..5}
do
    psql -d dojo -c "EXPLAIN ANALYZE
SELECT d.nome, count(e.emp_id)
FROM departamentos d
JOIN empregados e ON d.dep_id = e.dep_id
GROUP BY d.nome;
" >> output5-merge.txt
done


sudo service postgresql stop
sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
sudo service postgresql start

for i in {1..5}
do
    psql -d dojo -c "EXPLAIN ANALYZE select e1.nome, e1.dep_id from empregados e1 join
empregados e2 on e1.supervisor_id=e2.emp_id
where e1.dep_id!=e2.dep_id;
" >> output6-2.txt
done

sudo service postgresql stop
sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
sudo service postgresql start

for i in {1..5}
do
    psql -d dojo -c "EXPLAIN ANALYZE SELECT e1.nome, e1.dep_id
FROM empregados e1
LEFT JOIN empregados e2 ON e1.supervisor_id = e2.emp_id AND e1.dep_id <> e2.dep_id
WHERE e2.emp_id IS NOT NULL;
" >> output6-optimized-2.txt
done



sudo service postgresql stop
sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
sudo service postgresql start

for i in {1..5}
do
    psql -d dojo -c "EXPLAIN ANALYZE SELECT d.dep_id, d.nome AS departamento, SUM(e.salario) AS "Salariototal"
FROM departamentos d
LEFT OUTER JOIN empregados e ON d.dep_id = e.dep_id
GROUP BY d.dep_id, d.nome;" >> output7.txt
done

sudo service postgresql stop
sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
sudo service postgresql start

for i in {1..5}
do
    psql -d dojo -c "EXPLAIN ANALYZE select emp_id,nome, dep_id, salario
from empregados e1
where salario > (select avg(salario)
from empregados e2
where e1.dep_id = e2.dep_id);
" >> output8.txt
done


sudo service postgresql stop
sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
sudo service postgresql start

for i in {1..5}
do
    psql -d dojo -c "EXPLAIN ANALYZE
SELECT e1.emp_id, e1.nome, e1.dep_id, e1.salario
FROM empregados e1
JOIN (
    SELECT dep_id, AVG(salario) AS media_salario
    FROM empregados
    GROUP BY dep_id
) AS avg_salarios
ON e1.dep_id = avg_salarios.dep_id
WHERE e1.salario > avg_salarios.media_salario;
" >> output8-1.txt
done


sudo service postgresql stop
sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
sudo service postgresql start

for i in {1..5}
do
    psql -d dojo -c "EXPLAIN ANALYZE
SELECT e1.emp_id, e1.nome, e1.dep_id, e1.salario
FROM empregados e1
JOIN (
    SELECT dep_id, AVG(salario) AS media_salario
    FROM empregados
    GROUP BY dep_id
) AS avg_salarios
ON e1.dep_id = avg_salarios.dep_id
WHERE e1.salario > avg_salarios.media_salario;
" >> output8-4.txt
done





sudo service postgresql stop
sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
sudo service postgresql start

for i in {1..5}
do
    psql -d dojo -c "EXPLAIN ANALYZE SELECT emp_id, nome, dep_id, salario, AVG(salario)
OVER (PARTITION BY dep_id)
FROM empregados;
" >> output9.txt
done

sudo service postgresql stop
sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
sudo service postgresql start

for i in {1..5}
do
    psql -d dojo -c "EXPLAIN ANALYZE SELECT e.nome, e.dep_id, e.salario, AVG(e.salario)
OVER (PARTITION BY e.dep_id) AS media_salario_departamento
FROM empregados e
JOIN (SELECT dep_id, AVG(salario) AS media_salario
FROM empregados GROUP BY dep_id) AS t
ON e.dep_id = t.dep_id
WHERE e.salario >= t.media_salario;
" >> output10.txt
done
