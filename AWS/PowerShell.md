# Aquesta és la comanda que he provat
Measure-Command {
    Get-Process | Where-Object { $_.CPU -gt 1800 } | Select-Object -Property *
}

# He fet la prova amb el meu PC, ja que a la màquina virtual no hi havia cap procés que hagués consumit CPU durant + de 30 minuts

