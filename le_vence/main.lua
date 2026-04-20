-- Lê e Vence! — Desafio de leitura e compreensão para crianças
-- Console : Anbernic RG DS | Engine : Love2D 11.5
-- Tela de cima  (DSI-2) : x   0.. 639 — texto para leitura
-- Tela de baixo (DSI-1) : x 640..1279 — pergunta + 4 alternativas (touch)

-- ═══════════════════════════════════════════════════════════════════════════
--  QUESTÕES
-- ═══════════════════════════════════════════════════════════════════════════
local QUESTOES = {
  -- ── Nível 1 – Fácil ─────────────────────────────────────────────────────
  --1
  {
    texto    = "O cachorro late quando tem medo. Ele abana o rabo quando está feliz. O dono do cachorro se chama Pedro.",
    pergunta = "O que o cachorro faz quando está feliz?",
    opcoes   = {"Late", "Dorme", "Abana o rabo", "Come"},
    correta  = 3,
    bg       = {0.85, 1.00, 0.88},
  },
  --2
  {
    texto    = "Ana foi para a escola de manhã. Ela levou sua mochila azul. Na escola, Ana aprendeu a escrever.",
    pergunta = "De que cor era a mochila de Ana?",
    opcoes   = {"Verde", "Vermelha", "Amarela", "Azul"},
    correta  = 4,
    bg       = {1.00, 0.97, 0.82},
  },
  --3
  {
    texto    = "O sol nasce de manhã e se esconde à noite. Ele aquece a Terra e dá luz. À noite aparece a lua.",
    pergunta = "Quando o sol nasce?",
    opcoes   = {"À noite", "De manhã", "À tarde", "No inverno"},
    correta  = 2,
    bg       = {1.00, 0.93, 0.80},
  },
  --4
  {
    texto    = "Hoje está chovendo muito. Bia pegou o guarda-chuva e saiu de casa. Na rua, ela viu uma poça d'água e pulou por cima.",
    pergunta = "Por que Bia pegou o guarda-chuva?",
    opcoes   = {"Para brincar", "Porque estava chovendo", "Para se proteger do sol", "Porque estava frio"},
    correta  = 2,
    bg       = {0.91, 0.87, 1.00},
  },
  --5
  {
    texto    = "Hoje é o aniversário do Lucas. Ele vai fazer sete anos. A mamãe fez um bolo de chocolate com velas.",
    pergunta = "Quantos anos Lucas vai fazer?",
    opcoes   = {"Cinco", "Seis", "Sete", "Oito"},
    correta  = 3,
    bg       = {1.00, 0.85, 0.92},
  },
  --6
  {
    texto    = "A borboleta começou como uma lagarta. Depois ficou dentro de um casulo. Quando saiu do casulo, ela tinha asas coloridas.",
    pergunta = "Como a borboleta começa a vida?",
    opcoes   = {"Como um casulo", "Como um pássaro", "Como uma lagarta", "Como um ovo"},
    correta  = 3,
    bg       = {0.82, 1.00, 0.92},
  },
  --7
  {
    texto    = "Na biblioteca, as pessoas leem livros em silêncio. João foi à biblioteca para pegar um livro sobre dinossauros. Ele ficou duas horas lendo.",
    pergunta = "Por que João foi à biblioteca?",
    opcoes   = {"Para ler", "Para comer", "Para dormir", "Para pegar um livro"},
    correta  = 4,
    bg       = {0.87, 0.92, 1.00},
  },
  --8
  {
    texto    = "No inverno, os dias são frios. As pessoas usam casaco e cachecol para se aquecer. Em alguns lugares, cai neve no inverno.",
    pergunta = "O que as pessoas usam para se aquecer no inverno?",
    opcoes   = {"Camiseta e shorts", "Casaco e cachecol", "Boné e óculos", "Sandália e vestido"},
    correta  = 2,
    bg       = {0.88, 0.93, 0.98},
  },
  --9
  {
    texto    = "Dona Rosa tem uma horta no quintal. Ela planta tomates, cenouras e alface. Todo dia pela manhã ela rega as plantas.",
    pergunta = "Quando Dona Rosa rega as plantas?",
    opcoes   = {"À noite", "À tarde", "De manhã", "Toda semana"},
    correta  = 3,
    bg       = {0.88, 1.00, 0.83},
  },
  --10
  {
    texto    = "Miguel ganhou um robô de presente. O robô é vermelho e anda sozinho. Miguel aperta um botão e o robô dança.",
    pergunta = "O que acontece quando Miguel aperta o botão?",
    opcoes   = {"O robô para", "O robô dança", "O robô fala", "O robô some"},
    correta  = 2,
    bg       = {0.87, 0.90, 0.97},
  },
  --11
  {
    texto    = "Carla foi à praia com sua família. O mar estava azul e quente. Ela nadou, brincou na areia e comeu sorvete de morango.",
    pergunta = "Qual sabor de sorvete Carla comeu?",
    opcoes   = {"Chocolate", "Baunilha", "Limão", "Morango"},
    correta  = 4,
    bg       = {0.80, 0.97, 0.95},
  },
  --12
  {
    texto    = "A mãe de Pedro foi ao mercado comprar frutas. Ela comprou maçã, laranja e uva. Na hora de pagar, ela usou um cartão.",
    pergunta = "Como a mãe de Pedro pagou no mercado?",
    opcoes   = {"Com dinheiro", "Com cheque", "Com cartão", "Com troca"},
    correta  = 3,
    bg       = {1.00, 0.96, 0.78},
  },
  --13
  {
    texto    = "O urso polar vive em lugares muito frios, como o Ártico. Sua pelagem branca o ajuda a se esconder na neve. Ele é um ótimo nadador e come peixe.",
    pergunta = "Para que serve a pelagem branca do urso polar?",
    opcoes   = {"Para aquecer no calor", "Para nadar mais rápido", "Para se esconder na neve", "Para assustar outros animais"},
    correta  = 3,
    bg       = {0.83, 0.95, 1.00},
  },
  --14
  {
    texto    = "Papai estava cansado e quis pedir pizza. Mas Vovó queria fazer macarrão em casa. No final, todos ajudaram a cozinhar e o macarrão ficou delicioso.",
    pergunta = "O que Papai queria fazer para o jantar?",
    opcoes   = {"Fazer macarrão", "Pedir macarrão", "Fazer pizza", "Pedir pizza"},
    correta  = 4,
    bg       = {1.00, 0.93, 0.83},
  },
  --15
  {
    texto    = "Sofia sonhou que podia voar sobre as nuvens. No sonho, ela viu cidades pequenas lá embaixo e tocou nas estrelas. Quando acordou, quis dormir de novo para continuar o sonho.",
    pergunta = "Por que Sofia quis dormir de novo?",
    opcoes   = {"Porque estava com sono", "Porque era muito cedo", "Para ir à escola no sonho", "Para continuar o sonho"},
    correta  = 4,
    bg       = {0.93, 0.88, 1.00},
  },
  --16
  {
    texto    = "Dona Raposa muito esperta viu o rato com um queijo bem redondo. Quando o rato adormeceu, ela pegou um saco, roubou o queijo e saiu ligeira.",
    pergunta = "Como era o queijo do rato?",
    opcoes   = {"Quadrado", "Pequeno", "Bem redondo", "Comprido"},
    correta  = 3,
    bg       = {0.85, 1.00, 0.88},
  },
  --17
  {
    texto    = "O gato Mimi adora brincar com novelos de lã. Seu novelo favorito é o vermelho. Ele rola no tapete da sala o dia todo.",
    pergunta = "Qual é a cor do novelo favorito do gato Mimi?",
    opcoes   = {"Azul", "Amarelo", "Vermelho", "Verde"},
    correta  = 3,
    bg       = {0.90, 0.95, 1.00},
  },
  --18
  {
    texto    = "O passarinho Piu fez um ninho na árvore. Ele usou folhas e galhos secos. Todo dia de manhã, Piu canta uma linda música.",
    pergunta = "O que o passarinho usou para fazer o ninho?",
    opcoes   = {"Pedras e terra", "Folhas e galhos secos", "Papel e plástico", "Algodão e lã"},
    correta  = 2,
    bg       = {1.00, 0.90, 0.90},
  },
  --19
  {
    texto    = "Tito é um peixinho dourado que vive em um aquário. Ele adora comer farelos que caem na água. Quando vê sua dona, Tito nada bem rápido.",
    pergunta = "Onde o peixinho Tito vive?",
    opcoes   = {"No rio", "No mar", "No lago", "Em um aquário"},
    correta  = 4,
    bg       = {0.85, 0.95, 1.00},
  },
  --20
  {
    texto    = "Bidu é um cachorro muito bagunceiro. Ele escondeu o sapato do papai no quintal. Depois, Bidu foi dormir na sua casinha.",
    pergunta = "Onde Bidu escondeu o sapato?",
    opcoes   = {"No quarto", "Na sala", "No quintal", "Na cozinha"},
    correta  = 3,
    bg       = {1.00, 0.95, 0.85},
  },
  {
    texto    = "A tartaruga Tita anda bem devagar. Ela leva a sua casa nas costas. Ontem ela comeu uma folha de alface muito verde.",
    pergunta = "O que a tartaruga comeu ontem?",
    opcoes   = {"Uma cenoura", "Uma folha de alface", "Uma maçã", "Um tomate"},
    correta  = 2,
    bg       = {0.90, 1.00, 0.90},
  },
  {
    texto    = "O sapo Zé vive na beira da lagoa. Ele gosta de pular nas vitórias-régias. De noite, Zé canta bem alto para chamar os amigos.",
    pergunta = "Onde o sapo Zé gosta de pular?",
    opcoes   = {"Na terra", "Nas pedras", "Nas árvores", "Nas vitórias-régias"},
    correta  = 4,
    bg       = {0.85, 1.00, 0.88},
  },
  {
    texto    = "O coelho Bolinha tem o pelo branquinho. Ele adora comer cenouras fresquinhas da horta. Quando está assustado, Bolinha esconde as orelhas.",
    pergunta = "O que o coelho Bolinha adora comer?",
    opcoes   = {"Repolho", "Alface", "Cenouras", "Beterraba"},
    correta  = 3,
    bg       = {1.00, 0.90, 0.95},
  },
  {
    texto    = "O urso Pimpão encontrou uma colmeia na floresta. Ele tirou muito mel e comeu até ficar com a barriga cheia. Depois, foi tirar uma soneca.",
    pergunta = "O que o urso Pimpão encontrou na floresta?",
    opcoes   = {"Uma caverna", "Um rio", "Uma colmeia", "Uma árvore de maçãs"},
    correta  = 3,
    bg       = {1.00, 0.95, 0.85},
  },
  {
    texto    = "O porquinho Rosa gosta de rolar na lama depois da chuva. Ele fica todo sujo, mas muito feliz. O fazendeiro sempre dá um banho nele no final do dia.",
    pergunta = "O que o porquinho gosta de fazer depois da chuva?",
    opcoes   = {"Rolar na grama", "Rolar na lama", "Dormir no celeiro", "Comer milho"},
    correta  = 2,
    bg       = {0.95, 0.90, 1.00},
  },
  {
    texto    = "O cavalo Ventania corre muito rápido no pasto. Sua crina voa com o vento. Ele adora comer maçãs que a menina traz para ele.",
    pergunta = "O que o cavalo Ventania adora comer?",
    opcoes   = {"Maçãs", "Cenouras", "Capim", "Milho"},
    correta  = 1,
    bg       = {1.00, 0.90, 0.90},
  },
  {
    texto    = "O macaco Chico pulou de galho em galho até chegar na bananeira. Ele pegou a banana mais amarela de todas e comeu rapidinho.",
    pergunta = "Qual banana o macaco pegou?",
    opcoes   = {"A mais verde", "A mais amarela", "A menor", "A maior"},
    correta  = 2,
    bg       = {1.00, 1.00, 0.85},
  },
  {
    texto    = "O leão é o rei da selva. Ele tem uma juba muito grande e um rugido bem forte. Todos os animais respeitam o leão.",
    pergunta = "Como é o rugido do leão?",
    opcoes   = {"Bem baixo", "Bem fraco", "Bem forte", "Bem afinado"},
    correta  = 3,
    bg       = {1.00, 0.95, 0.85},
  },
  {
    texto    = "A formiguinha Fifi trabalha o dia inteiro. Ela carrega folhas que são maiores que ela para o formigueiro. No inverno, ela tem muita comida guardada.",
    pergunta = "O que a formiguinha carrega para o formigueiro?",
    opcoes   = {"Gravetos", "Pedrinhas", "Folhas", "Areia"},
    correta  = 3,
    bg       = {0.90, 1.00, 0.90},
  },

  {
    texto    = "A coruja Olívia fica acordada a noite toda. Ela tem olhos bem grandes para ver no escuro. De dia, ela dorme no buraco da árvore.",
    pergunta = "Onde a coruja dorme de dia?",
    opcoes   = {"No ninho", "No chão", "No buraco da árvore", "Na caverna"},
    correta  = 3,
    bg       = {0.95, 0.90, 1.00},
  },
  {
    texto    = "Marina acordou cedo para ir ao parque com seu avô. Ela colocou um boné amarelo, pegou uma garrafa de água e saiu sorrindo.",
    pergunta = "O que Marina pegou antes de sair?",
    opcoes   = {"Uma garrafa de água", "Um casaco", "Um guarda-chuva", "Uma bola"},
    correta  = 1,
    bg       = {0.92, 0.98, 0.88},
  },
  {
    texto    = "Na feira, seu Paulo comprou banana, mamão e melancia. A fruta mais pesada foi colocada por último na sacola.",
    pergunta = "Qual fruta foi colocada por último na sacola?",
    opcoes   = {"Banana", "Mamão", "Melancia", "Maçã"},
    correta  = 3,
    bg       = {1.00, 0.94, 0.84},
  },
  {
    texto    = "Lia gosta de desenhar depois do almoço. Hoje ela fez um castelo com torres altas e uma ponte na frente.",
    pergunta = "O que Lia desenhou hoje?",
    opcoes   = {"Um foguete", "Um castelo", "Uma floresta", "Um carro"},
    correta  = 2,
    bg       = {0.90, 0.92, 1.00},
  },
  {
    texto    = "O padeiro abriu a padaria antes do nascer do sol. Ele assou pães quentinhos e colocou tudo na vitrine.",
    pergunta = "O que o padeiro colocou na vitrine?",
    opcoes   = {"Brinquedos", "Livros", "Pães quentinhos", "Flores"},
    correta  = 3,
    bg       = {1.00, 0.90, 0.82},
  },
  {
    texto    = "Joana perdeu seu lápis na sala de aula. Depois de procurar embaixo da mesa, ela encontrou o lápis perto da mochila.",
    pergunta = "Onde Joana encontrou o lápis?",
    opcoes   = {"Na quadra", "Perto da mochila", "Na cozinha", "No ônibus"},
    correta  = 2,
    bg       = {0.88, 0.98, 0.94},
  },
  {
    texto    = "No sítio do tio Bento há galinhas, patos e um cavalo chamado Faísca. Faísca corre pelo campo todas as manhãs.",
    pergunta = "Como se chama o cavalo do tio Bento?",
    opcoes   = {"Trovão", "Brilho", "Faísca", "Pingo"},
    correta  = 3,
    bg       = {1.00, 0.96, 0.86},
  },
  {
    texto    = "Clara levou um livro para ler no ônibus. Durante a viagem, ela sentou perto da janela e viu muitas árvores pelo caminho.",
    pergunta = "Onde Clara sentou no ônibus?",
    opcoes   = {"Perto da porta", "Perto da janela", "No chão", "Ao lado do motorista"},
    correta  = 2,
    bg       = {0.87, 0.93, 1.00},
  },
  {
    texto    = "O relógio da cozinha tocou bem alto ao meio-dia. Mamãe desligou o fogão e serviu o almoço para todos.",
    pergunta = "O que mamãe fez quando o relógio tocou?",
    opcoes   = {"Abriu a janela", "Serviu o almoço", "Foi passear", "Lavou o carro"},
    correta  = 2,
    bg       = {1.00, 0.92, 0.88},
  },
  {
    texto    = "Pedro e Nina montaram uma cabana com lençóis na sala. Depois, entraram com lanternas e fingiram estar em uma floresta.",
    pergunta = "Com o que Pedro e Nina montaram a cabana?",
    opcoes   = {"Com cadeiras e lençóis", "Com tijolos", "Com madeira", "Com almofadas e areia"},
    correta  = 1,
    bg       = {0.93, 0.89, 1.00},
  },
  {
    texto    = "Na aula de ciências, a professora mostrou uma planta de feijão. As crianças viram a raiz, o caule e as folhas verdes.",
    pergunta = "O que as crianças viram na aula de ciências?",
    opcoes   = {"Uma planta de feijão", "Um peixinho dourado", "Uma bola azul", "Uma pipa colorida"},
    correta  = 1,
    bg       = {0.88, 1.00, 0.90},
  },
  {
    texto    = "Rafa ganhou uma bicicleta nova no sábado. Ela é azul, tem cesta na frente e uma campainha barulhenta.",
    pergunta = "O que a bicicleta de Rafa tem na frente?",
    opcoes   = {"Um espelho", "Uma cesta", "Uma mochila", "Uma bandeira"},
    correta  = 2,
    bg       = {0.85, 0.95, 1.00},
  },
  {
    texto    = "Quando acabou a energia, vovô acendeu duas velas na sala. A família ficou contando histórias até a luz voltar.",
    pergunta = "O que vovô acendeu na sala?",
    opcoes   = {"Duas lanternas", "Duas velas", "Uma fogueira", "Um abajur"},
    correta  = 2,
    bg       = {1.00, 0.95, 0.80},
  },
  {
    texto    = "A professora pediu silêncio durante a prova. Miguel terminou primeiro e ficou esperando, sentado bem quietinho.",
    pergunta = "Como Miguel ficou esperando depois de terminar?",
    opcoes   = {"Correndo pela sala", "Falando alto", "Sentado bem quietinho", "Pulando na cadeira"},
    correta  = 3,
    bg       = {0.92, 0.96, 1.00},
  },
  {
    texto    = "No quintal da casa havia um pé de manga carregado. Uma manga madura caiu na grama e fez um barulho fofo.",
    pergunta = "Onde a manga madura caiu?",
    opcoes   = {"No telhado", "Na rua", "Na grama", "Na janela"},
    correta  = 3,
    bg       = {1.00, 0.97, 0.84},
  },
  {
    texto    = "Breno levou seu carrinho vermelho para a casa do amigo. Os dois fizeram uma pista comprida usando caixas de papelão.",
    pergunta = "Que cor era o carrinho de Breno?",
    opcoes   = {"Azul", "Verde", "Amarelo", "Vermelho"},
    correta  = 4,
    bg       = {1.00, 0.88, 0.88},
  },
  {
    texto    = "No aquário da escola vivem três peixes pequenos. Toda sexta-feira, a turma coloca comida em flocos dentro da água.",
    pergunta = "Quando a turma coloca comida no aquário?",
    opcoes   = {"Toda segunda-feira", "Toda sexta-feira", "Todo domingo", "Toda noite"},
    correta  = 2,
    bg       = {0.86, 0.95, 1.00},
  },
  {
    texto    = "A chuva passou e um arco-íris apareceu no céu. Júlia chamou o irmão para ver as cores brilhando acima das casas.",
    pergunta = "O que apareceu no céu depois da chuva?",
    opcoes   = {"Um avião", "Um balão", "Um arco-íris", "Uma estrela"},
    correta  = 3,
    bg       = {0.95, 0.90, 1.00},
  },
  {
    texto    = "Seu Antônio varreu a calçada logo cedo. Depois, molhou as plantas da frente da casa com uma mangueira verde.",
    pergunta = "Com o que seu Antônio molhou as plantas?",
    opcoes   = {"Com um balde azul", "Com uma mangueira verde", "Com uma garrafa pequena", "Com uma panela"},
    correta  = 2,
    bg       = {0.90, 1.00, 0.92},
  },
  {
    texto    = "Na festa da escola, as crianças cantaram no palco e bateram palmas no final. A plateia sorriu e aplaudiu bem forte.",
    pergunta = "O que a plateia fez no final?",
    opcoes   = {"Foi embora correndo", "Dormiu na cadeira", "Aplaudiu bem forte", "Apagou as luzes"},
    correta  = 3,
    bg       = {1.00, 0.92, 0.90},
  },
  {
    texto    = "Helena guardou suas bonecas em uma caixa grande depois de brincar. A caixa ficou embaixo da cama para não atrapalhar a passagem.",
    pergunta = "Onde a caixa com as bonecas ficou guardada?",
    opcoes   = {"Em cima da mesa", "Dentro do armário", "Embaixo da cama", "Na varanda"},
    correta  = 3,
    bg       = {0.96, 0.90, 0.98},
  },
  {
    texto    = "O carteiro passou de bicicleta pela rua e deixou uma carta azul na caixa de correio. Dona Cida abriu a carta depois do café.",
    pergunta = "Que cor era a carta deixada pelo carteiro?",
    opcoes   = {"Branca", "Verde", "Amarela", "Azul"},
    correta  = 4,
    bg       = {0.86, 0.94, 1.00},
  },
  {
    texto    = "Na oficina, o mecânico usou uma chave para apertar a roda da bicicleta. Depois, encheu o pneu com uma bomba de ar.",
    pergunta = "O que o mecânico encheu com a bomba de ar?",
    opcoes   = {"O guidão", "O banco", "O pneu", "A corrente"},
    correta  = 3,
    bg       = {0.92, 0.92, 1.00},
  },
  {
    texto    = "Camila foi ao zoológico e viu macacos, girafas e elefantes. O animal que ela achou mais alto foi a girafa.",
    pergunta = "Qual animal Camila achou mais alto?",
    opcoes   = {"Macaco", "Girafa", "Elefante", "Leão"},
    correta  = 2,
    bg       = {1.00, 0.95, 0.86},
  },
  {
    texto    = "Tomás esqueceu o caderno em casa e ficou preocupado. Seu pai voltou rapidinho e levou o caderno para a escola.",
    pergunta = "O que Tomás esqueceu em casa?",
    opcoes   = {"O lanche", "O tênis", "O caderno", "O boné"},
    correta  = 3,
    bg       = {0.90, 0.96, 1.00},
  },
  {
    texto    = "A abelha voou de flor em flor no jardim. Suas patas ficaram cheias de pólen amarelinho.",
    pergunta = "Por onde a abelha voou?",
    opcoes   = {"De casa em casa", "De flor em flor", "De pedra em pedra", "De nuvem em nuvem"},
    correta  = 2,
    bg       = {1.00, 0.97, 0.82},
  },
  {
    texto    = "Iago levou seu patinete ao parque e colocou capacete antes de brincar. Ele deu voltas na pista até cansar.",
    pergunta = "O que Iago colocou antes de brincar?",
    opcoes   = {"Luvas de boxe", "Capacete", "Cachecol", "Chinelo"},
    correta  = 2,
    bg       = {0.88, 0.95, 1.00},
  },
  {
    texto    = "A panela de sopa ficou no fogo por bastante tempo. Quando ficou pronta, o cheiro gostoso se espalhou pela cozinha.",
    pergunta = "Onde o cheiro da sopa se espalhou?",
    opcoes   = {"Pela garagem", "Pelo quintal", "Pela cozinha", "Pelo telhado"},
    correta  = 3,
    bg       = {1.00, 0.91, 0.84},
  },
  {
    texto    = "No campeonato de corrida, Beto amarrou bem os cadarços antes da largada. Ele queria correr sem tropeçar.",
    pergunta = "Por que Beto amarrou bem os cadarços?",
    opcoes   = {"Para correr sem tropeçar", "Para guardar os tênis", "Para lavar o sapato", "Para jogar bola"},
    correta  = 1,
    bg       = {0.90, 0.98, 0.90},
  },
  {
    texto    = "A lua apareceu redonda no céu escuro. Gustavo puxou a cortina da janela para olhar melhor a noite.",
    pergunta = "Como a lua apareceu no céu?",
    opcoes   = {"Escondida", "Redonda", "Azul", "Pequena demais"},
    correta  = 2,
    bg       = {0.93, 0.91, 1.00},
  },
  {
    texto    = "A cozinheira da escola serviu arroz, feijão e cenoura no almoço. As crianças também ganharam suco de laranja.",
    pergunta = "Que bebida as crianças ganharam?",
    opcoes   = {"Leite", "Água", "Suco de laranja", "Vitamina de banana"},
    correta  = 3,
    bg       = {1.00, 0.96, 0.82},
  },
  {
    texto    = "Fábio montou um quebra-cabeça de cem peças na mesa da varanda. A última peça tinha a cor do céu.",
    pergunta = "Quantas peças tinha o quebra-cabeça?",
    opcoes   = {"Cinquenta", "Setenta", "Noventa", "Cem"},
    correta  = 4,
    bg       = {0.87, 0.95, 1.00},
  },
  {
    texto    = "Na horta da escola, as crianças colheram alface para a salada. Depois, lavaram as folhas com bastante cuidado.",
    pergunta = "O que as crianças colheram na horta?",
    opcoes   = {"Tomate", "Alface", "Batata", "Milho"},
    correta  = 2,
    bg       = {0.90, 1.00, 0.88},
  },
  {
    texto    = "O caminhão de bombeiros chegou com a sirene ligada. Os bombeiros desenrolaram a mangueira para apagar o fogo.",
    pergunta = "O que os bombeiros desenrolaram?",
    opcoes   = {"Uma escada", "Uma corda", "Uma mangueira", "Uma faixa"},
    correta  = 3,
    bg       = {1.00, 0.88, 0.88},
  },
  {
    texto    = "Bianca colocou sementes em um vasinho na janela. Todos os dias ela rega a terra um pouquinho.",
    pergunta = "Onde Bianca colocou as sementes?",
    opcoes   = {"Em um copo", "Em um vasinho na janela", "No quintal do vizinho", "Na pia"},
    correta  = 2,
    bg       = {0.90, 0.98, 0.90},
  },
  {
    texto    = "No museu, as crianças andaram devagar pelos corredores. A monitora pediu que ninguém tocasse nas peças antigas.",
    pergunta = "O que a monitora pediu às crianças?",
    opcoes   = {"Que corressem pelos corredores", "Que tocassem nas peças", "Que ninguém tocasse nas peças antigas", "Que apagassem as luzes"},
    correta  = 3,
    bg       = {0.92, 0.94, 1.00},
  },
  {
    texto    = "Samuel levou pipoca para ver um filme em casa com a família. O filme era de aventura e tinha um mapa do tesouro.",
    pergunta = "Que tipo de filme Samuel viu com a família?",
    opcoes   = {"De terror", "De aventura", "De futebol", "De culinária"},
    correta  = 2,
    bg       = {1.00, 0.94, 0.84},
  },
  {
    texto    = "A professora escreveu a tarefa no quadro com giz branco. Depois, pediu para todos copiarem no caderno.",
    pergunta = "Com o que a professora escreveu no quadro?",
    opcoes   = {"Caneta azul", "Tinta vermelha", "Giz branco", "Lápis preto"},
    correta  = 3,
    bg       = {0.95, 0.95, 1.00},
  },
}

local LIMITE_QUESTOES = 20
local TOTAL        = math.min(#QUESTOES, LIMITE_QUESTOES)
local META_ACERTOS = math.ceil(TOTAL * 0.8)   -- 16 de 20

-- Posição global dos 4 botões de alternativa (na tela de baixo)
-- Tela de baixo: x 640..1279 (640px), y 0..479 (480px)
-- Caixa de pergunta ocupa y 8..135 (128px); botões ocupam y 136..480 (344px / 2 linhas)
-- box pergunta: y=24 h=120 → fim=144; botões a partir de 152; dois rows + gap=8 + margin=24
-- altura de cada row: (480-152-8-24)/2 = 148
local BTNS = {
  {x = 664, y = 152, w = 292, h = 148},  -- A  (superior esquerdo)
  {x = 964, y = 152, w = 292, h = 148},  -- B  (superior direito)
  {x = 664, y = 308, w = 292, h = 148},  -- C  (inferior esquerdo)
  {x = 964, y = 308, w = 292, h = 148},  -- D  (inferior direito)
}
local LABELS = {"A", "B", "C", "D"}

local COR_BTN_TXT  = {0.10, 0.14, 0.32}
local COR_CORRETO  = {0.22, 0.82, 0.36}
local COR_ERRADO   = {0.88, 0.24, 0.24}
local COR_CORRETO_TXT = {1, 1, 1}
local COR_ERRADO_TXT  = {1, 1, 1}

-- ═══════════════════════════════════════════════════════════════════════════
--  ESTADO
-- ═══════════════════════════════════════════════════════════════════════════
local STARTUP_DELAY = 0.3    -- tela preta enquanto o sway reposiciona a janela
local startup_timer = 0

local INPUT_DELAY  = 0.4     -- cooldown após troca de estado, evita toque fantasma
local input_timer  = 0

local estado     = "intro"   -- intro | questao | feedback | resultado
local ordem      = {}
local idx        = 1
local acertos    = 0
local escolha    = 0         -- botão selecionado (1-4), 0 = nenhum
local t_feedback = 0
local FB_DUR     = 1.8       -- segundos mostrando feedback antes de avançar

-- Fontes (carregadas em love.load)
local f_body   -- 31px — texto de leitura
local f_ui     -- 27px — pergunta
local f_btn    -- 26px — alternativas nos botões
local f_big    -- 48px — títulos e destaques
local f_huge   -- 99px — placar final
local f_sm     -- 20px — indicadores secundários (progresso, etc.)

-- Sons (gerados em love.load)
local snd_click, snd_correto, snd_errado

-- ═══════════════════════════════════════════════════════════════════════════
--  UTILITÁRIOS
-- ═══════════════════════════════════════════════════════════════════════════
local function rrect(x, y, w, h, r, mode)
  love.graphics.rectangle(mode or "fill", x, y, w, h, r, r)
end

local function questao()
  return QUESTOES[ordem[idx]]
end

local function shuffle(t)
  for i = #t, 2, -1 do
    local j = love.math.random(i)
    t[i], t[j] = t[j], t[i]
  end
end

local function play(snd)
  if snd then snd:stop(); snd:play() end
end


-- Gera um tom sintético simples
local function make_tone(freq, dur, vol, waveform)
  local rate = 44100
  local n    = math.floor(rate * dur)
  local sd   = love.sound.newSoundData(n, rate, 16, 1)
  for i = 0, n - 1 do
    local t   = i / rate
    local env = math.min(1, t / 0.005) * math.min(1, (dur - t) / 0.04)
    local s
    if waveform == "square" then
      s = (math.sin(2 * math.pi * freq * t) >= 0) and 1.0 or -1.0
    else
      s = math.sin(2 * math.pi * freq * t)
    end
    sd:setSample(i, s * env * vol)
  end
  return love.audio.newSource(sd, "static")
end

-- Gera uma sequência de notas
local function make_seq(notes, vol)
  local rate    = 44100
  local total   = 0
  for _, n in ipairs(notes) do total = total + math.floor(rate * n.dur) end
  local sd      = love.sound.newSoundData(total, rate, 16, 1)
  local cursor  = 0
  for _, note in ipairs(notes) do
    local n = math.floor(rate * note.dur)
    for i = 0, n - 1 do
      local t   = i / rate
      local env = math.min(1, t / 0.008) * math.min(1, (note.dur - t) / 0.05)
      local s   = note.freq > 0 and math.sin(2 * math.pi * note.freq * t) or 0
      sd:setSample(cursor + i, s * env * vol)
    end
    cursor = cursor + n
  end
  return love.audio.newSource(sd, "static")
end

-- ═══════════════════════════════════════════════════════════════════════════
--  LOVE.LOAD
-- ═══════════════════════════════════════════════════════════════════════════
function love.load()
  f_body = love.graphics.newFont(28)
  f_ui   = love.graphics.newFont(27)
  f_btn  = love.graphics.newFont(26)
  f_big  = love.graphics.newFont(48)
  f_huge = love.graphics.newFont(99)
  f_sm   = love.graphics.newFont(20)

  -- click: toque sutil de alta frequência
  snd_click   = make_tone(1100, 0.06, 0.35, "sine")
  -- correto: arpegio ascendente animado
  snd_correto = make_seq({
    {freq=523, dur=0.10},  -- C5
    {freq=659, dur=0.10},  -- E5
    {freq=784, dur=0.18},  -- G5
  }, 0.55)
  -- errado: nota grave descendente
  snd_errado  = make_seq({
    {freq=300, dur=0.12},
    {freq=220, dur=0.20},
  }, 0.55)

  for i = 1, #QUESTOES do ordem[i] = i end
  shuffle(ordem)

  while #ordem > TOTAL do
    table.remove(ordem)
  end
end

-- ═══════════════════════════════════════════════════════════════════════════
--  LOVE.UPDATE
-- ═══════════════════════════════════════════════════════════════════════════
function love.update(dt)
  startup_timer = startup_timer + dt
  if startup_timer < STARTUP_DELAY then return end

  input_timer = input_timer + dt

  if estado == "feedback" then
    t_feedback = t_feedback + dt
    if t_feedback >= FB_DUR then
      t_feedback = 0
      escolha    = 0
      if idx < TOTAL then
        idx    = idx + 1
        estado = "questao"
      else
        estado = "resultado"
      end
    end
  end
end

-- ═══════════════════════════════════════════════════════════════════════════
--  DRAW — helpers
-- ═══════════════════════════════════════════════════════════════════════════

-- Tela de cima: fundo + card com borda arredondada
local function draw_card_top(bg, content_fn, card_color)
  love.graphics.setColor(bg)
  love.graphics.rectangle("fill", 0, 0, 640, 480)

  -- sombra leve
  love.graphics.setColor(0, 0, 0, 0.12)
  rrect(19, 19, 610, 450, 22)

  -- card
  love.graphics.setColor(card_color or {1, 1, 1, 0.94})
  rrect(15, 15, 610, 450, 20)

  -- borda suave
  love.graphics.setColor(0, 0, 0, 0.08)
  love.graphics.setLineWidth(1.5)
  rrect(15, 15, 610, 450, 20, "line")

  content_fn()
end

local function draw_tela_cima()
  local q = questao()

  if estado == "feedback" then
    -- tela de cima vira um painel grande de acerto/erro
    local acertou = (escolha == q.correta)
    local bg  = acertou and {0.15, 0.72, 0.30} or {0.82, 0.18, 0.18}
    local txt = acertou and "Acertou!" or "Errou!"

    love.graphics.setColor(bg)
    love.graphics.rectangle("fill", 0, 0, 640, 480)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(f_huge)
    love.graphics.printf(txt, 0, 480/2 - f_huge:getHeight()/2, 640, "center")
    return
  end

  draw_card_top({0.12, 0.22, 0.55}, function()
    -- indicador de progresso
    love.graphics.setFont(f_sm)
    love.graphics.setColor(0.30, 0.45, 0.75)
    love.graphics.printf(
      string.format("Pergunta %d de %d", idx, TOTAL),
      40, 26, 560, "right"
    )

    -- texto principal de leitura
    love.graphics.setFont(f_body)
    love.graphics.setColor(0.08, 0.12, 0.28)
    love.graphics.printf(q.texto, 40, 90, 560, "left")
  end, {0.88, 0.94, 1.00})
end

local function draw_tela_baixo()
  local q = questao()

  if estado == "feedback" then
    love.graphics.setColor(0.14, 0.14, 0.18)
    love.graphics.rectangle("fill", 640, 0, 640, 480)
    love.graphics.setColor(0.55, 0.58, 0.65)
    love.graphics.setFont(f_ui)
    love.graphics.printf(
      "Carregando próxima pergunta...",
      640, 480/2 - f_ui:getHeight()/2, 640, "center"
    )
    return
  end

  local cor_bg  = {0.12, 0.22, 0.55}
  local cor_box = {0.46, 0.56, 0.88}
  local cor_btn = {0.88, 0.94, 1.00}

  -- fundo
  love.graphics.setColor(cor_bg)
  love.graphics.rectangle("fill", 640, 0, 640, 480)

  -- box da pergunta (médio pastel)
  love.graphics.setColor(cor_box)
  rrect(664, 24, 592, 120, 14)
  love.graphics.setColor(0.12, 0.12, 0.22)
  love.graphics.setFont(f_ui)
  love.graphics.printf(q.pergunta, 676, 36, 568, "left")

  -- 4 botões de alternativa
  for i, btn in ipairs(BTNS) do
    local bc = cor_btn
    local tc = COR_BTN_TXT

    if estado == "feedback" then
      if i == q.correta then
        bc = COR_CORRETO
        tc = COR_CORRETO_TXT
      elseif i == escolha then
        bc = COR_ERRADO
        tc = COR_ERRADO_TXT
      end
    end

    -- sombra do botão
    love.graphics.setColor(0, 0, 0, 0.10)
    rrect(btn.x + 2, btn.y + 3, btn.w, btn.h, 14)

    -- corpo do botão
    love.graphics.setColor(bc)
    rrect(btn.x, btn.y, btn.w, btn.h, 14)

    -- borda
    love.graphics.setColor(0, 0, 0, 0.12)
    love.graphics.setLineWidth(1.5)
    rrect(btn.x, btn.y, btn.w, btn.h, 14, "line")

    -- texto centrado verticalmente (comporta até 2 linhas com fonte maior)
    love.graphics.setColor(tc)
    love.graphics.setFont(f_btn)
    local txt = LABELS[i] .. ")  " .. q.opcoes[i]
    local ty  = btn.y + math.floor(btn.h / 2 - f_btn:getHeight())
    love.graphics.printf(txt, btn.x + 12, ty, btn.w - 24, "center")
  end
end

local function draw_intro()
  -- ── Tela de cima ──────────────────────────────────────────────────────
  draw_card_top({0.90, 0.92, 1.00}, function()
    love.graphics.setFont(f_body)
    love.graphics.setColor(0.10, 0.10, 0.20)
    love.graphics.printf(
      "Olá, Gustavo!\n\n" ..
      "Você vai ler 20 textos curtos e responder uma pergunta sobre cada um.\n\n" ..
      "Para ganhar, precisa acertar pelo menos 16 de 20 perguntas (80%).\n\n" ..
      "Leia com calma e boa sorte!",
      55, 80, 530, "left"
    )
  end)

  -- ── Tela de baixo ─────────────────────────────────────────────────────
  love.graphics.setColor(0.75, 0.80, 1.00)
  love.graphics.rectangle("fill", 640, 0, 640, 480)

  -- sombra do botão grande
  love.graphics.setColor(0, 0, 0, 0.15)
  rrect(724, 162, 480, 158, 22)

  -- botão de início
  love.graphics.setColor(0.28, 0.52, 0.95)
  rrect(720, 158, 480, 158, 22)

  love.graphics.setColor(1, 1, 1)
  love.graphics.setFont(f_big)
  love.graphics.printf("Toque aqui\npara começar!", 720, 186, 480, "center")
end

local function draw_resultado()
  local pct    = math.floor(acertos / TOTAL * 100 + 0.5)
  local passou = acertos >= META_ACERTOS

  local bg_top = passou and {0.82, 1.00, 0.86} or {1.00, 0.88, 0.82}
  local bg_bot = passou and {0.52, 0.88, 0.58} or {0.90, 0.55, 0.52}
  local ink    = passou and {0.06, 0.36, 0.13} or {0.36, 0.08, 0.05}

  -- ── Tela de cima ──────────────────────────────────────────────────────
  draw_card_top(bg_top, function()
    love.graphics.setFont(f_big)
    love.graphics.setColor(ink)
    local titulo = passou and "Parabéns, Gustavo!" or "Quase lá, Gustavo!"
    love.graphics.printf(titulo, 40, 52, 560, "center")

    love.graphics.setFont(f_huge)
    love.graphics.setColor(ink)
    love.graphics.printf(
      string.format("%d / %d", acertos, TOTAL),
      40, 112, 560, "center"
    )

    love.graphics.setFont(f_body)
    love.graphics.setColor(0.12, 0.12, 0.18)
    local msg
    if passou then
      msg = string.format(
        "Você acertou %d%% das perguntas!\n\n" ..
        "Você passou no teste de leitura!\n\n" ..
        "Parabéns — o videogame é seu!",
        pct
      )
    else
      msg = string.format(
        "Você acertou %d%% das perguntas.\n\n" ..
        "Precisava de 80%% para passar.\n\n" ..
        "Continue praticando!\n" ..
        "Tente de novo na semana que vem.",
        pct
      )
    end
    love.graphics.printf(msg, 55, 235, 530, "center")
  end)

  -- ── Tela de baixo ─────────────────────────────────────────────────────
  love.graphics.setColor(bg_bot)
  love.graphics.rectangle("fill", 640, 0, 640, 480)

  love.graphics.setColor(1, 1, 1, 0.92)
  love.graphics.setFont(f_big)
  local bot_msg = passou
    and "Uhuuu!\nVocê conseguiu!"
    or  "Foi por pouco!\nNa próxima você passa!"
  love.graphics.printf(bot_msg, 640, 175, 640, "center")

  -- dica de saída
  love.graphics.setFont(f_sm)
  love.graphics.setColor(1, 1, 1, 0.60)
  love.graphics.printf("Pressione Start para sair", 640, 448, 640, "center")
end

-- ═══════════════════════════════════════════════════════════════════════════
--  LOVE.DRAW
-- ═══════════════════════════════════════════════════════════════════════════
function love.draw()
  if startup_timer < STARTUP_DELAY then
    love.graphics.clear(0, 0, 0)
    return
  end

  love.graphics.setBackgroundColor(0.14, 0.14, 0.18)

  if estado == "intro" then
    draw_intro()
  elseif estado == "questao" or estado == "feedback" then
    draw_tela_cima()
    draw_tela_baixo()
  elseif estado == "resultado" then
    draw_resultado()
  end
end

-- ═══════════════════════════════════════════════════════════════════════════
--  TOUCH
-- ═══════════════════════════════════════════════════════════════════════════
local function handle_press(x, y)
  if input_timer < INPUT_DELAY then return end

  if estado == "intro" then
    if x >= 640 then
      estado      = "questao"
      input_timer = 0
    end
    return
  end

  if estado == "questao" then
    for i, btn in ipairs(BTNS) do
      if x >= btn.x and x < btn.x + btn.w and
         y >= btn.y and y < btn.y + btn.h then
        play(snd_click)
        escolha    = i
        local q    = questao()
        if i == q.correta then
          acertos = acertos + 1
          play(snd_correto)
        else
          play(snd_errado)
        end
        estado      = "feedback"
        t_feedback  = 0
        input_timer = 0
        return
      end
    end
  end
end

function love.touchpressed(_, x, y)
  handle_press(x, y)
end

-- fallback para mouse no PC durante desenvolvimento
function love.mousepressed(x, y, btn)
  if btn == 1 then handle_press(x, y) end
end

-- ═══════════════════════════════════════════════════════════════════════════
--  TECLADO
-- ═══════════════════════════════════════════════════════════════════════════
-- gamepad: Select/Back fecha o jogo em qualquer estado
function love.gamepadpressed(_, button)
  if button == "back" then
    love.event.quit()
  end
end

function love.keypressed(k)
  if k == "escape" then
    love.event.quit()
  end

  if estado == "intro" and (k == "return" or k == "space" or k == "a") then
    estado = "questao"
    return
  end

  if estado == "questao" then
    -- atalhos numéricos para dev (PC)
    local map = {["1"]=1, ["2"]=2, ["3"]=3, ["4"]=4}
    local i = map[k]
    if i then
      escolha    = i
      local q    = questao()
      if i == q.correta then acertos = acertos + 1 end
      estado     = "feedback"
      t_feedback = 0
    end
  end
end
