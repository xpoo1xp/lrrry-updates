// By lrrry 2026-11-14
// SquidBotsLite 插件汉化：给每个 Lua 的 STRINGS 表补一份 zh，并让语言判断认识 zhCN。
//
// 插件本身已经支持多语言（STRINGS = { en = {...}, fr = {...} }），
// 界面统一通过 (STRINGS[lang] or STRINGS.en)[key] 取值，
// 所以不需要改动任何业务代码，只要：
//   1. 在每个 STRINGS 里加 zh = { ... }（key 与 en 相同，值换成中文）
//   2. SquidBotsLite.lua 里的 lang 判断加上 zhCN / zhTW
//
// 用法：
//   node tools/lrrry-addon-cn.mjs --src <插件目录> [--dict tools/lrrry-addon-zh.json]
//
// 词条库是「英文原文 -> 中文」，不是「key -> 中文」，这样上游改 key 也不影响翻译。
// End By lrrry 2026-11-14

import fs from 'node:fs';
import path from 'node:path';

const args = process.argv.slice(2);
const readArg = (name, fallback) => {
  const index = args.indexOf(name);
  return index >= 0 && args[index + 1] ? args[index + 1] : fallback;
};

const src = readArg('--src', '');
const dictPath = readArg('--dict', 'tools/lrrry-addon-zh.json');
if (!src) {
  console.error('用法: node tools/lrrry-addon-cn.mjs --src <SquidBotsLite 目录> [--dict <词条库>]');
  process.exit(1);
}

// 读取词条库（英文原文 -> 中文）
let dict = {};
try {
  dict = JSON.parse(fs.readFileSync(dictPath, 'utf8'));
} catch {
  console.warn(`[汉化] 没有词条库 ${dictPath}，只处理语言判断`);
}

// 找出 <name> = { ... } 的块范围（从 "name =" 后的 "{" 到配对的 "}"）
function findTable(text, name) {
  const head = new RegExp(`\\b${name}\\s*=\\s*\\{`).exec(text);
  if (!head) return null;
  const start = text.indexOf('{', head.index);
  let depth = 0;
  let index = start;
  let inString = false;
  while (index < text.length) {
    const ch = text[index];
    if (inString) {
      if (ch === '\\') { index += 2; continue; }
      if (ch === '"') inString = false;
    } else if (ch === '"') {
      inString = true;
    } else if (ch === '{') {
      depth += 1;
    } else if (ch === '}') {
      depth -= 1;
      if (depth === 0) return { start, end: index };
    }
    index += 1;
  }
  return null;
}

// 从 en 表里取 [key, 原文] 列表（只取 KEY = "..." 形式）
function entries(body) {
  const out = [];
  const pattern = /([A-Za-z_][A-Za-z0-9_]*)\s*=\s*"((?:[^"\\]|\\.)*)"/g;
  let match;
  while ((match = pattern.exec(body))) out.push([match[1], match[2]]);
  return out;
}

const report = [];

for (const name of fs.readdirSync(src)) {
  if (!name.endsWith('.lua')) continue;
  const file = path.join(src, name);
  let text = fs.readFileSync(file, 'utf8');
  if (text.includes('zh = {') || /\bzh\s*=\s*\{/.test(text)) {
    report.push(`${name}: 已有 zh 表，跳过`);
    continue;
  }
  const en = findTable(text, 'en');
  if (!en) continue;
  const body = text.slice(en.start, en.end + 1);
  const pairs = entries(body);
  if (!pairs.length) continue;

  // 逐条翻译；没有词条就保留英文（后续补词条再跑一次即可）
  const lines = [];
  let translated = 0;
  for (const [key, value] of pairs) {
    const zh = dict[value];
    if (zh) translated += 1;
    lines.push(`\t\t${key} = "${(zh || value).replace(/"/g, '\\"')}",`);
  }

  // 在 en 块的结束大括号后插入 zh 块
  const insertAt = en.end + 1;
  const block = `\n\tzh = {\n${lines.join('\n')}\n\t},`;
  text = text.slice(0, insertAt) + block + text.slice(insertAt);
  fs.writeFileSync(file, text, 'utf8');
  report.push(`${name}: ${pairs.length} 条，其中已翻译 ${translated} 条`);
}

// 语言判断：默认只有 fr/en，改成认识 zhCN/zhTW
const entryFile = path.join(src, 'SquidBotsLite.lua');
if (fs.existsSync(entryFile)) {
  let text = fs.readFileSync(entryFile, 'utf8');
  const before = 'lang = (GetLocale() == "frFR") and "fr" or "en"';
  const after = 'lang = (GetLocale() == "frFR") and "fr" or ((GetLocale() == "zhCN" or GetLocale() == "zhTW") and "zh" or "en")';
  if (text.includes(before)) {
    text = text.replace(before, after);
    fs.writeFileSync(entryFile, text, 'utf8');
    report.push('语言判断已支持 zhCN / zhTW');
  } else if (text.includes('and "zh"')) {
    report.push('语言判断已经是中文版本');
  }
}

for (const line of report) console.log(`[汉化] ${line}`);
console.log(`[汉化] 完成：词条库 ${Object.keys(dict).length} 条`);
