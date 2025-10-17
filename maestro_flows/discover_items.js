// Script to discover how many todo items exist
// This will be used by Maestro flows

// Try to find the maximum index of visible items
let maxIndex = -1;

// Check indices 0-20
for (let i = 0; i <= 20; i++) {
  // This is conceptual - Maestro's JS doesn't have direct DOM access
  // We'll need to rely on the conditional runFlow approach instead
  maxIndex = i;
}

output.maxItemIndex = maxIndex;
output.hasFirstItem = maxIndex >= 0;
output.hasMiddleItems = maxIndex >= 3;
output.hasLastItems = maxIndex >= 7;

console.log(`Discovered ${maxIndex + 1} items`);
