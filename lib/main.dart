
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

const roxo = Color(0xFF7952B5);
const roxoEscuro = Color(0xFF603A9B);
const roxoClaro = Color(0xFFF0E9FA);
const fundo = Color(0xFFF8F5FC);

void main() => runApp(const PetAlertaApp());

class PetAlertaApp extends StatelessWidget {
  const PetAlertaApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'PetAlerta',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: roxo),
      scaffoldBackgroundColor: fundo,
      appBarTheme: const AppBarTheme(
        backgroundColor: fundo,
        foregroundColor: roxoEscuro,
        elevation: 0,
      ),
    ),
    home: const PetHome(),
  );
}

class Pet {
  Pet({
    required this.id,
    required this.nome,
    required this.especie,
    required this.local,
    required this.status,
    required this.descricao,
    this.foto = '',
    this.arquivoFoto,
    this.contato = '',
    this.data = '',
  });

  String id, nome, especie, local, status, descricao, foto;
  String? arquivoFoto;
  String contato, data;

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'especie': especie,
    'local': local,
    'status': status,
    'descricao': descricao,
    'foto': foto,
    'arquivoFoto': arquivoFoto,
    'contato': contato,
    'data': data,
  };

  factory Pet.fromJson(Map<String, dynamic> j) => Pet(
    id: j['id'] ?? '',
    nome: j['nome'] ?? 'Animal',
    especie: j['especie'] ?? 'Outro',
    local: j['local'] ?? '',
    status: j['status'] ?? 'Perdido',
    descricao: j['descricao'] ?? '',
    foto: j['foto'] ?? '',
    arquivoFoto: j['arquivoFoto'],
    contato: j['contato'] ?? '',
    data: j['data'] ?? '',
  );
}

class PetHome extends StatefulWidget {
  const PetHome({super.key});

  @override
  State<PetHome> createState() => _PetHomeState();
}

class _PetHomeState extends State<PetHome> {
  int pagina = 0;
  String busca = '';
  String filtro = 'Todos';
  bool carregando = true;
  final Set<String> favoritos = {};
  final List<Pet> cadastrados = [];

  final List<Pet> animais = [
    Pet(id: '1', nome: 'Max', especie: 'Cachorro', local: 'Centro',
        status: 'Perdido', descricao: 'Carinhoso e brincalhão.',
        foto: 'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=800&q=85'),
    Pet(id: '2', nome: 'Luna', especie: 'Gato', local: 'Jardim das Flores',
        status: 'Encontrado', descricao: 'Gatinha tranquila encontrada perto de uma praça.',
        foto: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=800&q=85'),
    Pet(id: '3', nome: 'Thor', especie: 'Cachorro', local: 'Vila Nova',
        status: 'Perdido', descricao: 'Cão cheio de energia.',
        foto: 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=800&q=85'),
    Pet(id: '4', nome: 'Mimi', especie: 'Gato', local: 'Jardim América',
        status: 'Encontrado', descricao: 'Gatinha dócil encontrada na vizinhança.',
        foto: 'https://images.unsplash.com/photo-1573865526739-10659fec78a5?auto=format&fit=crop&w=800&q=85'),
    Pet(id: '5', nome: 'Bidu', especie: 'Cachorro', local: 'Parque Central',
        status: 'Perdido', descricao: 'Cão amigável e sociável.',
        foto: 'https://images.unsplash.com/photo-1551717743-49959800b1f6?auto=format&fit=crop&w=800&q=85'),
    Pet(id: '6', nome: 'Nina', especie: 'Gato', local: 'Vila Verde',
        status: 'Encontrado', descricao: 'Gatinha que precisa reencontrar sua família.',
        foto: 'https://images.unsplash.com/photo-1495360010541-f48722b34f7d?auto=format&fit=crop&w=800&q=85'),
    Pet(id: '7', nome: 'Bob', especie: 'Cachorro', local: 'Jardim Sul',
        status: 'Perdido', descricao: 'Cão companheiro.',
        foto: 'https://images.unsplash.com/photo-1517849845537-4d257902454a?auto=format&fit=crop&w=800&q=85'),
    Pet(id: '8', nome: 'Amora', especie: 'Gato', local: 'Centro',
        status: 'Encontrado', descricao: 'Gatinha encontrada perto de residências.',
        foto: 'https://images.unsplash.com/photo-1533738363-b7f9aef128ce?auto=format&fit=crop&w=800&q=85'),
    Pet(id: '9', nome: 'Pipoca', especie: 'Cachorro', local: 'Vila Nova',
        status: 'Perdido', descricao: 'Pequena companheira que faz falta em casa.',
        foto: 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?auto=format&fit=crop&w=800&q=85'),
    Pet(id: '10', nome: 'Tom', especie: 'Gato', local: 'Jardim das Flores',
        status: 'Encontrado', descricao: 'Gatinho que aguarda sua família.',
        foto: 'https://images.unsplash.com/photo-1495360010541-f48722b34f7d?auto=format&fit=crop&w=800&q=85'),
    Pet(id: '11', nome: 'Mel', especie: 'Cachorro', local: 'Parque Central',
        status: 'Perdido', descricao: 'Muito querida pela família.',
        foto: 'https://images.unsplash.com/photo-1518717758536-85ae29035b6d?auto=format&fit=crop&w=800&q=85'),
    Pet(id: '12', nome: 'Chico', especie: 'Pássaro', local: 'Vila Verde',
        status: 'Encontrado', descricao: 'Pássaro encontrado. Procura-se seu responsável.',
        foto: 'https://images.unsplash.com/photo-1444464666168-49d633b86797?auto=format&fit=crop&w=800&q=85'),
  ];

  List<Pet> get todos => [...cadastrados, ...animais];

  List<Pet> get filtrados {
    Iterable<Pet> lista = todos;
    if (pagina == 2) {
      lista = lista.where((p) => favoritos.contains(p.id));
    } else if (filtro != 'Todos') {
      lista = lista.where((p) => p.status == filtro);
    }
    if (busca.trim().isNotEmpty) {
      final q = busca.toLowerCase();
      lista = lista.where((p) =>
      p.nome.toLowerCase().contains(q) ||
          p.especie.toLowerCase().contains(q) ||
          p.local.toLowerCase().contains(q));
    }
    return lista.toList();
  }

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    favoritos.addAll(prefs.getStringList('petalerta_favoritos') ?? []);
    for (final item in prefs.getStringList('petalerta_cadastros') ?? []) {
      try {
        cadastrados.add(Pet.fromJson(jsonDecode(item)));
      } catch (_) {}
    }
    if (mounted) setState(() => carregando = false);
  }

  Future<void> salvarFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('petalerta_favoritos', favoritos.toList());
  }

  Future<void> salvarCadastros() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('petalerta_cadastros',
        cadastrados.map((p) => jsonEncode(p.toJson())).toList());
  }

  Future<void> cadastrar() async {
    final pet = await Navigator.push<Pet>(
      context,
      MaterialPageRoute(builder: (_) => const CadastroPetPage()),
    );
    if (pet == null || !mounted) return;
    setState(() {
      cadastrados.insert(0, pet);
      pagina = 1;
      filtro = 'Todos';
      busca = '';
    });
    await salvarCadastros();
  }

  Future<void> favoritar(Pet pet) async {
    setState(() {
      if (!favoritos.add(pet.id)) favoritos.remove(pet.id);
    });
    await salvarFavoritos();
  }

  void detalhes(Pet pet) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => DetalhesPetPage(
        pet: pet,
        favorito: favoritos.contains(pet.id),
        aoFavoritar: () => favoritar(pet),
      ),
    )).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [
          CircleAvatar(
            backgroundColor: roxo,
            child: Icon(Icons.pets_rounded, color: Colors.white),
          ),
          SizedBox(width: 10),
          Text('PetAlerta',
              style: TextStyle(color: roxo, fontWeight: FontWeight.w900)),
        ]),
        actions: [
          IconButton(
            tooltip: 'Cadastrar animal',
            onPressed: cadastrar,
            icon: const Icon(Icons.add_circle_rounded, color: roxo, size: 30),
          ),
        ],
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator(color: roxo))
          : IndexedStack(
        index: pagina,
        children: [
          inicio(),
          animaisPage(),
          favoritosPage(),
          quemSomos(),
        ],
      ),
      floatingActionButton: pagina == 3 ? null : FloatingActionButton.extended(
        onPressed: cadastrar,
        backgroundColor: roxo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_a_photo_rounded),
        label: const Text('Cadastrar pet'),
      ),
      bottomNavigationBar: NavigationBar(
        height: 72,
        backgroundColor: Colors.white,
        indicatorColor: roxoClaro,
        selectedIndex: pagina,
        onDestinationSelected: (i) => setState(() {
          pagina = i;
          busca = '';
          filtro = 'Todos';
        }),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded, color: roxo), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.pets_outlined), selectedIcon: Icon(Icons.pets_rounded, color: roxo), label: 'Animais'),
          NavigationDestination(icon: Icon(Icons.favorite_border_rounded), selectedIcon: Icon(Icons.favorite_rounded, color: roxo), label: 'Favoritos'),
          NavigationDestination(icon: Icon(Icons.info_outline_rounded), selectedIcon: Icon(Icons.info_rounded, color: roxo), label: 'Quem somos'),
        ],
      ),
    );
  }

  Widget inicio() {
    final destaques = todos.take(6).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [roxo, roxoEscuro]),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Juntos, podemos trazer eles de volta!',
                    style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                const Text('Encontre animais perdidos e ajude a reunir famílias.',
                    style: TextStyle(color: Colors.white, height: 1.4)),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: cadastrar,
                  style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: roxo),
                  icon: const Icon(Icons.add),
                  label: const Text('Anunciar animal'),
                ),
              ],
            )),
            const SizedBox(width: 8),
            const Mascote(tamanho: 66),
          ]),
        ),
        const SizedBox(height: 18),
        TextField(
          onChanged: (v) => setState(() => busca = v),
          onTap: () => setState(() => pagina = 1),
          decoration: InputDecoration(
            hintText: 'Buscar nome, espécie ou local...',
            prefixIcon: const Icon(Icons.search, color: roxo),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 22),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Encontre um amigo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          TextButton(onPressed: () => setState(() => pagina = 1), child: const Text('Ver todos')),
        ]),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.65,
          children: [
            atalho(Icons.search_rounded, 'Procurar pet', 'Veja os anúncios', () => setState(() => pagina = 1)),
            atalho(Icons.campaign_outlined, 'Animal perdido', 'Ajude na busca', () => setState(() { pagina = 1; filtro = 'Perdido'; })),
            atalho(Icons.favorite_outline_rounded, 'Encontrado', 'Ajude uma família', () => setState(() { pagina = 1; filtro = 'Encontrado'; })),
            atalho(Icons.add_a_photo_outlined, 'Cadastrar pet', 'Publique um anúncio', cadastrar),
          ],
        ),
        const SizedBox(height: 22),
        const Text('Animais em destaque', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        GridView.builder(
          itemCount: destaques.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 12, childAspectRatio: 0.66,
          ),
          itemBuilder: (_, i) => PetCard(
            pet: destaques[i],
            favorito: favoritos.contains(destaques[i].id),
            aoTocar: () => detalhes(destaques[i]),
            aoFavoritar: () => favoritar(destaques[i]),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: roxoClaro, borderRadius: BorderRadius.circular(20)),
          child: const Row(children: [
            Icon(Icons.volunteer_activism_rounded, color: roxo, size: 34),
            SizedBox(width: 12),
            Expanded(child: Text('Sua ajuda faz diferença! Compartilhe anúncios e ajude animais a voltar para casa.',
                style: TextStyle(height: 1.4, fontWeight: FontWeight.w600))),
          ]),
        ),
      ],
    );
  }

  Widget atalho(IconData icone, String titulo, String subtitulo, VoidCallback acao) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: acao,
        borderRadius: BorderRadius.circular(17),
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(color: roxoClaro, borderRadius: BorderRadius.circular(12)),
              child: Icon(icone, color: roxo, size: 23),
            ),
            const SizedBox(width: 9),
            Expanded(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                const SizedBox(height: 4),
                Text(subtitulo, style: const TextStyle(color: Colors.black54, fontSize: 10)),
              ],
            )),
          ]),
        ),
      ),
    );
  }

  Widget animaisPage() => ListView(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
    children: [
      const Text('Todos os animais', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      const Text('Pesquise e encontre os anúncios da comunidade.'),
      const SizedBox(height: 16),
      TextField(
        onChanged: (v) => setState(() => busca = v),
        decoration: const InputDecoration(
          hintText: 'Nome, espécie ou local',
          prefixIcon: Icon(Icons.search, color: roxo),
          filled: true, fillColor: Colors.white,
        ),
      ),
      const SizedBox(height: 12),
      Wrap(spacing: 8, children: ['Todos', 'Perdido', 'Encontrado'].map((f) =>
          ChoiceChip(
            label: Text(f), selected: filtro == f,
            selectedColor: roxoClaro,
            onSelected: (_) => setState(() => filtro = f),
          )).toList()),
      const SizedBox(height: 14),
      if (filtrados.isEmpty)
        const Padding(padding: EdgeInsets.all(30), child: Center(child: Text('Nenhum animal encontrado.')))
      else
        GridView.builder(
          itemCount: filtrados.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 12, childAspectRatio: 0.66,
          ),
          itemBuilder: (_, i) => PetCard(
            pet: filtrados[i],
            favorito: favoritos.contains(filtrados[i].id),
            aoTocar: () => detalhes(filtrados[i]),
            aoFavoritar: () => favoritar(filtrados[i]),
          ),
        ),
    ],
  );

  Widget favoritosPage() {
    final lista = todos.where((p) => favoritos.contains(p.id)).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        const Text('Seus favoritos', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        const Text('Guarde os animais que deseja acompanhar.'),
        const SizedBox(height: 18),
        if (lista.isEmpty)
          const Column(children: [
            SizedBox(height: 55),
            Icon(Icons.favorite_border_rounded, size: 75, color: roxo),
            SizedBox(height: 12),
            Text('Nenhum favorito ainda', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            SizedBox(height: 6),
            Text('Toque no coração de um animal para salvá-lo.'),
          ])
        else
          GridView.builder(
            itemCount: lista.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 12, childAspectRatio: 0.66,
            ),
            itemBuilder: (_, i) => PetCard(
              pet: lista[i], favorito: true,
              aoTocar: () => detalhes(lista[i]),
              aoFavoritar: () => favoritar(lista[i]),
            ),
          ),
      ],
    );
  }

  Widget quemSomos() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 35),
    children: [
      const Center(child: Mascote(tamanho: 100)),
      const SizedBox(height: 14),
      const Center(child: Text('Quem somos', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: roxo))),
      const SizedBox(height: 12),
      const Text('O PetAlerta é um projeto criado para aproximar pessoas e ajudar animais perdidos a reencontrarem suas famílias.',
          textAlign: TextAlign.center, style: TextStyle(height: 1.6)),
      const SizedBox(height: 22),
      info(Icons.flag_outlined, 'Nossa missão', 'Ajudar na divulgação de animais perdidos e encontrados.'),
      info(Icons.groups_outlined, 'Nossa comunidade', 'A colaboração entre pessoas pode ajudar animais a reencontrar suas famílias.'),
      info(Icons.phone_android_rounded, 'Como funciona', 'Cadastre um animal, adicione uma foto, informe o local e os dados de contato.'),
      info(Icons.favorite_outline_rounded, 'Nosso compromisso', 'Incentivar empatia, responsabilidade e cuidado com os animais.'),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: roxoClaro, borderRadius: BorderRadius.circular(20)),
        child: const Text('PetAlerta — juntos, podemos fazer a diferença!',
            textAlign: TextAlign.center, style: TextStyle(color: roxoEscuro, fontWeight: FontWeight.w900)),
      ),
    ],
  );

  Widget info(IconData icone, String titulo, String texto) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icone, color: roxo, size: 26),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(titulo, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        Text(texto, style: const TextStyle(height: 1.45, color: Colors.black54)),
      ])),
    ]),
  );
}

class PetCard extends StatelessWidget {
  const PetCard({
    super.key, required this.pet, required this.favorito,
    required this.aoTocar, required this.aoFavoritar,
  });

  final Pet pet;
  final bool favorito;
  final VoidCallback aoTocar, aoFavoritar;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(19),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: aoTocar,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Stack(fit: StackFit.expand, children: [
          PetImagem(pet: pet),
          Positioned(
            top: 8, left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: pet.status == 'Perdido' ? const Color(0xFFFFE5E1) : roxoClaro,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(pet.status, style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w800,
                color: pet.status == 'Perdido' ? Colors.red.shade800 : roxoEscuro,
              )),
            ),
          ),
          Positioned(
            top: 4, right: 4,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              child: IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: aoFavoritar,
                icon: Icon(favorito ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: favorito ? Colors.red : roxo, size: 21),
              ),
            ),
          ),
        ])),
        Padding(
          padding: const EdgeInsets.fromLTRB(11, 9, 11, 11),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(pet.nome, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text('${pet.especie} • ${pet.local}', maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: Colors.black54)),
            const SizedBox(height: 6),
            const Row(children: [
              Icon(Icons.location_on_outlined, size: 14, color: roxo),
              SizedBox(width: 3),
              Text('Ver informações', style: TextStyle(fontSize: 11, color: roxo)),
            ]),
          ]),
        ),
      ]),
    ),
  );
}

class PetImagem extends StatelessWidget {
  const PetImagem({super.key, required this.pet});
  final Pet pet;

  @override
  Widget build(BuildContext context) {
    if (pet.arquivoFoto != null && pet.arquivoFoto!.isNotEmpty) {
      final arquivo = File(pet.arquivoFoto!);
      if (arquivo.existsSync()) {
        return Image.file(arquivo, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const FotoReserva());
      }
    }
    if (pet.foto.isNotEmpty) {
      return Image.network(
        pet.foto,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const FotoReserva(),
        loadingBuilder: (_, child, progress) =>
        progress == null ? child : const FotoReserva(carregando: true),
      );
    }
    return const FotoReserva();
  }
}

class FotoReserva extends StatelessWidget {
  const FotoReserva({super.key, this.carregando = false});
  final bool carregando;

  @override
  Widget build(BuildContext context) => Container(
    color: roxoClaro,
    child: Center(
      child: carregando
          ? const CircularProgressIndicator(color: roxo)
          : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 76, height: 76,
          decoration: const BoxDecoration(color: Color(0xFFDCCCF5), shape: BoxShape.circle),
          child: const Icon(Icons.pets_rounded, size: 42, color: roxo),
        ),
        const SizedBox(height: 8),
        const Text('Foto indisponível',
            style: TextStyle(color: roxo, fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
    ),
  );
}

class DetalhesPetPage extends StatefulWidget {
  const DetalhesPetPage({
    super.key, required this.pet, required this.favorito, required this.aoFavoritar,
  });
  final Pet pet;
  final bool favorito;
  final Future<void> Function() aoFavoritar;

  @override
  State<DetalhesPetPage> createState() => _DetalhesPetPageState();
}

class _DetalhesPetPageState extends State<DetalhesPetPage> {
  late bool favorito;

  @override
  void initState() {
    super.initState();
    favorito = widget.favorito;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pet;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do animal'),
        actions: [
          IconButton(
            onPressed: () async {
              await widget.aoFavoritar();
              if (mounted) setState(() => favorito = !favorito);
            },
            icon: Icon(favorito ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: favorito ? Colors.red : roxo),
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.only(bottom: 30), children: [
        SizedBox(height: 300, child: PetImagem(pet: p)),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Chip(label: Text(p.status), backgroundColor: roxoClaro, avatar: const Icon(Icons.pets, color: roxo)),
            const SizedBox(height: 8),
            Text(p.nome, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            linha(Icons.pets, 'Espécie', p.especie),
            linha(Icons.location_on_outlined, 'Local', p.local),
            if (p.data.isNotEmpty) linha(Icons.calendar_today, 'Data', p.data),
            if (p.contato.isNotEmpty) linha(Icons.phone_outlined, 'Contato', p.contato),
            const SizedBox(height: 12),
            const Text('Sobre o animal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(p.descricao.isEmpty ? 'Nenhuma descrição informada.' : p.descricao,
                style: const TextStyle(height: 1.6, fontSize: 15)),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: roxo, padding: const EdgeInsets.all(15)),
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Entre em contato'),
                    content: Text(p.contato.isEmpty
                        ? 'Este anúncio ainda não tem contato informado.'
                        : 'Contato do responsável: ${p.contato}'),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar'))],
                  ),
                ),
                icon: const Icon(Icons.volunteer_activism_rounded),
                label: const Text('Quero ajudar'),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget linha(IconData icon, String titulo, String valor) => Padding(
    padding: const EdgeInsets.only(bottom: 13),
    child: Row(children: [
      Icon(icon, color: roxo),
      const SizedBox(width: 10),
      Text('$titulo: ', style: const TextStyle(fontWeight: FontWeight.w800)),
      Expanded(child: Text(valor)),
    ]),
  );
}

class CadastroPetPage extends StatefulWidget {
  const CadastroPetPage({super.key});

  @override
  State<CadastroPetPage> createState() => _CadastroPetPageState();
}

class _CadastroPetPageState extends State<CadastroPetPage> {
  final chave = GlobalKey<FormState>();
  final nome = TextEditingController();
  final local = TextEditingController();
  final descricao = TextEditingController();
  final contato = TextEditingController();
  final data = TextEditingController();

  String especie = 'Cachorro';
  String status = 'Perdido';
  XFile? foto;

  @override
  void dispose() {
    nome.dispose();
    local.dispose();
    descricao.dispose();
    contato.dispose();
    data.dispose();
    super.dispose();
  }

  Future<void> escolherFoto(ImageSource source) async {
    try {
      final imagem = await ImagePicker().pickImage(
        source: source, imageQuality: 80, maxWidth: 1400,
      );
      if (imagem != null && mounted) setState(() => foto = imagem);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir a câmera ou galeria.')),
        );
      }
    }
  }

  Future<void> opcoesFoto() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(child: Wrap(children: [
        const Padding(
          padding: EdgeInsets.all(18),
          child: Text('Adicionar foto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        ),
        ListTile(
          leading: const Icon(Icons.camera_alt_rounded, color: roxo),
          title: const Text('Tirar foto com a câmera'),
          onTap: () { Navigator.pop(ctx); escolherFoto(ImageSource.camera); },
        ),
        ListTile(
          leading: const Icon(Icons.photo_library_rounded, color: roxo),
          title: const Text('Escolher da galeria'),
          onTap: () { Navigator.pop(ctx); escolherFoto(ImageSource.gallery); },
        ),
      ])),
    );
  }

  Widget campo(String titulo, TextEditingController controller, {
    IconData? icone, bool obrigatorio = false, int linhas = 1,
  }) => TextFormField(
    controller: controller,
    maxLines: linhas,
    decoration: InputDecoration(
      labelText: titulo,
      prefixIcon: icone == null ? null : Icon(icone, color: roxo),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
    ),
    validator: obrigatorio
        ? (v) => v == null || v.trim().isEmpty ? 'Preencha este campo.' : null
        : null,
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Cadastrar animal')),
    body: Form(
      key: chave,
      child: ListView(padding: const EdgeInsets.all(20), children: [
        const Text('Ajude um animal a encontrar seu caminho.',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
        const SizedBox(height: 7),
        const Text('Preencha os dados para publicar um anúncio.'),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: opcoesFoto,
          child: Container(
            height: 190,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(color: roxoClaro, borderRadius: BorderRadius.circular(20)),
            child: foto == null
                ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.add_a_photo_rounded, size: 44, color: roxo),
              SizedBox(height: 10),
              Text('Adicionar foto do animal', style: TextStyle(fontWeight: FontWeight.w800)),
              SizedBox(height: 4),
              Text('Toque para abrir câmera ou galeria'),
            ])
                : Image.file(File(foto!.path), fit: BoxFit.cover, width: double.infinity),
          ),
        ),
        const SizedBox(height: 18),
        campo('Nome do animal', nome, icone: Icons.pets, obrigatorio: true),
        const SizedBox(height: 13),
        DropdownButtonFormField<String>(
          value: especie,
          decoration: const InputDecoration(labelText: 'Espécie', filled: true, fillColor: Colors.white),
          items: ['Cachorro', 'Gato', 'Pássaro', 'Outro'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => setState(() => especie = v ?? 'Cachorro'),
        ),
        const SizedBox(height: 13),
        DropdownButtonFormField<String>(
          value: status,
          decoration: const InputDecoration(labelText: 'Situação', filled: true, fillColor: Colors.white),
          items: ['Perdido', 'Encontrado'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => setState(() => status = v ?? 'Perdido'),
        ),
        const SizedBox(height: 13),
        campo('Local onde foi visto', local, icone: Icons.location_on_outlined, obrigatorio: true),
        const SizedBox(height: 13),
        campo('Data (opcional)', data, icone: Icons.calendar_today),
        const SizedBox(height: 13),
        campo('Contato do responsável', contato, icone: Icons.phone_outlined, obrigatorio: true),
        const SizedBox(height: 13),
        campo('Descrição do animal', descricao, icone: Icons.description_outlined, linhas: 4),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: roxo, padding: const EdgeInsets.all(16)),
            onPressed: () {
              if (!chave.currentState!.validate()) return;
              Navigator.pop(context, Pet(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                nome: nome.text.trim(),
                especie: especie,
                local: local.text.trim(),
                status: status,
                descricao: descricao.text.trim(),
                arquivoFoto: foto?.path,
                contato: contato.text.trim(),
                data: data.text.trim(),
              ));
            },
            icon: const Icon(Icons.check_circle_outline_rounded),
            label: const Text('Publicar anúncio'),
          ),
        ),
      ]),
    ),
  );
}

class Mascote extends StatelessWidget {
  const Mascote({super.key, this.tamanho = 85});
  final double tamanho;

  @override
  Widget build(BuildContext context) => Container(
    width: tamanho,
    height: tamanho,
    decoration: BoxDecoration(
      color: roxoClaro,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 2),
    ),
    child: Stack(alignment: Alignment.center, children: [
      Icon(Icons.pets_rounded, size: tamanho * 0.60, color: roxo),
      Positioned(
        right: tamanho * 0.04,
        bottom: tamanho * 0.04,
        child: Container(
          padding: EdgeInsets.all(tamanho * 0.06),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Icon(Icons.favorite_rounded, color: roxo, size: tamanho * 0.20),
        ),
      ),
    ]),
  );
}
