#!/usr/bin/env node

// Load environment variables from .env.local
// eslint-disable-next-line @typescript-eslint/no-require-imports
require('dotenv').config({ path: '.env.local' });

// Environment variables checker for CertBloom
console.log('🔍 Checking environment variables for CertBloom...\n');

const requiredEnvVars = [
  'STRIPE_SECRET_KEY',
  'STRIPE_MONTHLY_PRICE_ID', 
  'STRIPE_YEARLY_PRICE_ID',
  'STRIPE_WEBHOOK_SECRET',
  'NEXT_PUBLIC_SUPABASE_URL',
  'NEXT_PUBLIC_SUPABASE_ANON_KEY',
  'SUPABASE_SERVICE_ROLE_KEY'
];

const optionalEnvVars = [
  'NEXT_PUBLIC_BASE_URL'
];

let allRequired = true;

console.log('📋 Required Environment Variables:');
console.log('================================');

requiredEnvVars.forEach(envVar => {
  const value = process.env[envVar];
  const status = value ? '✅' : '❌';
  const displayValue = value ? 
    (envVar.includes('SECRET') || envVar.includes('KEY') ? 
      `${value.substring(0, 8)}...` : 
      value.length > 50 ? `${value.substring(0, 47)}...` : value) : 
    'NOT SET';
  
  console.log(`${status} ${envVar}: ${displayValue}`);
  
  if (!value) {
    allRequired = false;
  }
});

console.log('\n📋 Optional Environment Variables:');
console.log('=================================');

optionalEnvVars.forEach(envVar => {
  const value = process.env[envVar];
  const status = value ? '✅' : '⚠️';
  const displayValue = value || 'NOT SET (will use defaults)';
  
  console.log(`${status} ${envVar}: ${displayValue}`);
});

console.log('\n📊 Summary:');
console.log('===========');

if (allRequired) {
  console.log('✅ All required environment variables are set!');
  console.log('🚀 Your Stripe integration should work correctly.');
} else {
  console.log('❌ Some required environment variables are missing!');
  console.log('🔧 Please check your .env.local file and add the missing variables.');
  console.log('\n💡 Tip: Copy .env.local.example if available, or create .env.local with:');
  console.log('STRIPE_SECRET_KEY=sk_test_...');
  console.log('STRIPE_MONTHLY_PRICE_ID=price_...');
  console.log('STRIPE_YEARLY_PRICE_ID=price_...');
  console.log('STRIPE_WEBHOOK_SECRET=whsec_...');
  console.log('NEXT_PUBLIC_SUPABASE_URL=https://...');
  console.log('NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...');
  console.log('SUPABASE_SERVICE_ROLE_KEY=eyJ...');
}

console.log('\n');
