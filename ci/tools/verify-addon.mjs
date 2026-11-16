// By lrrry 2026-11-15
// SquidBotsLite 汉化后的静态校验：云编译打包前跑一遍，坏文件不进产物。
//
// 为什么需要：
//   tools/lrrry-addon-cn.mjs 早期版本把 zh 表插在 en 表的 "}" 和它后面的逗号之间，
//   结果是 en 少一个逗号、zh 多一个逗号（"}\n\tzh = {...},,"）。两份 Lua 语法都不合法，
//   插件在游戏里整体加载失败——但文件看着"有中文、条数也对"，不跑 Lua 解析根本发现不了。
//
// 检查项：
//   1. 没有 ",,"（表元素之间的双逗号）
//   2. 没有 "}" 直接跟 "en/zh/fr = {"（表之间缺逗号）
//   3. 大括号整体配对（跳过字符串与注释）
//   4. 有 en 表的文件必须有 zh 表
//
// 用法：node ci/tools/verify-addon.mjs <SquidBotsLite 目录>
import fs from 'node:fs';
import path from 'node:path';

const dir = process.argv[2];
if (!dir || !fs.existsSync(dir)) {
  console.error('用法: node verify-addon.mjs <SquidBotsLite 目录>');
  process.exit(1);
}

// 把注释和字符串内容抹掉，只留下结构字符，避免被文本里的括号/逗号误导
function maskCode(text) {
  const out = [];
  let i = 0;
  const n = text.length;
  while (i < n) {
    // 长注释 --[[ ... ]]
    if (text.startsWith('--[[', i) || text.startsWith('--[=[', i)) {
      const m = /^--\[(=*)\[/.exec(text.slice(i));
      if (m) {
        const close = ']' + m[1] + ']';
        let j = text.indexOf(close, i + m[0].length);
        j = j < 0 ? n : j + close.length;
        for (let k = i; k < j; k++) out.push(text[k] === '\n' ? '\n' : ' ');
        i = j;
        continue;
      }
    }
    // 行注释
    if (text.startsWith('--', i)) {
      let j = text.indexOf('\n', i);
      j = j < 0 ? n : j;
      for (let k = i; k < j; k++) out.push(' ');
      i = j;
      continue;
    }
    const ch = text[i];
    if (ch === '"' || ch === "'") {
      const quote = ch;
      let j = i + 1;
      while (j < n) {
        if (text[j] === '\\') { j += 2; continue; }
        if (text[j] === quote) { j += 1; break; }
        if (text[j] === '\n') break;
        j += 1;
      }
      out.push(quote, quote);
      i = j;
      continue;
    }
    if (text.startsWith('[[', i)) {
      let j = text.indexOf(']]', i + 2);
      j = j < 0 ? n : j + 2;
      out.push('[[]]');
      i = j;
      continue;
    }
    out.push(ch);
    i += 1;
  }
  return out.join('');
}

const problems = [];
let checked = 0;

for (const name of fs.readdirSync(dir)) {
  if (!name.endsWith('.lua')) continue;
  checked += 1;
  const raw = fs.readFileSync(path.join(dir, name), 'utf8');
  const code = maskCode(raw);

  if (code.includes(',,')) {
    problems.push(`${name}: 出现 ",,"（表元素间多了逗号）`);
  }
  if (/\}\s*\n\s*(en|zh|fr)\s*=\s*\{/.test(code)) {
    problems.push(`${name}: 表之间缺逗号（"}" 后直接跟 en/zh/fr 表）`);
  }

  let depth = 0;
  let firstNegative = -1;
  for (let i = 0; i < code.length; i++) {
    if (code[i] === '{') depth += 1;
    else if (code[i] === '}') {
      depth -= 1;
      if (depth < 0 && firstNegative < 0) firstNegative = i;
    }
  }
  if (depth !== 0) {
    problems.push(`${name}: 大括号不配对（剩余 ${depth}）`);
  } else if (firstNegative >= 0) {
    problems.push(`${name}: 出现了多余的 "}"`);
  }

  const hasEn = /\ben\s*=\s*\{/.test(code);
  const hasZh = /\bzh\s*=\s*\{/.test(code);
  if (hasEn && !hasZh) {
    problems.push(`${name}: 有 en 表但没有 zh 表（汉化没跑？）`);
  }
}

if (problems.length) {
  console.error(`[校验] ${checked} 个 Lua，发现 ${problems.length} 个问题：`);
  for (const line of problems) console.error(`  - ${line}`);
  process.exit(1);
}
console.log(`[校验] ${checked} 个 Lua 通过（逗号、括号、zh 表齐全）`);
