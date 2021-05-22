
# LS-U modelo de dimensionamento de lotes não capacitado com único item.

# Indices
# t = 1....T periodos

# Parâmetros
# h = custo de estocagem por unidade do produto j no período de tempo.
# p = custo de setup do produto.
# q = custo de produção por unidade produzida.
# dt = demanda do produto no período t.
# I0 = estoque inicial do produto.
# M =  número suficientemente grande

# Variaveis
# It >= 0 quantidade estocada do produto no final no período t.
# xt >= 0 quantidade total produzida do produto no período t.
# yt ∈ {0,1} variável de escolha que define se o produto será no produzida no período t.


# Modelo matemático

# Função objetivo:

#         T
# Min z = ∑ (p(t) * x(t) + q(t) * y(t) + h(t) * I(t))
#       t = 1

# Restrições:

#  I(t-1) + x(t) = d(t) + I(t)               ∀ t = 1...T
#  I(1) = 0
#  I(t) = 0
#  x(t) ≤ M * y(t)                          ∀ t = 1...T


using JuMP, Cbc, PlotlyJS

LSU = Model(Cbc.Optimizer)

include("report.jl")

# Indices
T = 8 # number of periods

# Parametros
d = rand(1:100,1,T)                # demand
h = rand(10:10,1,T)                # holding costs
p = rand(10:10,1,T)                # setup costs
q = rand(10:10,1,T)                # production unit cost
I0 = rand(0:0,1)                   # initial stock
M = sum(d) * 100                   # sufficiently large number

# Variaveis
@variable(LSU, I[1:T] >= 0, Int)   # inventory of product.
@variable(LSU, x[1:T] >= 0, Int)   # total quantity of product produced in period t.
@variable(LSU, y[1:T], Bin)        # setup changeover

# Função objetivo
@objective(LSU, Min, sum(p[t] * x[t] + q[t] * y[t] + h[t] * I[t] for t in 1:T))

# Restrições
@constraint(LSU, [t = 1], I0[1] + x[t] == d[t] + I[t])    # balance inventory in period t = 1
@constraint(LSU, [t = 2:T], I[t-1] + x[t] == d[t] + I[t]) # balance inventory in period t in 2 to T.
@constraint(LSU, I[1] == 0)                               # estoque inicial igual à zero.
@constraint(LSU, I[T] == 0)                               # estoque final igual à zero.
@constraint(LSU, [t in 1:T], x[t] <= M * y[t])            # maximum lot-sizing constraint. / restrição que define o tamanho máximo do lote

# Resolvendo o modelo
optimize!(LSU)

# gerando o relatório de saída
report(LSU,T,d,I,x)
