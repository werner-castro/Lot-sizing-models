
function outputmodel(d::Matrix{Int64}, modelo::Model, x::Array{VariableRef, 2}, I::Array{VariableRef, 2})

    J,T = size(d)

    # Validando o status da solução e gerando o relatorio de saída
    if termination_status(modelo) == MOI.OPTIMAL
        function tabela()
            obj = round.(Int,objective_value(modelo))
            produtos = "Produto " .* string.(1:J)
            periodos = "Período " .* string.(1:T)
            # Adicionando dados do modelo
            values = [
                produtos d produtos round.(Int,value.(x)) produtos round.(Int,value.(I))
            ]
            relatorio = table(
                header=attr(# Configurações do cabeçalho da tabela
                    values=[
                        ["Demanda"]
                        periodos
                        ["Produção"]
                        periodos
                        ["Estoques"]
                        periodos
                    ],
                    align="center", line=attr(width=1, color="black"),                   # configurações da tabela
                    fill_color="grey", font=attr(family="Arial", size=12, color="white") # configurações das fontes
                ),
                cells=attr(                                                              # Configurações da células
                    values=values, align="center", line=attr(color="black", width=1),    # configurações das células
                    font=attr(family="Arial", size=11, color="black")                    # configurações das fontes
                )
            )
            layout = Layout(
                title= "| Modelo - CLSP | [Solução ótima encontrada] -- Custos totais de operação = $(obj)", width = 1200
            )
            plot(relatorio,layout)
        end
        # plotando o gráfico
        # [plot(scatter(;x = 1:T, y = value.(x[1,:,1]), mode="lines+markers", name="Produção")) plot(bar(;x = 1:T, y = value.(I[1,:,1]), name="Estoque"))]

        # plotando a tabela com os dados
        tabela()
    else
        println("Solução ótima não encontrada !!!")
    end
end