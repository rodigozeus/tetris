return {
  name  = "Cogumelo (Mario)",
  color = { 0.90, 0.10, 0.10 }, -- Um vermelho um pouco mais vivo
  sol   = {
    { 0,0,0,0,0,0,0,0,0,0 }, -- Margem superior
    { 0,0,0,1,1,1,1,0,0,0 }, -- Topo do chapéu
    { 0,0,1,1,0,0,1,1,0,0 }, -- Início da mancha central
    { 0,1,1,1,0,0,1,1,1,0 }, -- Mancha central continua
    { 1,1,0,0,1,1,0,0,1,1 }, -- Manchas laterais (esq/dir)
    { 1,1,0,0,1,1,0,0,1,1 }, -- Manchas laterais
    { 0,1,1,1,1,1,1,1,1,0 }, -- Base sólida do chapéu
    { 0,0,0,1,1,1,1,0,0,0 }, -- Caule largo
    { 0,0,0,1,1,1,1,0,0,0 }, -- Caule largo
    { 0,0,0,0,0,0,0,0,0,0 }, -- Margem inferior
  },
}
