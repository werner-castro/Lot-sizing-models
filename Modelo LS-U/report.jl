# tabela com relatório de saída do modelo matemático
function report(Modelo::Model, T::Int, d::AbstractArray, I::AbstractArray, x::AbstractArray)

    obj = objective_value(Modelo)

    # Validando o status da solução e gerando o relatorio de saída
    if termination_status(Modelo) == MOI.OPTIMAL
        periodos = "Período " .* string.(1:T)
        function tabela()
            # Adicionando dados do modelo
            values = [
                periodos, d, round.(Int,value.(x)), round.(Int,value.(I))
            ]
            rel = table(
                header=attr(                                                             # configurações do cabeçalho
                    values=[
                        ["Períodos"],["Demanda"],["Produção planejada"],["Estoque planejado"]
                    ],
                    align="center", line=attr(width=1, color="black"),                   # configurações da tabela
                    fill_color="grey", font=attr(family="Arial", size=12, color="white") # configurações das fontes
                ),
                cells=attr(                                                              # configurações da células
                    values=values, align="center", line=attr(color="black", width=1),    # configurações das células
                    font=attr(family="Arial", size=11, color="black")                    # configurações das fontes
                )
            )
            layout = Layout(title = "| Modelo LS-U  | solução ótima encontrada -- custos totais de operação = $(obj)", width=1200)
            PlotlyJS.plot(rel,layout)
        end
        return tabela()
    else
        println("Solução ótima não encontrada !!!")
    end
end
