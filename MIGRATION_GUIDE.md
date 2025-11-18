# Warpack Masters - Dojo 1.7 Migration Guide

## Overview

This guide helps client developers migrate their applications to work with the upgraded Warpack Masters contracts. The backend has been upgraded from Dojo 1.6.0-alpha.2 to Dojo 1.7.2, Cairo 2.10.1 to 2.12.2, and OpenZeppelin Contracts v1.0.0 to v2.0.0.

---

## Breaking Changes

### 1. Model Name Changes (26-Character Limit)

Dojo 1.7 enforces a 26-character maximum length for model names. The following models have been renamed:

| Old Model Name (1.6)              | New Model Name (1.7)         | Length |
|-----------------------------------|------------------------------|--------|
| `CharacterItemsStorageCounter`    | `CharItemStorageCounter`     | 23     |
| `CharacterItemsInventoryCounter`  | `CharItemInventoryCounter`   | 25     |

#### Client Code Updates Required:

**TypeScript/JavaScript (dojo.js):**
```typescript
// OLD (Dojo 1.6)
const storageCounter = await client.getEntity(
  'CharacterItemsStorageCounter',
  { player: playerAddress }
);

const inventoryCounter = await client.getEntity(
  'CharacterItemsInventoryCounter',
  { player: playerAddress }
);

// NEW (Dojo 1.7)
const storageCounter = await client.getEntity(
  'CharItemStorageCounter',
  { player: playerAddress }
);

const inventoryCounter = await client.getEntity(
  'CharItemInventoryCounter',
  { player: playerAddress }
);
```

**GraphQL Queries:**
```graphql
# OLD
query {
  characterItemsStorageCounterModels {
    edges {
      node {
        player
        count
      }
    }
  }
}

# NEW
query {
  charItemStorageCounterModels {
    edges {
      node {
        player
        count
      }
    }
  }
}
```

---

### 2. Dojo Client SDK Updates

The Dojo 1.7 client SDK has some API changes. Update your dependencies:

**package.json:**
```json
{
  "dependencies": {
    "@dojoengine/core": "^1.7.2",
    "@dojoengine/create-burner": "^1.7.2",
    "@dojoengine/react": "^1.7.2",
    "@dojoengine/torii-client": "^1.7.2",
    "@dojoengine/utils": "^1.7.2"
  }
}
```

**Installation:**
```bash
npm install @dojoengine/core@1.7.2 @dojoengine/create-burner@1.7.2 @dojoengine/react@1.7.2 @dojoengine/torii-client@1.7.2 @dojoengine/utils@1.7.2
```

---

### 3. World Contract Changes

The World contract has been redeployed. You'll need to:

1. **Update World Address**: After deployment, update your client configuration with the new world contract address
2. **Update Contract ABIs**: Regenerate TypeScript bindings from the new manifest

**Generate new bindings:**
```bash
# After sozo migrate, the manifest is updated at:
# ./manifests/release/manifest.json

# Use dojo-bindgen or sozo auth to generate TypeScript types
npx dojo-bindgen --manifest manifests/release/manifest.json --output src/generated
```

---

### 4. ERC20 Token Contract Updates (OpenZeppelin v2.0.0)

The ERC20 token contracts have been upgraded to OpenZeppelin v2.0.0. The ABI is mostly compatible, but there are minor interface changes:

**Key Changes:**
- Token decimals are now immutable (set to 18)
- Some internal function signatures have changed (shouldn't affect external callers)

**Client Integration (No Changes Required):**
```typescript
// These standard ERC20 calls remain the same
const balance = await erc20Contract.balanceOf(playerAddress);
const allowance = await erc20Contract.allowance(owner, spender);
await erc20Contract.approve(spender, amount);
await erc20Contract.transfer(recipient, amount);
```

---

## Migration Checklist

### For Frontend Developers:

- [ ] Update Dojo SDK packages to 1.7.2
- [ ] Replace `CharacterItemsStorageCounter` → `CharItemStorageCounter` in all queries
- [ ] Replace `CharacterItemsInventoryCounter` → `CharItemInventoryCounter` in all queries
- [ ] Update GraphQL queries with new model names
- [ ] Update world contract address after deployment
- [ ] Regenerate TypeScript bindings from new manifest
- [ ] Test all entity queries and subscriptions
- [ ] Test ERC20 token interactions (balance, transfer, approve)
- [ ] Update any cached/hardcoded contract addresses

### For Backend/Indexer Developers:

- [ ] Update Torii indexer to Dojo 1.7.2
- [ ] Update GraphQL schema with new model names
- [ ] Reindex from the new world contract
- [ ] Update any database migrations or seed data
- [ ] Update API documentation with new model names

---

## Testing Your Integration

### 1. Test Model Queries

```typescript
// Test that you can query the renamed models
const storageCount = await client.getEntity('CharItemStorageCounter', {
  player: '0x...'
});

const inventoryCount = await client.getEntity('CharItemInventoryCounter', {
  player: '0x...'
});

console.log('Storage count:', storageCount?.count);
console.log('Inventory count:', inventoryCount?.count);
```

### 2. Test System Calls

All system function signatures remain the same:
```typescript
// These should work without changes
await actions.spawn(account, name, wmClass);
await actions.place_item(account, item_id, x, y, rotation);
await actions.fight(account);
// ... etc
```

### 3. Test Events/Subscriptions

Event structures remain the same, but ensure your subscriptions work:
```typescript
await client.subscribeEntityQuery({
  query: {
    Warpacks: {
      BattleLog: {
        $: {
          where: {
            player: { $eq: playerAddress }
          }
        }
      }
    }
  },
  callback: (response) => {
    console.log('Battle log update:', response);
  }
});
```

---

## Deployment Information

### Sepolia Testnet

After deployment, the following addresses will be updated:

- **World Contract**: TBD (will be provided after `sozo migrate`)
- **Gold Token (ERC20)**: TBD (deployed separately)
- **Torii Indexer**: TBD (GraphQL endpoint)

### RPC Endpoints

Use these Sepolia endpoints:
- Blast API: `https://starknet-sepolia.public.blastapi.io/rpc/v0_7`
- Alchemy: Your Alchemy endpoint
- Infura: Your Infura endpoint

---

## Troubleshooting

### "Model not found" Errors

**Issue**: Getting errors like `Model 'CharacterItemsStorageCounter' not found`

**Solution**: You're using the old model name. Update to `CharItemStorageCounter`.

### TypeScript Type Errors

**Issue**: TypeScript complains about missing types or incorrect model names

**Solution**: Regenerate TypeScript bindings:
```bash
npx dojo-bindgen --manifest manifests/release/manifest.json --output src/generated
```

### Subscription Not Receiving Updates

**Issue**: Entity subscriptions not working after upgrade

**Solution**:
1. Ensure Torii is running and connected to the new world
2. Verify you're using the correct model names
3. Clear any cached world addresses in your client

---

## Support

- **GitHub Issues**: https://github.com/0xKube/Warpack-Masters/issues
- **Discord**: https://discord.gg/tjJJHc7JtP
- **Twitter**: https://x.com/WarpackMasters

For questions about this migration, please reach out on Discord or create a GitHub issue.

---

## Additional Resources

- [Dojo 1.7 Upgrade Guide](https://dojoengine.org/framework/upgrading/dojo-1-7)
- [Dojo Book](https://book.dojoengine.org/)
- [OpenZeppelin Contracts v2.0.0 Documentation](https://docs.openzeppelin.com/contracts-cairo/2.0.0/)
- [Starknet.js Documentation](https://www.starknetjs.com/)

---

**Last Updated**: 2025-11-18
**Version**: Dojo 1.7.2 / Cairo 2.12.2
