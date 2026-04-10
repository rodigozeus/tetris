return {
  name  = "Casa (Detalhada)",
  color = { 0.40, 0.75, 0.35 },
  sol   = {
    { 0,0,0,0,1,1,0,0,0,0 },
    { 0,0,0,1,1,1,1,0,0,0 },
    { 0,0,1,1,1,1,1,1,0,0 },
    { 0,1,1,1,1,1,1,1,1,0 },
    { 1,1,1,1,1,1,1,1,1,1 }, -- Beiral do telhado ocupando toda a largura
    { 0,1,1,1,1,1,1,1,1,0 }, -- Paredes largas
    { 0,1,0,1,0,0,1,0,1,0 }, -- Janela, Parede, Porta, Parede, Janela
    { 0,1,1,1,0,0,1,1,1,0 }, -- Base da janela, Porta
    { 0,1,1,1,0,0,1,1,1,0 }, -- Chão da casa
    { 0,0,0,0,0,0,0,0,0,0 },
  },
}
