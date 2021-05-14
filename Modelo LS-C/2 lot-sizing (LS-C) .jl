# capacitated lot-sizing model (LS - C) / modelo de dimensionamento de lotes capacitado com único item.

# Indices
# j = 1....J productos
# t = 1....T periods

# Data/Parameters
# hj = holding costs per unit of product j for one period/ custo de estocagem por unidade do produto j no período de tempo.
# pj = setup costs for product j / custo de setup do produto j.
# qj = production unit cost for product j / custo de produção por unidade produzida.
# djt = Demand of product j in period t (qty) / demanda do produto j no período t.
# Ij0 = initial inventory of product j at the beginning of the planning horizon (qty) / estoque inicial do produto j no início do planejamento.
# Ct = available capacity in period t (time) / capacidade disponível no período t em unidades de tempo.
# Mjt = sufficiently large number for product j and period t.

# Variables
# Ijt >= 0 inventory of product j at the end of period t (qty) / estoque do produto j no final no período t.
# xjt >= 0 total quantity of product j produced in period t (qty) / quantidade total produzida do produto j no período t.
# yjt ∈ {0,1} setup changeover yjt = 1 if a setup changeover to product j is executed in period t (0 otherside).

using JuMP, Cbc, PlotlyJS

include("report.jl")

LSC = Model(with_optimizer(Cbc.Optimizer, threads = 5, seconds = 3600.0))

# Parameters
J = 1 # number of products
T = 6 # number of periods
# d = rand(1:100,J,T) # Demand
# h = rand(10:10,J,1) # holding costs
# p = rand(10:10,J,1) # setup costs
# q = rand(10:10,J,1) # production unit cost
Ij0 = rand(000:000,J,1) # initial stock
# C = rand(1000:1000,T,1) # available capacity in period t. / capacidade de produção em unidades de tempo por período t
M = 300  # sufficiently large number.

d = [6 7 4 6 2 8]
q = [3,4,3,4,4,5]
C = rand(10:10,T,1)
p = [12,15,30,23,19,45]
h = [1,1,1,1,1,1]

# Variables
@variable(LSC, I[j in 1:J, t in 1:T] >= 0, Int) # inventory of product.
@variable(LSC, x[j in 1:J, t in 1:T] >= 0, Int) # total quantity of product j produced in period t.
@variable(LSC, y[j in 1:J, t in 1:T], Bin) # setup changeover

# Objective function
@objective(LSC, Min, sum(p[j] * x[j,t] + q[j] * y[j,t] + h[j] * I[j,t] for j in 1:J, t in 1:T))

# Constraints
#@constraint(LSC, [j in 1:J, t = 1], Ij0[j] + x[j,t] == d[j,t] + I[j,t]) # balance inventory in period t = 1
@constraint(LSC, [j = 1:J, t = 2:T], I[j,t-1] + x[j,t] == d[j,t] + I[j,t]) # balance inventory in period t in 2 to T.
@constraint(LSC, I[1,1] == 0) # estoque inicial é igual à zero.
# @constraint(LSC, I[1,T] == 0) # estoque final é igual ao estoque inicial.
@constraint(LSC, [j in 1:J, t in 1:T], x[j,t] <= M * y[j,t]) # maximum lot-sizing constraint.

# solve model
optimize!(LSC)

# 
report(LSC, x, I)