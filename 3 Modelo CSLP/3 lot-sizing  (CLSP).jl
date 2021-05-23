# Capacitated lot-sizing problem (CLSP) / Modelo de dimensionamento de lotes multi-ítem com restrição de capacidade.
# 
# modelo retirado do livro: Deterministic Lotsizing Models for Production Planning, Marc Salomon, pg = 30

# Indices
# j = 1....J productos
# t = 1....T periods

# Data/Parameters
# bj = capacity absorption / temop de processamento do produto j 
# pj = production costs / custo de produção do item j
# hj = holding costs per unit of product j for one period/ custo de estocagem do produto j por uma unidade de período de tempo
# sj = setup costs for product j/ custo de setup do produto j
# djt = Demand of product j in period t (qty)/ demanda do produto j no período t
# Ct = available capacity in period t (time)/capacidade disponível no período t em unidades de tempo

# Variables
# Ijt >= 0, inventory of product j at the end of period t (qty) / estoque do produto j no final no período t.
# xjt >= 0, total quantity of product j produced in period t (qty) / quantidade total produzida do produto j no período t.
# yjt ∈ {0,1} setup changeover = 1 if a setup changeover to product j is executed in period t, 0 otherside.
#
# Objective function / Função objetivo
#
#         J   T
# Min z = ∑   ∑ (s(j) * y(j,t) + h(j) * I(j,t) + p(j,t) * x(j,t))
#        j=1 t=1
#
# subject to / restrições

# I(j, t-1) + x(j,t) - d(j,t) = I(j,t)                 ∀ j = 1...J, t = 1...T

#  J
#  ∑ b(j) * x(j,t) ≤ C(t)                              ∀ t = 1..T 
# j=1

#            T
# x(j,t) ≤ ( ∑ d(j,τ) ) * y(j,t)                       ∀ j = 1...J, t = 1...T
#           τ=1 

using JuMP, Cbc, PlotlyJS, ElectronDisplay

include("utils.jl")

# CLSP = Model(with_optimizer(CPLEX.Optimizer))
CLSP = Model(Cbc.Optimizer)

# Indices
J = 9                          # number of products / número de produtos
T = 4                          # number of periods / número de períodos

# Parâmetros
b = rand(1:4,J,1)               # capacity absorption / tempo de processamento
d = rand(1:100,J,T)             # Demand/demanda
p = rand(1:4,J,T)               # Production costs / custos de produção
h = repeat(rand(10:10,J,1))     # holding costs / custos de estocagem
s = repeat(rand(2:2,J,1))       # setup costs / custos de preparação
C = repeat(rand(1000:1000,1,T)) # available capacity in period t / capacidade de produção em unidades de tempo por período t

# Variáveis
@variable(CLSP, I[j in 1:J, t in 0:T] >= 0, Int)   # inventory of product / quantidade a ser estocada
@variable(CLSP, x[j in 1:J, t in 1:T] >= 0, Int)   # total quantity of product j produced in period t / quantidade de produto j a ser produzida no período t
@variable(CLSP, y[j in 1:J, t in 1:T], Bin)        # binary setup variables

# Função objetivo = minimiza os custos de estocagem e produção
@objective(CLSP, Min, sum(s[j] * y[j,t] + h[j] * I[j,t] +  p[j,t] * x[j,t] for j in 1:J, t in 1:T))

# Restrições
@constraint(CLSP, [j in 1:J, t in 1:T],  I[j,t-1] + x[j,t] - d[j,t] == I[j,t])   
@constraint(CLSP, [t in 1:T], sum(b[j] * x[j,t] for j = 1:J) ≤ C[t])
@constraint(CLSP, [j in 1:J, t in 1:T], x[j,t] ≤ (sum(d[j,τ] for τ = 1:T)) * y[j,t])             

# Otimizando o modelo
optimize!(CLSP)

# validando o status da solução e gerando o relatorio de saída
outputmodel(d, CLSP, x, I)
