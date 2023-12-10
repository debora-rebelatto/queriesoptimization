# Prova 2 LFA

1- Para a GR a seguir, construa o AFND:

S::= bB | aA | bA
A::= cS | bB | cC
B::= cS | a | ᗴ

Use a tabela para determinizar a AFND acima
| | a | b | c | d |
|-----|---|---|-----|---|
| => S | B | B | A,C ||
| A*| | |S|B|
|B*|S| | D| |
|C|A|B,S| | |
|D\*| | | |

2- Fatore a GLC
S::= 1A | OAB | 1AB
A::= 1C0 | 01
B::= S10 | C01
C::= 11C | 10B

3- Elimine os símbolos inúteis da seguinte GLC
S::= aBb | aCd | ab
A::= aCa | aA | b
B::= aBb | aB
C::= ad | aCc

4- Elimine a recursão a esquerda da seguinte GLC
S::= Bc | Sc  
A::= AC | SaA | aAb
B::= Bc | Sab

5- Construa uma árvore de derivação por redução usando a GLC:

E::= E+E | E\*E | (E) | id

Para a expressão: (id+id)\*(id+id)
