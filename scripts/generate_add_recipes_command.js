const fs = require('fs');
const path = require('path');

const args = process.argv.slice(2);
if (args.length < 1) {
  console.error(
    'Usage: node scripts/generate_add_recipes_command.js <env: mainnet|sepolia|release>',
  );
  process.exit(1);
}

const envArg = args[0];
const profile = envArg === 'sepolia' ? 'release' : envArg;

if (envArg === 'sepolia') {
  console.log('Using profile "release" for sepolia.');
}

const itemsPath = path.join(__dirname, '../src/items.cairo');
const recipesPath = path.join(__dirname, '../src/Recipes.csv');

const itemsContent = fs.readFileSync(itemsPath, 'utf-8');
const recipesContent = fs.readFileSync(recipesPath, 'utf-8');

const itemRegex =
  /pub mod (\w+)\s*\{[\s\S]*?pub const id: u32 = (\d+);[\s\S]*?pub fn name\(\) -> ByteArray \{\s*"([^"]+)"/g;

const nameToId = new Map();
let match;
while ((match = itemRegex.exec(itemsContent)) !== null) {
  const id = Number(match[2]);
  const name = match[3];
  nameToId.set(name, id);
}

if (nameToId.size === 0) {
  console.error('Failed to parse items from src/items.cairo');
  process.exit(1);
}

const lines = recipesContent.split(/\r?\n/);
lines.shift(); // header

const missing = new Set();
const commands = [];

for (const line of lines) {
  const trimmed = line.trim();
  if (!trimmed) continue;
  const parts = trimmed.split(',').map((s) => s.trim());
  if (parts.length < 3) {
    console.error(`Invalid recipe line: ${line}`);
    process.exit(1);
  }

  const [item1, item2, result] = parts;
  for (const name of [item1, item2, result]) {
    if (!nameToId.has(name)) missing.add(name);
  }

  if (!nameToId.has(item1) || !nameToId.has(item2) || !nameToId.has(result)) {
    continue;
  }

  const id1 = nameToId.get(item1);
  const id2 = nameToId.get(item2);
  const resultId = nameToId.get(result);

  let itemIds;
  let itemAmounts;
  if (id1 === id2) {
    itemIds = [id1];
    itemAmounts = [2];
  } else {
    itemIds = [id1, id2];
    itemAmounts = [1, 1];
  }

  const argsList = [
    itemIds.length,
    ...itemIds,
    itemAmounts.length,
    ...itemAmounts,
    resultId,
  ].join(' ');

  commands.push(`# ${item1} + ${item2} -> ${result}`);
  commands.push(
    `sozo execute -P ${profile} Warpacks-recipe_system add_recipe ${argsList} --wait --rpc-url $STARKNET_RPC_URL`,
  );
  commands.push('');
}

if (missing.size > 0) {
  console.error('Missing items in src/items.cairo:');
  for (const name of Array.from(missing).sort()) {
    console.error(`- ${name}`);
  }
  process.exit(1);
}

const outputDir = path.join(__dirname, 'generated');
fs.mkdirSync(outputDir, { recursive: true });
const outputFilePath = path.join(outputDir, `add_recipes_${envArg}.sh`);
const header = [
  '#!/bin/bash',
  'set -euo pipefail',
  ': "${STARKNET_RPC_URL:?Environment variable STARKNET_RPC_URL must be set}"',
  '',
].join('\n');

fs.writeFileSync(outputFilePath, `${header}\n${commands.join('\n')}\n`);
fs.chmodSync(outputFilePath, 0o755);
console.log(`Generated ${outputFilePath}`);
