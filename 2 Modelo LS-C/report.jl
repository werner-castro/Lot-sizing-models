
function report(model::Model, x::AbstractArray, I::AbstractArray)
    if termination_status(model) == MOI.OPTIMAL
        J,T = size(x)
        objetivo = round.(Int,objective_value(model))
        periodos = "Período " .* string.(1:T)
        produtos = "Produto " .* string.(1:J)
        function tabela()
            # Adicionando dados do modelo
            values = [
                produtos round.(Int,value.(x)) produtos round.(Int,value.(I))
            ]
            relatorio = table(
                header=attr(# Configurações do cabeçalho
                    values=[
                        ["Produção"]
                        periodos
                        ["Estoque"]
                        periodos
                    ],
                    align="center", line=attr(width=1, color="black"), # configurações da tabela
                    fill_color="grey", font=attr(family="Arial", size=12, color="white") # configurações das fontes
                ),
                cells=attr(# Configurações da células
                    values=values, align="center", line=attr(color="black", width=1),# configurações das células
                    font=attr(family="Arial", size=11, color="black")# configurações das fontes
                )
            )
            layout = Layout(
                title="| Modelo - LS-C | [Solução ótima encontrada] -- Custos totais da operação = $(objetivo) ", width = 1200
            )
            plot(relatorio,layout)
        end
        return tabela()
    else
        println("Solução ótima não encontrada !")
    end
end
