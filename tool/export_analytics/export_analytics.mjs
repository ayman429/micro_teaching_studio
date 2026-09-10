/**
 * Export student analytics from Firestore into a teacher-facing Excel workbook.
 *
 * Usage (PowerShell — use npm.cmd):
 *   cd tool/export_analytics
 *   npm.cmd install
 *   node export_analytics.mjs --key .\serviceAccount.json --out .\micro-teaching-analytics.xlsx
 */
import { readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import ExcelJS from "exceljs";
import { cert, initializeApp } from "firebase-admin/app";
import { FieldPath, getFirestore } from "firebase-admin/firestore";

const here = dirname(fileURLToPath(import.meta.url));
const args = parseArgs(process.argv.slice(2));
const keyPath = resolve(here, args.key ?? "./serviceAccount.json");
const outPath = resolve(here, args.out ?? "./micro-teaching-analytics.xlsx");

const FILL = {
  Green: "059669",
  Amber: "D97706",
  Red: "E11D48",
  Grey: "64748B",
  Excellent: "BBF7D0",
  "Well done": "BFDBFE",
  "Good effort": "FDE68A",
  "Don't give up": "FECDD3",
  "No response": "E2E8F0",
};

const serviceAccount = JSON.parse(readFileSync(keyPath, "utf8"));
initializeApp({
  credential: cert(serviceAccount),
  projectId: serviceAccount.project_id,
});
const db = getFirestore();

const users = await loadCollection("users");
const progressRows = await loadCollection("user_progress");
const parts = await loadCollection("part_progress");
const attempts = await loadCollection("attempts");
const words = await loadCollection("attempt_words");
const phonemes = await loadCollection("attempt_phonemes");

const progress = indexBy(progressRows, "uid");
const userById = indexBy(users, "uid");
const studentIds = new Set([
  ...users.map((row) => str(row.uid)),
  ...progressRows.map((row) => str(row.uid)),
  ...parts.map((row) => str(row.uid)),
  ...attempts.map((row) => str(row.uid)),
].filter(Boolean));

const students = [...studentIds].map((uid) => {
  const profile = userById.get(uid) ?? {};
  const rollup = progress.get(uid) ?? {};
  return {
    uid,
    fullName: profile.fullName || rollup.fullName || "",
    userName: profile.userName || rollup.userName || "",
    overallPercent: rollup.overallPercent,
    module1Percent: rollup.module1Percent,
    module2Percent: rollup.module2Percent,
    module3Percent: rollup.module3Percent,
  };
});

const workbook = new ExcelJS.Workbook();
workbook.creator = "Micro Teaching Studio";
workbook.created = new Date();

const studentSheet = addSheet(workbook, "Students", [
  { header: "Full name", key: "fullName", width: 24 },
  { header: "Username", key: "userName", width: 18 },
  { header: "Overall %", key: "overallPercent", width: 12 },
  { header: "Module 1 %", key: "module1Percent", width: 12 },
  { header: "Module 2 %", key: "module2Percent", width: 12 },
  { header: "Module 3 %", key: "module3Percent", width: 12 },
], sortRows(students, ["fullName", "userName"]));
formatPercents(studentSheet, ["overallPercent", "module1Percent", "module2Percent", "module3Percent"]);

addSheet(workbook, "Course items", [
  { header: "Student", key: "student", width: 22 },
  { header: "Module", key: "module", width: 42 },
  { header: "Session", key: "session", width: 28 },
  { header: "Item", key: "itemKind", width: 12 },
  { header: "Name", key: "itemName", width: 24 },
  { header: "Status", key: "statusLabel", width: 14 },
  { header: "Tries used", key: "tries", width: 12 },
  { header: "Last feedback", key: "feedback", width: 16 },
  { header: "Last overall %", key: "latestPronScore", width: 16 },
], sortRows(parts.map((row) => ({
  ...row,
  student: studentName(row),
  module: moduleLabel(row),
  session: sessionLabel(row),
  itemKind: row.itemKind || itemKindFrom(row),
  itemName: row.itemName || row.partLabel || "",
  statusLabel: statusLabel(row.status),
  tries: `${num(row.attemptCount)} / ${num(row.maxAttempts) || 3}`,
  feedback: row.latestFeedbackLabel || bandLabel(row.latestBand),
})), ["student", "module", "session", "itemName"]));

const attemptSheet = addSheet(workbook, "Attempts", [
  { header: "Student", key: "student", width: 22 },
  { header: "Module", key: "module", width: 42 },
  { header: "Session", key: "session", width: 28 },
  { header: "Item", key: "itemKind", width: 12 },
  { header: "Name", key: "itemName", width: 24 },
  { header: "Attempt", key: "attemptNumber", width: 10 },
  { header: "Feedback", key: "feedbackLabel", width: 16 },
  { header: "Overall %", key: "pronScore", width: 12 },
  { header: "Accuracy %", key: "accuracyScore", width: 12 },
  { header: "Fluency %", key: "fluencyScore", width: 12 },
  { header: "Completeness %", key: "completenessScore", width: 16 },
  { header: "Prosody %", key: "prosodyScore", width: 12 },
  { header: "Correct words", key: "correctWords", width: 36 },
  { header: "Needs improv words", key: "needsImprovWords", width: 36 },
  { header: "Incorrect words", key: "incorrectWords", width: 36 },
  { header: "Heard text", key: "heardText", width: 36 },
  { header: "Recognition", key: "recognitionStatus", width: 14 },
  { header: "Duration (sec)", key: "durationSec", width: 14 },
], sortRows(attempts.map((row) => ({
  ...row,
  student: studentName(row),
  module: moduleLabel(row),
  session: sessionLabel(row),
  itemKind: row.itemKind || itemKindFrom(row),
  itemName: row.itemName || row.partLabel || "",
  feedbackLabel: row.feedbackLabel || bandLabel(row.band),
  durationSec: row.durationMs ? Math.round(Number(row.durationMs) / 1000) : "",
})), ["student", "module", "session", "itemName", "attemptNumber"]));
colorByValue(attemptSheet, "feedbackLabel", FILL);

const wordSheet = addSheet(workbook, "Paragraph words", [
  { header: "Student", key: "student", width: 22 },
  { header: "Module", key: "module", width: 42 },
  { header: "Session", key: "session", width: 28 },
  { header: "Name", key: "itemName", width: 24 },
  { header: "Attempt", key: "attemptNumber", width: 10 },
  { header: "Word #", key: "wordIndex", width: 10 },
  { header: "Word", key: "expectedWord", width: 18 },
  { header: "Color", key: "color", width: 22 },
  { header: "Accuracy %", key: "accuracy", width: 12 },
  { header: "Azure error", key: "errorType", width: 18 },
], sortRows(words.map((row) => ({
  ...row,
  student: studentName(row),
  module: moduleLabel(row),
  session: sessionLabel(row),
  itemName: row.itemName || row.partLabel || "",
  wordIndex: Number(row.wordIndex) + 1,
  color: colorLabel(row),
})), ["student", "session", "itemName", "attemptNumber", "wordIndex"]));
colorByValue(wordSheet, "color", {
  "Green — Excellent": FILL.Green,
  "Amber — Needs improv": FILL.Amber,
  "Red — Incorrect": FILL.Red,
  Grey: FILL.Grey,
});

const soundSheet = addSheet(workbook, "Word sounds", [
  { header: "Student", key: "student", width: 22 },
  { header: "Module", key: "module", width: 42 },
  { header: "Session", key: "session", width: 28 },
  { header: "Word", key: "expectedWord", width: 18 },
  { header: "Attempt", key: "attemptNumber", width: 10 },
  { header: "Sound #", key: "phonemeIndex", width: 10 },
  { header: "Expected", key: "expectedPhoneme", width: 12 },
  { header: "Heard", key: "heardPhoneme", width: 12 },
  { header: "Accuracy %", key: "accuracy", width: 12 },
  { header: "Color", key: "color", width: 22 },
  { header: "Wrong?", key: "wrong", width: 10 },
  { header: "Azure guess 2", key: "nBest2", width: 14 },
  { header: "Azure guess 3", key: "nBest3", width: 14 },
], sortRows(phonemes.map((row) => ({
  ...row,
  student: studentName(row),
  module: moduleLabel(row),
  session: sessionLabel(row),
  phonemeIndex: Number(row.phonemeIndex) + 1,
  color: colorLabel(row),
  wrong: row.isMismatch ? "Yes" : "No",
})), ["student", "expectedWord", "attemptNumber", "phonemeIndex"]));
colorByValue(soundSheet, "color", {
  "Green — Excellent": FILL.Green,
  "Amber — Needs improv": FILL.Amber,
  "Red — Incorrect": FILL.Red,
  Grey: FILL.Grey,
});

await workbook.xlsx.writeFile(outPath);
console.log(`Wrote ${outPath}`);
console.log(
  `Students ${students.length} · Items ${parts.length} · Attempts ${attempts.length} · Words ${words.length} · Sounds ${phonemes.length}`,
);

function addSheet(workbook, title, columns, rows) {
  const sheet = workbook.addWorksheet(title);
  sheet.columns = columns;
  sheet.getRow(1).font = { bold: true };
  sheet.views = [{ state: "frozen", ySplit: 1 }];
  for (const row of rows) {
    const values = {};
    for (const column of columns) {
      values[column.key] = cell(row[column.key]);
    }
    sheet.addRow(values);
  }
  return sheet;
}

function colorByValue(sheet, key, palette) {
  const index = sheet.columns.findIndex((column) => column.key === key) + 1;
  if (index < 1) return;
  sheet.eachRow((row, rowNumber) => {
    if (rowNumber === 1) return;
    const value = String(row.getCell(index).value ?? "");
    const hex = palette[value];
    if (!hex) return;
    row.getCell(index).fill = {
      type: "pattern",
      pattern: "solid",
      fgColor: { argb: `FF${hex}` },
    };
    row.getCell(index).font = { color: { argb: "FF111827" }, bold: true };
  });
}

function formatPercents(sheet, keys) {
  for (const key of keys) {
    const index = sheet.columns.findIndex((column) => column.key === key) + 1;
    if (index < 1) continue;
    sheet.getColumn(index).numFmt = "0.0";
  }
}

function studentName(row) {
  return [row.fullName, row.userName].filter(Boolean).join(" / ") || str(row.uid);
}

function moduleLabel(row) {
  const number = row.moduleNumber ?? "";
  const title = row.moduleTitle ?? "";
  return [number, title].filter((part) => String(part).length > 0).join(" — ");
}

function sessionLabel(row) {
  const number = row.sessionNumber ?? "";
  const title = row.sessionTitle ?? "";
  return [number, title].filter((part) => String(part).length > 0).join(" — ");
}

function itemKindFrom(row) {
  const type = str(row.partType);
  if (type === "fluency_passage") return "Paragraph";
  if (type === "phonics_word") return "Word";
  return "Session";
}

function statusLabel(status) {
  if (status === "completed") return "Completed";
  if (status === "in_progress") return "In progress";
  return "Not started";
}

function bandLabel(band) {
  if (band === "excellent") return "Excellent";
  if (band === "needs_improv") return "Well done";
  if (band === "incorrect") return "Don't give up";
  return "";
}

function colorLabel(row) {
  if (row.color === "Green" || row.band === "excellent") return "Green — Excellent";
  if (row.color === "Amber" || row.band === "needs_improv") return "Amber — Needs improv";
  if (row.color === "Red" || row.band === "incorrect") return "Red — Incorrect";
  return row.color || "Grey";
}

async function loadCollection(name) {
  const rows = [];
  let last;
  for (;;) {
    let query = db.collection(name).orderBy(FieldPath.documentId()).limit(500);
    if (last) query = query.startAfter(last);
    const snapshot = await query.get();
    if (snapshot.empty) break;
    for (const doc of snapshot.docs) {
      rows.push({ id: doc.id, ...doc.data() });
    }
    last = snapshot.docs[snapshot.docs.length - 1];
    if (snapshot.size < 500) break;
  }
  return rows;
}

function sortRows(rows, keys) {
  return [...rows].sort((left, right) => {
    for (const key of keys) {
      const a = cell(left[key]);
      const b = cell(right[key]);
      if (a < b) return -1;
      if (a > b) return 1;
    }
    return 0;
  });
}

function indexBy(rows, key) {
  const map = new Map();
  for (const row of rows) {
    map.set(str(row[key]), row);
  }
  return map;
}

function cell(value) {
  if (value == null) return "";
  if (typeof value.toDate === "function") return value.toDate().toISOString();
  if (typeof value === "object" && typeof value._seconds === "number") {
    return new Date(value._seconds * 1000).toISOString();
  }
  if (typeof value === "boolean") return value ? "Yes" : "No";
  if (typeof value === "number") return Math.round(value * 10) / 10;
  return value;
}

function str(value) {
  return value == null ? "" : String(value);
}

function num(value) {
  return value == null || value === "" ? 0 : Number(value);
}

function parseArgs(argv) {
  const result = {};
  for (let i = 0; i < argv.length; i += 1) {
    const token = argv[i];
    if (!token.startsWith("--")) continue;
    result[token.slice(2)] = argv[i + 1];
    i += 1;
  }
  return result;
}
