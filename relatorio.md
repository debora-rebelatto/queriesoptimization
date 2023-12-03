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

## EXPLAIN ANALYZE

A seguir temos os resultados da primeira execução do comando de `EXPLAIN ANALYZE` para cada uma das 10 consultas fornecidas, onde analisamos o tempo de planejamento e de execução para cada uma limpando o buffer antes para evitar que o cache do sistema influencie nos resultados.

A coluna de tempo total é a soma do tempo de planejamento e de execução.

Ordenando pelo tempo de total de forma decrescente, podemos facilitar a visualização sobre quais consultas são mais lentas, e portanto, quais consultas devem ser otimizadas.

| Query    | Tempo de Planejamento (ms) | Tempo de Execução (ms) |
| -------- | -------------------------- | ---------------------- |
| Query 10 | 52.263                     | 20.959                 |
| Query 7  | 52.424                     | 21.002                 |
| Query 8  | 52.617                     | 21.252                 |
| Query 1  | 27.843                     | 24.542                 |
| Query 4  | 60.226                     | 24.391                 |
| Query 5  | 60.297                     | 24.311                 |
| Query 6  | 118.544                    | 21.278                 |
| Query 2  | 60.442                     | 35.730                 |
| Query 9  | 85.155                     | 32.442                 |
| Query 3  | 160.001                    | 32.058                 |

Uma análise que podemos fazer apenas a partir desses dados é que todas as consultas possuem um tempo de planejamento muito maior que o tempo de execução, o que indica que o tempo de execução não é o problema, e sim o tempo de planejamento. Isso pode ser explicado pelo fato de que o postgres precisa analisar a query e decidir qual o melhor plano de execução para a mesma, e isso leva tempo.

Irei levar em conta apenas o tempo de execução para a análise de otimização, pois o tempo de planejamento não é algo que podemos otimizar diretamente, e sim indiretamente através da otimização da query. Então, temos que as consultas mais lentas são: 10, 7 e 8.

- Explicar o funcionamento com o comando explain das 3 consultas mais lentas.
- Executar a consulta 5 vezes, calcular a média e o desvio.
- Explicar o plano da consulta.

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

## [Query 10](./resultados/output10.txt)

## Tarefa 1

- [x] Executar a consulta 5 vezes, calcular a média e o desvio.
- [ ] Explicar o funcionamento com o comando explain
- [ ] Explicar o plano da consulta.
- [ ] Atentar: Qual algoritmo foi usado para realizar o Join? Explique o seu funcionamento.

## Tarefa 2

- [ ] Analisar a consulta visando possíveis melhorias na consulta.
- [ ] Qual etapa está gastando mais recursos? Será que a inserção de index pode ajudar a reduzir o tempo da consulta?
- [ ] Além disso, reescrever a consulta pode auxiliar o SBGB?

Encontre os empregados com salario maior ou igual a média do seu departamento. Deve ser reportado o salario do empregado e a média do departamento (dica: usar window function com subconsulta)

```sql
EXPLAIN ANALYZE SELECT e.nome, e.dep_id, e.salario, AVG(e.salario)
OVER (PARTITION BY e.dep_id) AS media_salario_departamento
FROM empregados e
JOIN (SELECT dep_id, AVG(salario) AS media_salario
FROM empregados GROUP BY dep_id) AS t
ON e.dep_id = t.dep_id
WHERE e.salario >= t.media_salario;
```

| Query      | Tempo de Planejamento (ms) | Tempo de Execução (ms) |
| ---------- | -------------------------- | ---------------------- |
| Query 1    | 230.301                    | 38.276                 |
| Query 2    | 0.168                      | 0.240                  |
| Query 3    | 0.160                      | 0.359                  |
| Query 4    | 0.158                      | 0.344                  |
| Query 5    | 0.111                      | 0.185                  |
| **Média**  | 46.199                     | 7.081                  |
| **Desvio** | 85.155                     | 32.442                 |

Após a segunda execução da query, percebemos que a gradualmente o tempo de execução começa a diminuir, o que ocorre por causa da cache do sistema, que armazena os dados na memória para que eles possam ser acessados mais rapidamente.

