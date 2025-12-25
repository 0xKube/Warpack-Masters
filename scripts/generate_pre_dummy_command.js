const fs = require('fs');
const path = require('path');

const encodeShortString = (s) => '0x' + Buffer.from(s, 'ascii').toString('hex');

const args = process.argv.slice(2);
const env = args[0] || 'release';
const action = args[1] || 'update_prefine_dummy';
const allowedActions = new Set(['update_prefine_dummy', 'prefine_dummy']);
if (!allowedActions.has(action)) {
  console.error(
    `Usage: node scripts/generate_pre_dummy_command.js [env] [update_prefine_dummy|prefine_dummy]`,
  );
  process.exit(1);
}

const predefinedDummiesContent = fs.readFileSync(
  path.join(__dirname, '../src/prdefined_dummies.cairo'),
  'utf-8',
);

const itemsContent = fs.readFileSync(path.join(__dirname, '../src/items.cairo'), 'utf-8');

// Parse items with all fields needed to compute adjacency and plugin effects
const itemMap = {};
const itemRegex =
  /pub mod (\w+)\s*\{[\s\S]*?const id: u32 = (\d+);[\s\S]*?const itemType: u8 = (\d+);[\s\S]*?const width: u32 = (\d+);[\s\S]*?const height: u32 = (\d+);[\s\S]*?const effectType: u8 = (\d+);[\s\S]*?const effectStacks: u32 = (\d+);[\s\S]*?const effectActivationType: u8 = (\d+);[\s\S]*?const chance: u32 = (\d+);[\s\S]*?const cooldown: u8 = (\d+);[\s\S]*?const energyCost: u8 = (\d+);[\s\S]*?const isPlugin: bool = (true|false);/g;

let m;
while ((m = itemRegex.exec(itemsContent)) !== null) {
  const [
    _,
    name,
    id,
    itemType,
    width,
    height,
    effectType,
    effectStacks,
    effectActivationType,
    chance,
    cooldown,
    energyCost,
    isPlugin,
  ] = m;
  itemMap[name] = {
    id: Number(id),
    itemType: Number(itemType),
    width: Number(width),
    height: Number(height),
    effectType: Number(effectType),
    effectStacks: Number(effectStacks),
    effectActivationType: Number(effectActivationType),
    chance: Number(chance),
    cooldown: Number(cooldown),
    energyCost: Number(energyCost),
    isPlugin: isPlugin === 'true',
  };
}

const dummyRegex =
  /mod\s+Dummy(\d+)\s*{([\s\S]+?)fn\s+get_items\(\)\s*->\s*Array<PredefinedItem>\s*{([\s\S]+?)}\s*}/g;

const levelRegex = /const\s+level:\s+u32\s+=\s+(\d+);/;
const nameRegex = /const\s+name:\s+felt252\s+=\s+'([^']+)';/;
const wmClassRegex = /const\s+wmClass:\s+WMClass\s+=\s+WMClass::([a-zA-Z]+);/;
const wmClassMap = { Warrior: 0, Warlock: 1, Archer: 2 };

const itemDetailsRegex =
  /items\s*\.?\s*append\(\s*PredefinedItem\s*{[\s\S]*?itemId:\s*(\w+)::id,[\s\S]*?position:\s*Position\s*{\s*x:\s*(\d+),\s*y:\s*(\d+)\s*}\s*,\s*rotation:\s*(\d+)/gms;

const touch = (a, b) => {
  const ax2 = a.x + a.w - 1;
  const ay2 = a.y + a.h - 1;
  const bx2 = b.x + b.w - 1;
  const by2 = b.y + b.h - 1;
  const xOverlap = a.x <= bx2 && b.x <= ax2;
  const yOverlap = a.y <= by2 && b.y <= ay2;
  const verticalTouch = xOverlap && (ay2 + 1 === b.y || by2 + 1 === a.y);
  const horizontalTouch = yOverlap && (ax2 + 1 === b.x || bx2 + 1 === a.x);
  return verticalTouch || horizontalTouch;
};

const getDims = (item, rotation) => {
  if (rotation === 90 || rotation === 270) return { w: item.height, h: item.width };
  return { w: item.width, h: item.height };
};

const commands = [];
let match;
while ((match = dummyRegex.exec(predefinedDummiesContent)) !== null) {
  const dummyContent = match[2];
  const itemsSection = match[3];

  const level = Number(dummyContent.match(levelRegex)?.[1]);
  const name = dummyContent.match(nameRegex)?.[1];
  const wmClass = wmClassMap[dummyContent.match(wmClassRegex)?.[1]];
  const encodedName = encodeShortString(name);

  const items = [];
  let itemMatch;
  while ((itemMatch = itemDetailsRegex.exec(itemsSection)) !== null) {
    const def = itemMap[itemMatch[1]];
    const x = Number(itemMatch[2]);
    const y = Number(itemMatch[3]);
    const rotation = Number(itemMatch[4]);
    const dims = getDims(def, rotation);
    items.push({
      def,
      x,
      y,
      rot: rotation,
      w: dims.w,
      h: dims.h,
      plugins: [],
    });
  }

  const weapons = items.filter((it) => it.def.itemType === 1 || it.def.itemType === 2);
  const pluginItems = items.filter((it) => it.def.isPlugin);

  for (const w of weapons) {
    for (const p of pluginItems) {
      if (touch(w, p)) {
        w.plugins.push([p.def.effectType, p.def.chance, p.def.effectStacks]);
      }
    }
  }

  const itemCount = items.length;
  const flattened = items
    .map((it) => {
      const base = [it.def.id, it.x, it.y, it.rot, it.plugins.length];
      const plugs = it.plugins.flat();
      return base.concat(plugs).join(' ');
    })
    .join(' ');

  const dummyId = 1; // single dummy per level
  const baseArgs =
    action === 'update_prefine_dummy'
      ? `${dummyId} ${level} ${encodedName} ${wmClass} ${itemCount} ${flattened}`
      : `${level} ${encodedName} ${wmClass} ${itemCount} ${flattened}`;
  const commandLine = `sozo execute -P ${env} Warpacks-dummy_system ${action} ${baseArgs} --wait --rpc-url $STARKNET_RPC_URL`;
  commands.push(commandLine);
}

const outputDir = path.join(__dirname, 'generated');
fs.mkdirSync(outputDir, { recursive: true });
const outputBaseByAction = {
  update_prefine_dummy: 'update_pre_dummies',
  prefine_dummy: 'prefine_dummies',
};
const outputBase = outputBaseByAction[action] || `dummies_${action}`;
const outputFilePath = path.join(outputDir, `${outputBase}_${env}.sh`);
const header = [
  '#!/bin/bash',
  'set -euo pipefail',
  ': "${STARKNET_RPC_URL:?Environment variable STARKNET_RPC_URL must be set}"',
  '',
].join('\n');
fs.writeFileSync(outputFilePath, `${header}\n${commands.join('\n')}\n`);
fs.chmodSync(outputFilePath, 0o755);
console.log(`Generated ${outputFilePath}`);
