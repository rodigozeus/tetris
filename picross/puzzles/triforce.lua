return {
  name  = "Triforce",
  color = { 0.95, 0.80, 0.10 }, -- Dourado clássico
  sol   = {
    { 0,0,0,0,0,0,0,0,0,0 }, -- Margem
    { 0,0,0,0,1,1,0,0,0,0 }, -- Topo do triângulo superior
    { 0,0,0,1,1,1,1,0,0,0 },
    { 0,0,1,1,1,1,1,1,0,0 }, -- Base do triângulo superior
    { 0,1,1,0,0,0,0,1,1,0 }, -- Topo dos triângulos inferiores
    { 1,1,1,1,0,0,1,1,1,1 },
    { 1,1,1,1,1,1,1,1,1,1 }, -- Base conectada dos triângulos
    { 0,0,0,0,0,0,0,0,0,0 }, -- Margem
    { 0,0,0,0,0,0,0,0,0,0 },
    { 0,0,0,0,0,0,0,0,0,0 },
  },
}