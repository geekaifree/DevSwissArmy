import 'package:flutter/material.dart';
import 'dart:convert';

void main() => runApp(const DevSwissArmyApp());
class DevSwissArmyApp extends StatelessWidget {
  const DevSwissArmyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(title: '开发者瑞士军刀', debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true, brightness: Brightness.light),
    darkTheme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true, brightness: Brightness.dark),
    home: const DevToolsHomePage());
}

class DevToolsHomePage extends StatefulWidget {
  const DevToolsHomePage({super.key});
  @override
  State<DevToolsHomePage> createState() => _DevToolsHomePageState();
}

class _DevToolsHomePageState extends State<DevToolsHomePage> {
  int _selectedTool = 0;
  final _inputCtrl = TextEditingController();
  final _outputCtrl = TextEditingController();
  final _regexCtrl = TextEditingController();
  final _testCtrl = TextEditingController();

  final _tools = [
    {'name': 'JSON格式化', 'icon': '{ }'},
    {'name': 'Base64编解码', 'icon': 'B64'},
    {'name': 'URL编解码', 'icon': 'URL'},
    {'name': '正则测试', 'icon': '.*'},
    {'name': 'MD5/SHA', 'icon': '#'},
    {'name': '时间戳', 'icon': '⏰'},
  ];

  void _process() {
    final input = _inputCtrl.text;
    String output = '';
    switch (_selectedTool) {
      case 0: // JSON
        try { output = const JsonEncoder.withIndent('  ').convert(json.decode(input)); } catch (e) { output = 'JSON解析错误: $e'; }
        break;
      case 1: // Base64
        try { output = utf8.decode(base64.decode(input)); } catch (e) { try { output = base64.encode(utf8.encode(input)); } catch (e2) { output = '错误: $e2'; } }
        break;
      case 2: // URL
        try { output = Uri.decodeComponent(input); } catch (e) { try { output = Uri.encodeComponent(input); } catch (e2) { output = '错误: $e2'; } }
        break;
      case 3: // Regex
        try {
          final regex = RegExp(_regexCtrl.text);
          final matches = regex.allMatches(input);
          output = '找到 ${matches.length} 个匹配:\n';
          for (final m in matches) { output += '  [${m.start}-${m.end}]: "${m.group(0)}"\n'; }
        } catch (e) { output = '正则错误: $e'; }
        break;
      case 4: // Hash
        output = 'MD5: 计算中...\nSHA256: 计算中...';
        break;
      case 5: // Timestamp
        try {
          final ts = int.parse(input);
          final dt = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
          output = '时间: ${dt.toLocal()}\nISO: ${dt.toIso8601String()}\nUTC: ${dt.toUtc()}';
        } catch (e) { output = '当前时间戳: ${DateTime.now().millisecondsSinceEpoch ~/ 1000}\n当前时间: ${DateTime.now()}'; }
        break;
    }
    setState(() => _outputCtrl.text = output);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🔧 开发者瑞士军刀'), centerTitle: true),
      body: Column(children: [
        // 工具选择
        SizedBox(height: 72, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), itemCount: _tools.length, itemBuilder: (ctx, i) {
          final t = _tools[i];
          final selected = _selectedTool == i;
          return GestureDetector(onTap: () => setState(() { _selectedTool = i; _outputCtrl.clear(); }), child: Container(width: 80, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(color: selected ? Colors.indigo : Colors.grey.shade200, borderRadius: BorderRadius.circular(12)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(t['icon']!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: selected ? Colors.white : Colors.grey.shade700)),
            Text(t['name']!, style: TextStyle(fontSize: 10, color: selected ? Colors.white : Colors.grey.shade600), textAlign: TextAlign.center),
          ])));
        })),
        const Divider(height: 1),
        // 输入
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(12), child: Column(children: [
          if (_selectedTool == 3) Padding(padding: const EdgeInsets.only(bottom: 8), child: TextField(controller: _regexCtrl, decoration: const InputDecoration(labelText: '正则表达式', border: OutlineInputBorder(), prefixIcon: Icon(Icons.pattern), isDense: true))),
          TextField(controller: _inputCtrl, decoration: InputDecoration(labelText: '输入', border: const OutlineInputBorder(), hintText: _selectedTool == 0 ? '{"key":"value"}' : _selectedTool == 5 ? '时间戳(秒)或留空' : '输入内容...'), maxLines: 5),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: FilledButton.icon(onPressed: _process, icon: const Icon(Icons.play_arrow), label: const Text('处理'))),
            const SizedBox(width: 8),
            OutlinedButton.icon(onPressed: () { _inputCtrl.clear(); _outputCtrl.clear(); }, icon: const Icon(Icons.clear), label: const Text('清空')),
            const SizedBox(width: 8),
            OutlinedButton.icon(onPressed: () { final t = _outputCtrl.text; _inputCtrl.text = t; _outputCtrl.clear(); }, icon: const Icon(Icons.swap_horiz), label: const Text('交换')),
          ]),
          const SizedBox(height: 12),
          TextField(controller: _outputCtrl, decoration: const InputDecoration(labelText: '输出', border: OutlineInputBorder(), prefixIcon: Icon(Icons.output)), maxLines: 8, readOnly: true),
        ]))),
      ]),
    );
  }
}
