sudo service postgresql stop
sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
sudo service postgresql start
sudo -u postgres psql -d dojo

CREATE INDEX idx_dep_salario ON empregados (dep_id, salario);
DROP INDEX IF EXISTS idx_dep_salario;

EXPLAIN ANALYZE SELECT e.dep_id, e.nome, e.salario
FROM empregados e
JOIN (
    SELECT dep_id, MAX(salario) AS max_salario
    FROM empregados
    GROUP BY dep_id
) AS max_sal ON e.dep_id = max_sal.dep_id AND e.salario = max_sal.max_salario
/*+ index(empregados empregados_dep_id_salario_idx) */

EXPLAIN ANALYZE SELECT DISTINCT ON (dep_id) dep_id, nome, salario
FROM empregados
ORDER BY dep_id, salario DESC;
