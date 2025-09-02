console.log('🔧 Quick Study Path Debug - Paste this in browser console on /study-path page');

// Check what certifications are actually loaded
if (window.React) {
  console.log('React is available - checking component state...');
  
  // Look for certification data in the DOM
  const certCards = document.querySelectorAll('[class*="certification"], [class*="cert"], .bg-white.rounded-lg');
  console.log(`Found ${certCards.length} certification-like elements in DOM`);
  
  certCards.forEach((card, i) => {
    const text = card.textContent;
    if (text.includes('Test Code:')) {
      console.log(`Card ${i + 1}: ${text.substring(0, 100)}...`);
    }
  });
} else {
  console.log('No React found - check if page fully loaded');
}

// Check for errors
if (window.console.error.toString().includes('[native code]')) {
  console.log('✅ Console appears clean');
} else {
  console.log('⚠️ Console may have been overridden');
}

console.log('Navigate to Network tab and reload to check for failed API calls');
