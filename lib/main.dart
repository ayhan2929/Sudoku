import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const SudokuApp());

const gold = Color(0xFFD6B46A);
const brightGold = Color(0xFFFFD36B);
const night = Color(0xFF080B12);
const panel = Color(0xE91B1D22);
const white = Color(0xFFF7F2E8);
const muted = Color(0xFFB9B6B0);

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Sudoku', debugShowCheckedModeBanner: false,
    theme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: night,
      colorScheme: const ColorScheme.dark(primary: gold, secondary: brightGold), useMaterial3: true),
    home: const HomeScreen(),
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => GameBackground(child: SafeArea(
    child: LayoutBuilder(builder: (context, c) => SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
      child: ConstrainedBox(constraints: BoxConstraints(minHeight: c.maxHeight-20),
        child: Column(children: [
          Align(alignment: Alignment.topRight, child: IconButton(
            onPressed: () => showDialog(context: context, builder: (_) => const InfoDialog()),
            icon: const Icon(Icons.info_outline, color: brightGold))),
          const SizedBox(height: 2),
          const Brand(),
          const SizedBox(height: 25),
          MenuCard(icon: Icons.play_arrow_rounded, title: 'Klasik Sudoku',
            subtitle: 'İstediğin zorlukta bulmaca oyna.', onTap: () => go(context, const DifficultyScreen()), primary: true),
          const SizedBox(height: 12),
          MenuCard(icon: Icons.calendar_month_rounded, title: 'Günlük Sudoku',
            subtitle: 'Her gün yeni bir bulmaca çöz.', onTap: () => go(context, const DailyScreen())),
          const SizedBox(height: 12),
          MenuCard(icon: Icons.bar_chart_rounded, title: 'İstatistikler',
            subtitle: 'Oyun performansını izle.', onTap: () => go(context, const StatsScreen())),
          const SizedBox(height: 12),
          MenuCard(icon: Icons.settings_rounded, title: 'Ayarlar',
            subtitle: 'Oyun deneyimini kişiselleştir.', onTap: () => go(context, const SettingsScreen())),
          const Spacer(),
          const SizedBox(height: 26),
          const Text('Ayhan Kayaoğlu', style: TextStyle(color: brightGold, fontSize: 13,
            fontStyle: FontStyle.italic, letterSpacing: 1, shadows: [Shadow(color: gold, blurRadius: 8)])),
        ]),
      ),
    )),
  ));
}

void go(BuildContext context, Widget page) => Navigator.push(context, MaterialPageRoute(builder: (_) => page));

class Brand extends StatelessWidget {
  const Brand({super.key});
  @override
  Widget build(BuildContext context) => Column(children: [
    const Icon(Icons.workspace_premium_rounded, color: brightGold, size: 45),
    Container(width: 112, height: 112, decoration: BoxDecoration(
      border: Border.all(color: brightGold, width: 2), borderRadius: BorderRadius.circular(22),
      color: const Color(0xAA080B12), boxShadow: const [BoxShadow(color: Color(0x88FFB52E), blurRadius: 20)]),
      child: const Center(child: Icon(Icons.grid_4x4_rounded, color: brightGold, size: 72))),
    const SizedBox(height: 9),
    const FittedBox(child: Text('SUDOKU', style: TextStyle(fontSize: 54, height: 1,
      letterSpacing: 5, fontWeight: FontWeight.w900, color: brightGold,
      shadows: [Shadow(color: gold, blurRadius: 20)]))),
    const SizedBox(height: 12),
    Container(width: 180, height: 2, decoration: const BoxDecoration(
      gradient: LinearGradient(colors: [Colors.transparent, brightGold, Colors.transparent]))),
  ]);
}

class MenuCard extends StatelessWidget {
  final IconData icon; final String title, subtitle; final VoidCallback onTap; final bool primary;
  const MenuCard({super.key, required this.icon, required this.title, required this.subtitle,
    required this.onTap, this.primary=false});
  @override
  Widget build(BuildContext context) => Material(color: Colors.transparent, child: InkWell(
    onTap: onTap, borderRadius: BorderRadius.circular(20), child: Ink(
      padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: panel,
        borderRadius: BorderRadius.circular(20), border: Border.all(color: primary ? brightGold : const Color(0xFF9A7440), width: primary ? 2 : 1)),
      child: Row(children: [
        Container(width: 52, height: 52, decoration: BoxDecoration(color: gold.withOpacity(.13), borderRadius: BorderRadius.circular(15)),
          child: Icon(icon, color: brightGold, size: 32)),
        const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: white, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 3), Text(subtitle, style: const TextStyle(color: muted, fontSize: 12)),
        ])), const Icon(Icons.chevron_right, color: brightGold, size: 28),
      ]),
    ),
  ));
}

class GameBackground extends StatelessWidget {
  final Widget child;
  const GameBackground({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Stack(fit: StackFit.expand, children: [
    const _Scenery(), child,
  ]);
}

class _Scenery extends StatelessWidget {
  const _Scenery();
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _ScenePainter());
}
class _ScenePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final rect=Offset.zero & s;
    canvas.drawRect(rect, Paint()..shader=const LinearGradient(begin: Alignment.topCenter,end: Alignment.bottomCenter,
      colors:[Color(0xFF050912),Color(0xFF172131),Color(0xFF28252A),Color(0xFF080C13)]).createShader(rect));
    final star=Paint()..color=const Color(0xFFFFD98A);
    for(int i=0;i<80;i++){ final x=(i*73.7)%s.width; final y=(i*37.3)%(s.height*.42); canvas.drawCircle(Offset(x,y), i%4==0?1.3:.7,star); }
    final moon=Offset(s.width*.82,s.height*.12);
    canvas.drawCircle(moon,25,Paint()..color=const Color(0xFFFFD98A).withOpacity(.8));
    void mountain(double base, Color color, double offset){
      final p=Path()..moveTo(0,base);
      for(int i=0;i<=6;i++){final x=i*s.width/6; p.lineTo(x+s.width/12,base-s.height*(.09+((i*17+offset.toInt())%5)*.018)); p.lineTo(x+s.width/6,base);}
      p.lineTo(s.width,s.height);p.lineTo(0,s.height);p.close();canvas.drawPath(p,Paint()..color=color);
    }
    mountain(s.height*.38,const Color(0xFF202A3A),1);
    mountain(s.height*.45,const Color(0xFF101A29),3);
    canvas.drawRect(Rect.fromLTWH(0,s.height*.84,s.width,s.height*.16),Paint()..color=const Color(0xCC050A12));
    final glow=Paint()..shader=RadialGradient(colors:[gold.withOpacity(.22),Colors.transparent]).createShader(
      Rect.fromCircle(center:Offset(s.width*.5,s.height*.86),radius:s.width*.45));
    canvas.drawCircle(Offset(s.width*.5,s.height*.86),s.width*.45,glow);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate)=>false;
}

class PageShell extends StatelessWidget {
  final String title; final Widget child;
  const PageShell({super.key, required this.title, required this.child});
  @override
  Widget build(BuildContext context)=>Scaffold(body:GameBackground(child:SafeArea(child:Column(children:[
    Padding(padding:const EdgeInsets.fromLTRB(8,4,18,8),child:Row(children:[
      IconButton(onPressed:()=>Navigator.pop(context),icon:const Icon(Icons.arrow_back_ios_new,color:gold)),
      Expanded(child:Text(title,textAlign:TextAlign.center,style:const TextStyle(color:brightGold,fontWeight:FontWeight.w900,letterSpacing:1.4,fontSize:18))),
      const SizedBox(width:48),
    ])),
    Expanded(child:child),
  ])))));
}

class DifficultyScreen extends StatelessWidget {
  const DifficultyScreen({super.key});
  static const names=['Başlangıç','Kolay','Orta','Zor','Uzman','Efsane'];
  static const desc=['Sudoku ile yeni tanışanlar için','Temel mantık adımları','Dengeli bir meydan okuma','Daha dikkatli ve planlı ilerle','İleri seviye Sudoku','Ustalığını kanıtlama zamanı'];
  @override
  Widget build(BuildContext context)=>PageShell(title:'ZORLUK SEÇİMİ',child:Column(children:[
    const SizedBox(height:12),const Icon(Icons.grid_4x4,color:brightGold,size:42),
    const Text('Seviyeni belirle',style:TextStyle(color:white,fontSize:24,fontWeight:FontWeight.bold)),
    const Text('Her seviyede yeni bir meydan okuma.',style:TextStyle(color:muted,fontSize:12)),
    const SizedBox(height:18),
    Expanded(child:ListView.separated(padding:const EdgeInsets.fromLTRB(20,0,20,22),itemCount:6,
      separatorBuilder:(_,__)=>const SizedBox(height:10),itemBuilder:(context,i)=>MenuCard(
        icon:[Icons.spa,Icons.sentiment_satisfied,Icons.psychology,Icons.local_fire_department,Icons.workspace_premium,Icons.diamond][i],
        title:names[i],subtitle:desc[i],onTap:()=>go(context,GameScreen(level:names[i])),primary:i==0))),
  ]));
}


class GameScreen extends StatefulWidget {
  final String level;
  final bool daily;
  const GameScreen({super.key, this.level='Orta', this.daily=false});
  @override State<GameScreen> createState()=>_GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<List<int>> board, givens, solution;
  int? row, col;
  bool notes=false, loading=true, paused=false;
  int mistakes=0, hints=0, seconds=0;
  final Map<String,Set<int>> pencil={};
  final List<Map<String,dynamic>> history=[];
  static const _saveKey='sudoku_active_game_v2';
  static const _statsKey='sudoku_stats_v2';
  static const _levels=['Başlangıç','Kolay','Orta','Zor','Uzman','Efsane'];

  @override void initState(){super.initState(); _loadOrCreate();}
  String get time=>'${(seconds~/60).toString().padLeft(2,'0')}:${(seconds%60).toString().padLeft(2,'0')}';
  int get clueCount=>[45,38,32,28,25,22][_levels.indexOf(widget.level).clamp(0,5).toInt()];

  Future<void> _loadOrCreate() async {
    final prefs=await SharedPreferences.getInstance();
    final raw=prefs.getString(_saveKey);
    if(raw!=null) {
      try {
        final data=jsonDecode(raw) as Map<String,dynamic>;
        final same=data['level']==widget.level && data['daily']==widget.daily &&
          (!widget.daily || data['date']==_today());
        if(same) {
          board=_matrix(data['board']); givens=_matrix(data['givens']); solution=_matrix(data['solution']);
          seconds=data['seconds']??0; mistakes=data['mistakes']??0; hints=data['hints']??0;
          final p=data['pencil'] as Map<String,dynamic>? ?? {};
          p.forEach((k,v)=>pencil[k]=(v as List).cast<int>().toSet());
        } else { _newPuzzle(); }
      } catch (_) { _newPuzzle(); }
    } else { _newPuzzle(); }
    if(mounted){setState(()=>loading=false); _clock();}
    await _save();
  }
  List<List<int>> _matrix(dynamic value)=>(value as List).map((r)=>(r as List).cast<int>()).toList();
  String _today(){final d=DateTime.now();return '${d.year}-${d.month}-${d.day}';}
  void _newPuzzle(){
    final seed=widget.daily?int.parse(_today().replaceAll('-','')):DateTime.now().microsecondsSinceEpoch;
    final full=_generateSolution(seed);
    solution=full.map((r)=>[...r]).toList();
    givens=full.map((r)=>[...r]).toList();
    final random=Random(seed);
    final cells=List<int>.generate(81,(i)=>i)..shuffle(random);
    final targetClues=clueCount;
    var clues=81;
    for(final index in cells){
      if(clues<=targetClues)break;
      final r=index~/9,c=index%9,backup=givens[r][c];
      givens[r][c]=0;
      if(_countSolutions(givens,limit:2)==1){clues--;}else{givens[r][c]=backup;}
    }
    board=givens.map((r)=>[...r]).toList();
    seconds=0;mistakes=0;hints=0;row=null;col=null;pencil.clear();history.clear();
  }
  List<List<int>> _generateSolution(int seed){
    final rng=Random(seed);
    final rows=[0,1,2].map((b){final x=[0,1,2]..shuffle(rng);return x.map((v)=>b*3+v).toList();}).expand((x)=>x).toList();
    final cols=[0,1,2].map((b){final x=[0,1,2]..shuffle(rng);return x.map((v)=>b*3+v).toList();}).expand((x)=>x).toList();
    final nums=[1,2,3,4,5,6,7,8,9]..shuffle(rng);
    int pattern(int r,int c)=>(3*(r%3)+r~/3+c)%9;
    return List.generate(9,(r)=>List.generate(9,(c)=>nums[pattern(rows[r],cols[c])] ));
  }

  int _countSolutions(List<List<int>> source,{int limit=2}){
    final grid=source.map((r)=>[...r]).toList();
    bool allowed(int r,int c,int n){
      for(int i=0;i<9;i++){if(grid[r][i]==n||grid[i][c]==n)return false;}
      final br=r~/3*3,bc=c~/3*3;
      for(int y=br;y<br+3;y++)for(int x=bc;x<bc+3;x++){if(grid[y][x]==n)return false;}
      return true;
    }
    int search(){
      var bestR=-1,bestC=-1;List<int>? best;
      for(int r=0;r<9;r++)for(int c=0;c<9;c++){
        if(grid[r][c]!=0)continue;
        final candidates=<int>[];
        for(int n=1;n<=9;n++){if(allowed(r,c,n))candidates.add(n);}
        if(candidates.isEmpty)return 0;
        if(best==null||candidates.length<best.length){best=candidates;bestR=r;bestC=c;}
        if(best.length==1)break;
      }
      if(bestR==-1)return 1;
      var count=0;
      for(final n in best!){
        grid[bestR][bestC]=n;
        count+=search();
        if(count>=limit){grid[bestR][bestC]=0;return count;}
      }
      grid[bestR][bestC]=0;
      return count;
    }
    return search();
  }
  Future<void> _clock() async {
    while(mounted){await Future.delayed(const Duration(seconds:1));if(mounted&&!paused&&!loading){setState(()=>seconds++);_save();}}
  }
  Future<void> _save() async {
    if(loading)return;
    final prefs=await SharedPreferences.getInstance();
    await prefs.setString(_saveKey,jsonEncode({
      'level':widget.level,'daily':widget.daily,'date':_today(),
      'board':board,'givens':givens,'solution':solution,'seconds':seconds,
      'mistakes':mistakes,'hints':hints,
      'pencil':pencil.map((k,v)=>MapEntry(k,v.toList())),
    }));
  }
  bool fixed(int r,int c)=>givens[r][c]!=0;
  bool conflict(int r,int c,int n){
    for(int i=0;i<9;i++){if(i!=c&&board[r][i]==n)return true;if(i!=r&&board[i][c]==n)return true;}
    for(int y=r~/3*3;y<r~/3*3+3;y++)for(int x=c~/3*3;x<c~/3*3+3;x++){
      if((y!=r||x!=c)&&board[y][x]==n)return true;
    }
    return false;
  }
  bool get complete=>List.generate(9,(r)=>List.generate(9,(c)=>board[r][c]==solution[r][c]).every((v)=>v)).every((v)=>v);
  Future<void> enter(int n) async {
    if(row==null||col==null||fixed(row!,col!))return;
    final r=row!,c=col!;
    setState((){
      if(notes){final k='$r,$c';pencil.putIfAbsent(k,()=>{});if(pencil[k]!.contains(n)){pencil[k]!.remove(n);}else{pencil[k]!.add(n);}}
      else{
        history.add({'r':r,'c':c,'old':board[r][c],'mistakes':mistakes,'pencil':(pencil['$r,$c']??{}).toList()});
        board[r][c]=n;pencil.remove('$r,$c');
        if(n!=solution[r][c])mistakes++;
      }
    });
    await _save();
    if(complete)await _finish();
  }
  Future<void> erase() async {
    if(row==null||col==null||fixed(row!,col!))return;
    final r=row!,c=col!;
    setState((){
      history.add({'r':r,'c':c,'old':board[r][c],'mistakes':mistakes,'pencil':(pencil['$r,$c']??{}).toList()});
      board[r][c]=0;pencil.remove('$r,$c');
    });await _save();
  }
  Future<void> undo() async {
    if(history.isEmpty)return;
    final m=history.removeLast();
    setState((){
      final r=m['r'] as int,c=m['c'] as int;
      board[r][c]=m['old'] as int;
      mistakes=m['mistakes'] as int? ?? mistakes;
      final oldNotes=(m['pencil'] as List?)?.cast<int>() ?? [];
      if(oldNotes.isNotEmpty)pencil['$r,$c']=oldNotes.toSet();else{pencil.remove('$r,$c');}
    });await _save();
  }
  Future<void> hint() async {
    if(row==null||col==null||fixed(row!,col!))return;
    final r=row!,c=col!;
    setState((){
      history.add({'r':r,'c':c,'old':board[r][c],'mistakes':mistakes,'pencil':(pencil['$r,$c']??{}).toList()});
      board[r][c]=solution[r][c];pencil.remove('$r,$c');
      hints++;
    });
    await _save();if(complete)await _finish();
  }
  Future<void> _finish() async {
    final prefs=await SharedPreferences.getInstance();
    final stats=jsonDecode(prefs.getString(_statsKey)??'{}') as Map<String,dynamic>;
    stats['played']=(stats['played']??0)+1;stats['solved']=(stats['solved']??0)+1;
    stats['seconds']=(stats['seconds']??0)+seconds;
    stats['byLevel'] ??= <String,int>{};
    final by=Map<String,dynamic>.from(stats['byLevel'] as Map);by[widget.level]=(by[widget.level]??0)+1;stats['byLevel']=by;
    if(widget.daily){
      final today=_today();
      final last=stats['lastDailyDate'] as String?;
      final solvedDates=(stats['dailySolvedDates'] as List? ?? []).cast<String>().toSet();
      if(!solvedDates.contains(today)){
        final yesterday=DateTime.now().subtract(const Duration(days:1));
        final y='${yesterday.year}-${yesterday.month}-${yesterday.day}';
        final streak=last==today?(stats['dailyStreak']??1) as int:(last==y?((stats['dailyStreak']??0) as int)+1:1);
        stats['dailyStreak']=streak;
        stats['bestDailyStreak']=max((stats['bestDailyStreak']??0) as int,streak);
        stats['lastDailyDate']=today;
        solvedDates.add(today);
        stats['dailySolvedDates']=solvedDates.toList()..sort();
      }
    }
    await prefs.setString(_statsKey,jsonEncode(stats));await prefs.remove(_saveKey);
    if(!mounted)return;
    setState(()=>paused=true);
    Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>SuccessScreen(level:widget.level,time:time,mistakes:mistakes)));
  }
  Future<void> confirmNew() async {
    final yes=await showDialog<bool>(context:context,builder:(d)=>AlertDialog(backgroundColor:const Color(0xFF191B20),
      title:const Text('Yeni Oyun Başlat'),content:const Text('Mevcut oyunun ilerlemesi kalıcı olarak silinecek. Bu işlem geri alınamaz.'),
      actions:[TextButton(onPressed:()=>Navigator.pop(d,false),child:const Text('Vazgeç ve devam et')),
        FilledButton(onPressed:()=>Navigator.pop(d,true),child:const Text('Yeni oyuna başla'))]));
    if(yes==true){final p=await SharedPreferences.getInstance();await p.remove(_saveKey);if(!mounted)return;Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>GameScreen(level:widget.level,daily:widget.daily)));}
  }
  void pause(){
    setState(()=>paused=true);
    showDialog(context:context,builder:(d)=>AlertDialog(backgroundColor:const Color(0xFF191B20),
    title:const Text('Oyun Duraklatıldı'),content:Text('Süre: $time\nHatalar: $mistakes/3\nZorluk: ${widget.level}'),
    actions:[
      TextButton(onPressed:(){setState(()=>paused=false);Navigator.pop(d);},child:const Text('Oyuna devam et')),
      TextButton(onPressed:(){Navigator.pop(d);confirmNew();},child:const Text('Yeni oyun başlat')),
      TextButton(onPressed:(){Navigator.pop(d);Navigator.push(context,MaterialPageRoute(builder:(_)=>const SettingsScreen()));},child:const Text('Ayarlar')),
      TextButton(onPressed:(){Navigator.pop(d);Navigator.pop(context);},child:const Text('Ana sayfa')),
    ])).then((_) {if(mounted)setState(()=>paused=false);});
  }
  @override Widget build(BuildContext context){
    if(loading)return const Scaffold(backgroundColor:night,body:Center(child:CircularProgressIndicator(color:gold)));
    return Scaffold(backgroundColor:Colors.transparent,body:GameBackground(child:SafeArea(child:Column(children:[
      Padding(padding:const EdgeInsets.symmetric(horizontal:12,vertical:5),child:Row(children:[
        IconButton(onPressed:()=>Navigator.pop(context),icon:const Icon(Icons.arrow_back,color:gold)),
        Expanded(child:Column(children:[Text(widget.daily?'GÜNLÜK SUDOKU':'KLASİK SUDOKU',style:const TextStyle(color:brightGold,fontWeight:FontWeight.bold,letterSpacing:1.2)),
          Text(widget.level,style:const TextStyle(color:muted,fontSize:11))])),
        IconButton(onPressed:pause,icon:const Icon(Icons.pause_circle_outline,color:gold)),
      ])),
      Padding(padding:const EdgeInsets.symmetric(horizontal:28,vertical:4),child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
        _metric('SÜRE',time),_metric('HATALAR','$mistakes'),_metric('İPUCU','$hints'),
      ])),
      Expanded(child:Center(child:AspectRatio(aspectRatio:1,child:Container(margin:const EdgeInsets.all(12),
        decoration:BoxDecoration(border:Border.all(color:gold,width:1.3),borderRadius:BorderRadius.circular(5),color:const Color(0xCC10141D)),
        child:Column(children:List.generate(9,(r)=>Expanded(child:Row(children:List.generate(9,(c){
          final n=board[r][c],selected=row==r&&col==c;
          final related=row==r||col==c||(row!=null&&col!=null&&row!~/3==r~/3&&col!~/3==c~/3);
          final bad=n!=0&&n!=solution[r][c];
          final notesText=(pencil['$r,$c']??{}).toList()..sort();
          return Expanded(child:GestureDetector(onTap:()=>setState((){row=r;col=c;}),child:Container(
            alignment:Alignment.center,
            decoration:BoxDecoration(color:selected?const Color(0xFF594725):related?const Color(0x332D3A4C):Colors.transparent,
              border:Border(right:BorderSide(color:c==2||c==5?gold:Colors.white12,width:c==2||c==5?1.5:.45),
                bottom:BorderSide(color:r==2||r==5?gold:Colors.white12,width:r==2||r==5?1.5:.45))),
            child:Text(n==0?notesText.join(''):'$n',style:TextStyle(fontSize:n==0?9:20,
              color:bad?Colors.redAccent:(fixed(r,c)?white:brightGold),fontWeight:fixed(r,c)?FontWeight.bold:FontWeight.w500)),
          )));
        })))))))),
      )),
      Padding(padding:const EdgeInsets.symmetric(horizontal:12,vertical:7),child:Row(children:[
        _tool(Icons.edit_note,'Not',notes,()=>setState(()=>notes=!notes)),
        _tool(Icons.undo,'Geri al',false,undo),
        _tool(Icons.lightbulb_outline,'İpucu',false,hint),
        _tool(Icons.delete_outline,'Sil',false,erase),
      ])),
      Padding(padding:const EdgeInsets.fromLTRB(8,4,8,12),child:Row(children:List.generate(9,(i)=>Expanded(child:Padding(
        padding:const EdgeInsets.symmetric(horizontal:2),child:Material(color:panel,borderRadius:BorderRadius.circular(8),
          child:InkWell(onTap:()=>enter(i+1),child:Container(height:47,alignment:Alignment.center,
            child:Text('${i+1}',style:const TextStyle(color:brightGold,fontSize:19,fontWeight:FontWeight.bold)))))))))),
      const Padding(padding:EdgeInsets.only(bottom:5),child:Text('Ayhan Kayaoğlu',style:TextStyle(color:brightGold,fontSize:10,fontStyle:FontStyle.italic))),
    ]))));
  }
  Widget _metric(String a,String b)=>Column(children:[Text(a,style:const TextStyle(color:muted,fontSize:9)),Text(b,style:const TextStyle(color:brightGold,fontSize:17,fontWeight:FontWeight.bold))]);
  Widget _tool(IconData icon,String label,bool active,VoidCallback tap)=>Expanded(child:InkWell(onTap:tap,child:Column(children:[
    Icon(icon,color:active?brightGold:gold),Text(label,style:const TextStyle(color:muted,fontSize:10))])));
}

class SuccessScreen extends StatelessWidget {
  final String level,time; final int mistakes;
  const SuccessScreen({super.key,required this.level,required this.time,required this.mistakes});
  @override Widget build(BuildContext context)=>PageShell(title:'TEBRİKLER',child:Center(child:Padding(padding:const EdgeInsets.all(24),child:Column(
    mainAxisAlignment:MainAxisAlignment.center,children:[
      const Icon(Icons.emoji_events_rounded,color:brightGold,size:88),
      const SizedBox(height:18),const Text('BULMACA TAMAMLANDI!',textAlign:TextAlign.center,style:TextStyle(color:brightGold,fontSize:25,fontWeight:FontWeight.w900)),
      const SizedBox(height:10),const Text('Harika iş çıkardın. Bir sonraki meydan okumaya hazır mısın?',textAlign:TextAlign.center,style:TextStyle(color:muted)),
      const SizedBox(height:25),Row(children:[
        Expanded(child:StatCard(label:'SÜRE',value:time,icon:Icons.timer)),
        const SizedBox(width:10),Expanded(child:StatCard(label:'HATA',value:'$mistakes',icon:Icons.rule)),
      ]),
      const SizedBox(height:10),StatCard(label:'ZORLUK',value:level,icon:Icons.grid_4x4),
      const SizedBox(height:25),GoldButton(label:'YENİ OYUN',icon:Icons.play_arrow,onTap:()=>Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>const DifficultyScreen()))),
      TextButton(onPressed:()=>Navigator.popUntil(context,(r)=>r.isFirst),child:const Text('ANA SAYFAYA DÖN',style:TextStyle(color:gold))),
    ])))));
}

class DailyScreen extends StatefulWidget {
  const DailyScreen({super.key});
  @override State<DailyScreen> createState()=>_DailyScreenState();
}
class _DailyScreenState extends State<DailyScreen>{
  int streak=0,best=0;
  Set<String> solved={};
  bool loading=true;
  @override void initState(){super.initState();_load();}
  String _date(DateTime d)=>'${d.year}-${d.month}-${d.day}';
  Future<void> _load() async {
    final p=await SharedPreferences.getInstance();
    final raw=p.getString('sudoku_stats_v2');
    if(raw!=null){try{
      final m=jsonDecode(raw) as Map<String,dynamic>;
      streak=m['dailyStreak']??0;best=m['bestDailyStreak']??0;
      solved=(m['dailySolvedDates'] as List? ?? []).cast<String>().toSet();
    }catch(_){}}
    if(mounted)setState(()=>loading=false);
  }
  @override Widget build(BuildContext context){
    final now=DateTime.now();
    return PageShell(title:'GÜNLÜK SUDOKU',child:loading
      ?const Center(child:CircularProgressIndicator(color:gold))
      :ListView(padding:const EdgeInsets.all(20),children:[
        const Icon(Icons.calendar_month,color:brightGold,size:55),
        const Text('Bugünün Bulmacası',textAlign:TextAlign.center,style:TextStyle(color:white,fontSize:23,fontWeight:FontWeight.bold)),
        const SizedBox(height:8),const Text('Her gün aynı tarihte aynı bulmaca. Serini koru!',textAlign:TextAlign.center,style:TextStyle(color:muted)),
        const SizedBox(height:20),Row(children:[
          Expanded(child:StatCard(label:'GÜNLÜK SERİ',value:'$streak gün',icon:Icons.local_fire_department)),
          const SizedBox(width:10),Expanded(child:StatCard(label:'EN UZUN SERİ',value:'$best gün',icon:Icons.emoji_events)),
        ]),
        const SizedBox(height:20),
        GoldButton(label:solved.contains(_date(now))?'BUGÜN TAMAMLANDI':'BUGÜNÜN BULMACASINI OYNA',
          icon:solved.contains(_date(now))?Icons.check_circle:Icons.play_arrow,
          onTap:()=>go(context,const GameScreen(daily:true,level:'Orta'))),
        const SizedBox(height:24),const Text('AYLIK İLERLEME',style:TextStyle(color:brightGold,fontWeight:FontWeight.bold,letterSpacing:1)),
        const SizedBox(height:10),CalendarCard(month:now,solved:solved),
      ]));
  }
}

class CalendarCard extends StatelessWidget {
  final DateTime month;final Set<String> solved;
  const CalendarCard({super.key,required this.month,required this.solved});
  String _date(DateTime d)=>'${d.year}-${d.month}-${d.day}';
  @override Widget build(BuildContext context){
    final first=DateTime(month.year,month.month,1);
    final offset=(first.weekday+6)%7;
    final days=DateUtils.getDaysInMonth(month.year,month.month);
    final count=((offset+days+6)~/7)*7;
    const weekdays=['P','S','Ç','P','C','C','P'];
    return Container(padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:panel,borderRadius:BorderRadius.circular(18),border:Border.all(color:gold.withOpacity(.6))),
      child:Column(children:[
        Text('${_monthName(month.month)} ${month.year}',style:const TextStyle(color:white,fontWeight:FontWeight.bold,fontSize:17)),
        const SizedBox(height:12),Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children:weekdays.map((x)=>Text(x,style:const TextStyle(color:gold,fontWeight:FontWeight.bold))).toList()),
        const SizedBox(height:8),
        ...List.generate(count~/7,(r)=>Padding(padding:const EdgeInsets.symmetric(vertical:4),child:Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children:List.generate(7,(c){
          final day=r*7+c-offset+1;
          if(day<1||day>days)return const SizedBox(width:32,height:32);
          final d=DateTime(month.year,month.month,day);
          final done=solved.contains(_date(d));
          final today=DateUtils.isSameDay(d,DateTime.now());
          return Container(width:32,height:32,alignment:Alignment.center,decoration:BoxDecoration(shape:BoxShape.circle,
            color:done?gold.withOpacity(.28):Colors.transparent,border:today?Border.all(color:brightGold):done?Border.all(color:gold):null),
            child:Text('$day',style:TextStyle(color:done?brightGold:white,fontSize:12,fontWeight:done?FontWeight.bold:FontWeight.normal)));
        })))),
      ]));
  }
  String _monthName(int m)=>['','Ocak','Şubat','Mart','Nisan','Mayıs','Haziran','Temmuz','Ağustos','Eylül','Ekim','Kasım','Aralık'][m];
}

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override State<StatsScreen> createState()=>_StatsScreenState();
}
class _StatsScreenState extends State<StatsScreen>{
  Map<String,dynamic> data={};
  bool loading=true;
  @override void initState(){super.initState();_read();}
  Future<void> _read() async {
    final p=await SharedPreferences.getInstance();
    final raw=p.getString('sudoku_stats_v2');
    if(raw!=null){try{data=jsonDecode(raw) as Map<String,dynamic>;}catch(_){data={};}}
    if(mounted)setState(()=>loading=false);
  }
  String _duration(int seconds)=>seconds<=0?'—':'${seconds~/60} dk ${(seconds%60).toString().padLeft(2,'0')} sn';
  @override Widget build(BuildContext context){
    final played=(data['played']??0) as int;
    final solved=(data['solved']??0) as int;
    final totalSeconds=(data['seconds']??0) as int;
    final by=Map<String,dynamic>.from(data['byLevel']??{});
    final rate=played==0?'—':'%${(solved*100/played).round()}';
    final avg=solved==0?'—':_duration(totalSeconds~/solved);
    return PageShell(title:'İSTATİSTİKLER',child:loading
      ?const Center(child:CircularProgressIndicator(color:gold))
      :ListView(padding:const EdgeInsets.all(18),children:[
        const Icon(Icons.emoji_events,color:brightGold,size:48),
        const Text('Genel Performans',textAlign:TextAlign.center,style:TextStyle(color:white,fontSize:23,fontWeight:FontWeight.bold)),
        const SizedBox(height:18),
        GridView.count(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisCount:2,childAspectRatio:1.65,crossAxisSpacing:9,mainAxisSpacing:9,children:[
          StatCard(label:'TAMAMLANAN',value:'$solved',icon:Icons.check_circle),
          StatCard(label:'BAŞARI ORANI',value:rate,icon:Icons.percent),
          StatCard(label:'TOPLAM SÜRE',value:_duration(totalSeconds),icon:Icons.timer),
          StatCard(label:'ORT. ÇÖZÜM',value:avg,icon:Icons.speed),
        ]),
        const SizedBox(height:22),const Text('ZORLUK SEVİYESİNE GÖRE',style:TextStyle(color:brightGold,fontWeight:FontWeight.bold)),
        const SizedBox(height:8),
        ...DifficultyScreen.names.map((n)=>Container(margin:const EdgeInsets.only(bottom:8),padding:const EdgeInsets.all(13),
          decoration:BoxDecoration(color:panel,borderRadius:BorderRadius.circular(12),border:Border.all(color:gold.withOpacity(.35))),
          child:Row(children:[Expanded(child:Text(n,style:const TextStyle(color:white))),Text('${by[n]??0} tamamlandı',style:const TextStyle(color:muted))]))),
        const SizedBox(height:12),
        Text('Günlük Sudoku serisi: ${data['dailyStreak']??0} gün',style:const TextStyle(color:muted)),
      ]));
  }
}
class StatCard extends StatelessWidget {
  final String label,value;final IconData icon;
  const StatCard({super.key,required this.label,required this.value,required this.icon});
  @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:panel,borderRadius:BorderRadius.circular(15),border:Border.all(color:gold.withOpacity(.45))),
    child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(icon,color:gold,size:21),const SizedBox(height:5),Text(value,style:const TextStyle(color:brightGold,fontSize:20,fontWeight:FontWeight.bold)),Text(label,style:const TextStyle(color:muted,fontSize:9,letterSpacing:.7))]));
}


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override State<SettingsScreen> createState()=>_SettingsScreenState();
}
class _SettingsScreenState extends State<SettingsScreen>{
  static const _key='sudoku_settings_v1';
  bool errors=true,notes=true,autosave=true,highlight=true,sound=true,music=false,reminders=true;
  bool loading=true;
  @override void initState(){super.initState();_load();}
  Future<void> _load() async {
    final p=await SharedPreferences.getInstance();
    final raw=p.getString(_key);
    if(raw!=null){try{
      final m=jsonDecode(raw) as Map<String,dynamic>;
      errors=m['errors']??errors;notes=m['notes']??notes;autosave=m['autosave']??autosave;
      highlight=m['highlight']??highlight;sound=m['sound']??sound;music=m['music']??music;reminders=m['reminders']??reminders;
    }catch(_){}}
    if(mounted)setState(()=>loading=false);
  }
  Future<void> _persist() async {
    final p=await SharedPreferences.getInstance();
    await p.setString(_key,jsonEncode({'errors':errors,'notes':notes,'autosave':autosave,'highlight':highlight,'sound':sound,'music':music,'reminders':reminders}));
  }
  void _change(String key,bool value){
    setState((){
      switch(key){
        case 'errors':errors=value;break;case 'notes':notes=value;break;
        case 'autosave':autosave=value;break;case 'highlight':highlight=value;break;
        case 'sound':sound=value;break;case 'music':music=value;break;case 'reminders':reminders=value;break;
      }
    });_persist();
  }
  @override Widget build(BuildContext context)=>PageShell(title:'AYARLAR',child:loading
    ?const Center(child:CircularProgressIndicator(color:gold))
    :ListView(padding:const EdgeInsets.all(18),children:[
      const _SectionTitle('GÖRÜNÜM'),
      const _SettingRow(icon:Icons.palette,label:'Tema',trailing:'Koyu ve premium'),
      const _SettingRow(icon:Icons.grid_4x4,label:'Tahta stili',trailing:'Klasik'),
      const SizedBox(height:14),const _SectionTitle('OYUN TERCİHLERİ'),
      _toggle(Icons.rule,'Hata kontrolü',errors,(v)=>_change('errors',v)),
      _toggle(Icons.edit_note,'Not alma',notes,(v)=>_change('notes',v)),
      _toggle(Icons.save,'Otomatik kayıt',autosave,(v)=>_change('autosave',v)),
      _toggle(Icons.highlight,'Aynı sayıları vurgula',highlight,(v)=>_change('highlight',v)),
      const SizedBox(height:14),const _SectionTitle('SES VE BİLDİRİMLER'),
      _toggle(Icons.volume_up,'Ses efektleri',sound,(v)=>_change('sound',v)),
      _toggle(Icons.music_note,'Müzik',music,(v)=>_change('music',v)),
      _toggle(Icons.notifications,'Günlük hatırlatma',reminders,(v)=>_change('reminders',v)),
      const SizedBox(height:14),const _SettingRow(icon:Icons.language,label:'Dil',trailing:'Türkçe'),
      const SizedBox(height:18),GoldButton(label:'İSTATİSTİKLERİ SIFIRLA',icon:Icons.restart_alt,onTap:()=>_reset(context)),
    ]));
  Widget _toggle(IconData i,String l,bool v,ValueChanged<bool> c)=>Container(margin:const EdgeInsets.only(bottom:7),padding:const EdgeInsets.symmetric(horizontal:13,vertical:4),decoration:BoxDecoration(color:panel,borderRadius:BorderRadius.circular(12)),child:Row(children:[Icon(i,color:gold),const SizedBox(width:12),Expanded(child:Text(l,style:const TextStyle(color:white))),Switch(value:v,onChanged:c,activeColor:brightGold)]));
  Future<void> _reset(BuildContext context) async {
    final yes=await showDialog<bool>(context:context,builder:(d)=>AlertDialog(backgroundColor:panel,
      title:const Text('İstatistikleri sıfırla?'),
      content:const Text('Tamamlanan oyun ve süre kayıtları silinecek. Bu işlem geri alınamaz.'),
      actions:[TextButton(onPressed:()=>Navigator.pop(d,false),child:const Text('Vazgeç')),
        FilledButton(onPressed:()=>Navigator.pop(d,true),child:const Text('Sıfırla'))]));
    if(yes==true){final p=await SharedPreferences.getInstance();await p.remove('sudoku_stats_v2');if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('İstatistikler sıfırlandı.')));}
  }
}
class _SettingRow extends StatelessWidget {
  final IconData icon;final String label,trailing;
  const _SettingRow({required this.icon,required this.label,required this.trailing});
  @override Widget build(BuildContext context)=>Container(margin:const EdgeInsets.only(bottom:7),padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:panel,borderRadius:BorderRadius.circular(12)),child:Row(children:[Icon(icon,color:gold),const SizedBox(width:12),Expanded(child:Text(label,style:const TextStyle(color:white))),Text(trailing,style:const TextStyle(color:gold,fontSize:12))]));
}
class _SectionTitle extends StatelessWidget {
  final String title;const _SectionTitle(this.title);
  @override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.only(bottom:9),child:Text(title,style:const TextStyle(color:brightGold,fontWeight:FontWeight.bold,letterSpacing:1.1)));
}

class GoldButton extends StatelessWidget {
  final String label;final IconData icon;final VoidCallback onTap;
  const GoldButton({super.key,required this.label,required this.icon,required this.onTap});
  @override Widget build(BuildContext context)=>SizedBox(height:52,child:FilledButton.icon(
    style:FilledButton.styleFrom(backgroundColor:gold,foregroundColor:night,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14))),
    onPressed:onTap,icon:Icon(icon),label:Text(label,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:12,letterSpacing:.5))));
}

class InfoDialog extends StatelessWidget {
  const InfoDialog({super.key});
  @override Widget build(BuildContext context)=>AlertDialog(backgroundColor:panel,title:const Text('Sudoku'),content:const Text('Ayhan Kayaoğlu tarafından geliştirilmektedir.',style:TextStyle(color:white)),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Kapat'))]);
}
