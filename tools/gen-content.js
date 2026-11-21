#!/usr/bin/env node
// Builds WCAGforDesigners/Model/Library.swift from content/*.json.
// content/ is the single source of lesson copy for the iOS, web and Electron apps.
//
//   node tools/gen-content.js           # validate and regenerate
//   node tools/gen-content.js --check   # validate only, exit 1 on problems
//
// Run from the repository root.
const fs = require('fs');
const path = require('path');

const root = path.join(__dirname, '..');
const read = f => JSON.parse(fs.readFileSync(path.join(root, 'content', f), 'utf8'));
const wcag = read('wcag.json');
const app = read('app.json');
const lessonDir = path.join(root, 'content', 'lessons');
const lessons = fs.readdirSync(lessonDir).filter(f => f.endsWith('.json')).sort()
  .map(f => ({ file: f, ...JSON.parse(fs.readFileSync(path.join(lessonDir, f), 'utf8')) }));

// ---- Validation -----------------------------------------------------------
const errors = [];
const nums = new Set(wcag.criteria.map(c => c.num));
const isStr = v => typeof v === 'string' && v.trim().length > 0;
const strList = (l, k, min, max) => {
  if (!Array.isArray(l[k]) || l[k].length < min || l[k].length > max || !l[k].every(isStr))
    errors.push(`${l.file}: "${k}" needs ${min}–${max} non-empty strings`);
};
for (const l of lessons) {
  if (l.file !== l.num + '.json') errors.push(`${l.file}: "num" is ${l.num}, file name disagrees`);
  if (!nums.has(l.num)) errors.push(`${l.file}: ${l.num} is not a WCAG 2.2 criterion`);
  if (!isStr(l.meta)) errors.push(`${l.file}: "meta" missing`);
  if (l.demo !== null && !['contrast', 'color', 'taps', 'motion'].includes(l.demo)) errors.push(`${l.file}: unknown demo "${l.demo}"`);
  strList(l, 'who', 3, 6); strList(l, 'takeaways', 3, 5); strList(l, 'failures', 2, 4); strList(l, 'check', 2, 4);
  strList(l, 'spec', 2, 4); strList(l, 'review', 2, 4);
  for (const k of ['tradeoff', 'system', 'pitch']) if (!isStr(l[k])) errors.push(`${l.file}: "${k}" missing`);
  const q = l.quiz || {};
  if (!isStr(q.question) || !isStr(q.why) || !Array.isArray(q.options) || q.options.length !== 3 || !q.options.every(isStr))
    errors.push(`${l.file}: quiz needs a question, exactly 3 options and a why`);
  if (!Number.isInteger(q.answer) || q.answer < 0 || q.answer > 2) errors.push(`${l.file}: quiz.answer must be 0, 1 or 2`);
  if (/\\/.test(JSON.stringify(l).replace(/\\"/g, ''))) errors.push(`${l.file}: contains a backslash`);
}
for (const p of app.paths) for (const n of p.list) if (!nums.has(n)) errors.push(`app.json: path ${p.id} lists unknown ${n}`);
if (errors.length) { console.error(errors.join('\n')); process.exit(1); }

const withLesson = new Set(lessons.map(l => l.num));
console.log(`${wcag.criteria.length} criteria, ${lessons.length} full lessons`);
for (const p of app.paths) {
  const miss = p.list.filter(n => !withLesson.has(n));
  console.log(`  path ${p.id}: ${p.list.length - miss.length}/${p.list.length}` + (miss.length ? ` (missing ${miss.join(' ')})` : ''));
}
if (process.argv.includes('--check')) process.exit(0);

// ---- Swift output ---------------------------------------------------------
const s = v => JSON.stringify(v);
const arr = (a, f = s) => '[' + a.map(f).join(', ') + ']';
const o = [];
o.push('// GENERATED from content/*.json by tools/gen-content.js — do not edit by hand.');
o.push('// Edit the JSON, then run: node tools/gen-content.js');
o.push('import Foundation\n');
o.push('enum Library {');
o.push('    static let principles: [Principle] = [');
wcag.principles.forEach(p => o.push(`        Principle(n: ${p.n}, id: ${s(p.id)}, name: ${s(p.name)}, question: ${s(p.question)}, desc: ${s(p.desc)}),`));
o.push('    ]\n');
o.push('    static let guidelines: [Guideline] = [');
wcag.guidelines.forEach(g => o.push(`        Guideline(num: ${s(g.num)}, name: ${s(g.name)}, summary: ${s(g.summary)}),`));
o.push('    ]\n');
o.push(`    static let newIn22: Set<String> = ${arr(wcag.newIn22)}\n`);
o.push('    static let criteria: [Criterion] = [');
wcag.criteria.forEach(c => o.push(`        Criterion(num: ${s(c.num)}, title: ${s(c.title)}, level: .${c.level.toLowerCase()}, designerLed: ${c.designerLed}, summary: ${s(c.summary)}),`));
o.push('    ]\n');
o.push('    static let lessons: [String: DeepLesson] = [');
for (const x of lessons) {
  o.push(`        ${s(x.num)}: DeepLesson(`);
  o.push(`            meta: ${s(x.meta)}, demo: ${x.demo ? '.' + x.demo : 'nil'},`);
  for (const f of ['who', 'takeaways', 'failures', 'check']) o.push(`            ${f}: ${arr(x[f])},`);
  o.push(`            quiz: Quiz(question: ${s(x.quiz.question)}, options: ${arr(x.quiz.options)}, answer: ${x.quiz.answer}, why: ${s(x.quiz.why)}),`);
  o.push(`            spec: ${arr(x.spec)},`);
  o.push(`            review: ${arr(x.review)},`);
  o.push(`            tradeoff: ${s(x.tradeoff)},`);
  o.push(`            system: ${s(x.system)},`);
  o.push(`            pitch: ${s(x.pitch)}`);
  o.push('        ),');
}
o.push('    ]\n');
o.push('    static let paths: [LearningPath] = [');
app.paths.forEach(p => o.push(`        LearningPath(id: ${s(p.id)}, name: ${s(p.name)}, desc: ${s(p.desc)}, list: ${arr(p.list)}),`));
o.push('    ]\n');
o.push('    static let scenarios: [Scenario] = [');
app.scenarios.forEach(p => o.push(`        Scenario(text: ${s(p.text)}, options: ${arr(p.options)}, answer: ${p.answer}, why: ${s(p.why)}),`));
o.push('    ]\n');
o.push('    static let roles: [Role] = [');
app.roles.forEach(r => o.push(`        Role(id: ${s(r.id)}, desc: ${s(r.desc)}),`));
o.push('    ]\n');
o.push('    static let levelBlurbs: [String: String] = [');
Object.keys(app.levelBlurbs).forEach(k => o.push(`        ${s(k)}: ${s(app.levelBlurbs[k])},`));
o.push('    ]\n');
o.push(`    static let reviewIntervals: [Int] = ${arr(app.reviewIntervals, String)}\n`);
o.push('    static let diagnostic: [DiagQuestion] = [');
app.diagnostic.forEach(q => o.push(`        DiagQuestion(question: ${s(q.question)}, options: ${arr(q.options)}, answer: ${q.answer}),`));
o.push('    ]\n');
o.push('    static let roleTasks: [String: RoleTask] = [');
Object.keys(app.roleTasks).forEach(k => { const t = app.roleTasks[k];
  o.push(`        ${s(k)}: RoleTask(name: ${s(t.name)}, desc: ${s(t.desc)}, questions: [`);
  t.questions.forEach(q => o.push(`            RoleQuestion(text: ${s(q.text)}, options: ${arr(q.options)}, answer: ${q.answer}, criterion: ${s(q.criterion)}, why: ${s(q.why)}),`));
  o.push('        ]),');
});
o.push('    ]\n');
o.push('    static let laws: [Law] = [');
app.laws.forEach(w => o.push(`        Law(region: ${s(w.region)}, law: ${s(w.law)}, note: ${s(w.note)}),`));
o.push('    ]');
o.push('}');
fs.writeFileSync(path.join(root, 'WCAGforDesigners/Model/Library.swift'), o.join('\n') + '\n');
console.log('wrote WCAGforDesigners/Model/Library.swift');
