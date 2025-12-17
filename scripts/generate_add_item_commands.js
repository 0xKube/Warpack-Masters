const fs = require('fs')
const path = require('path')

const encodeShortString = (s) => '0x' + Buffer.from(s, 'ascii').toString('hex')

const itemsFilePath = path.join(__dirname, '../src/items.cairo')
const outputDir = path.join(__dirname, 'generated')
const outputFilePath = path.join(outputDir, 'add_item_commands.sh')

const itemsFileContent = fs.readFileSync(itemsFilePath, 'utf8')

const items = []
const moduleRegex = /pub\s+mod\s+(\w+)\s*{/g
let match
while ((match = moduleRegex.exec(itemsFileContent)) !== null) {
  const modName = match[1]

  // Find the matching closing brace for the module body (handles nested braces inside fn name()).
  const startBraceIdx = match.index + match[0].lastIndexOf('{')
  let depth = 0
  let endIdx = startBraceIdx
  for (let i = startBraceIdx; i < itemsFileContent.length; i++) {
    const ch = itemsFileContent[i]
    if (ch === '{') depth++
    if (ch === '}') depth--
    if (depth === 0) {
      endIdx = i
      break
    }
  }
  const body = itemsFileContent.slice(startBraceIdx + 1, endIdx)
  moduleRegex.lastIndex = endIdx + 1

  // Pull name from fn name() -> ByteArray { "..." } if present, otherwise use module name
  const nameFnMatch = body.match(/pub\s+fn\s+name\(\)\s*->\s*ByteArray\s*{\s*"([^"]+)"\s*}/)
  const itemName = nameFnMatch ? nameFnMatch[1] : modName

  // Pull consts (all are declared with `pub const`)
  const dataRegex = /pub\s+const\s+(\w+):\s+\w+\s*=\s*([^;]+);/g
  const item = { modName, name: itemName }
  let dataMatch
  while ((dataMatch = dataRegex.exec(body)) !== null) {
    item[dataMatch[1]] = dataMatch[2].trim()
  }

  items.push(item)
}

// Build commands
const commands = items
  .map((item) => {
    const {
      id,
      name,
      itemType,
      rarity,
      width,
      height,
      price,
      effectType,
      effectStacks,
      effectActivationType,
      chance,
      cooldown,
      energyCost,
      isPlugin,
    } = item

    const encodedName = encodeShortString(name)
    const isPluginFormatted = isPlugin === 'true' ? 1 : 0

    const fields = [
      id,
      encodedName,
      itemType,
      rarity,
      width,
      height,
      price,
      effectType,
      effectStacks,
      effectActivationType,
      chance,
      cooldown,
      energyCost,
      isPluginFormatted,
    ]

    if (fields.some((v) => v === undefined)) {
      throw new Error(`Missing field for ${item.modName}: ${JSON.stringify(item, null, 2)}`)
    }

    return `sozo execute --world $WORLD_ADDRESS $ITEM_STSTEM_ADDRESS add_item -c ${fields.join(',')} --wait --rpc-url $STARKNET_RPC_URL`
  })
  .join('\n')

fs.mkdirSync(outputDir, { recursive: true })

const header = [
  '#!/bin/bash',
  'set -euo pipefail',
  ': "${STARKNET_RPC_URL:?Environment variable STARKNET_RPC_URL must be set}"',
  ': "${WORLD_ADDRESS:?Environment variable WORLD_ADDRESS must be set}"',
  ': "${ITEM_STSTEM_ADDRESS:?Environment variable ITEM_STSTEM_ADDRESS must be set}"',
  '',
].join('\n')

fs.writeFileSync(outputFilePath, `${header}\n${commands}\n`)
fs.chmodSync(outputFilePath, 0o755)

console.log(`Generated ${outputFilePath} with ${items.length} add_item commands`)
