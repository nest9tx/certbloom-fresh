// 🧪 ENHANCED BROWSER CONSOLE TEST
// Copy and paste this into your browser console to test certification goal updates
// This will show detailed step-by-step logging

console.log('🧪 Starting enhanced certification goal test...');

async function testCertificationSystem() {
    try {
        console.log('🔍 Step 1: Testing 902 certification goal update...');
        
        const response = await fetch('/api/update-certification-goal', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            credentials: 'include',
            body: JSON.stringify({
                certificationGoal: '902'
            })
        });

        console.log('📡 Response status:', response.status);
        console.log('📡 Response headers:', Object.fromEntries(response.headers.entries()));
        
        const result = await response.json();
        console.log('📋 API Response:', result);

        if (response.ok) {
            console.log('✅ API call successful!');
            console.log('📊 Study Plan ID:', result.studyPlanId);
            console.log('🎯 Has Structured Content:', result.hasStructuredContent);
            console.log('📝 Certification Name:', result.certificationName);
            
            console.log('🔍 Step 2: Testing learning path bridge...');
            
            // Wait a moment for database to update
            await new Promise(resolve => setTimeout(resolve, 1000));
            
            const pathResponse = await fetch('/api/learning-path-bridge', {
                method: 'GET',
                credentials: 'include'
            });
            
            console.log('🔗 Learning path response status:', pathResponse.status);
            const pathResult = await pathResponse.json();
            console.log('🔗 Learning path result:', pathResult);
            
            console.log('🔍 Step 3: Testing dashboard refresh...');
            
            // Test if dashboard would show structured path
            if (pathResult.hasStructuredPath) {
                console.log('✅ SUCCESS: Dashboard should show "Begin Learning" button');
                console.log('🎯 Certification ID:', pathResult.certificationId);
                console.log('📝 Study Plan ID:', pathResult.studyPlanId);
            } else {
                console.log('❌ ISSUE: Dashboard will show concept-based learning instead of structured path');
                console.log('🔍 Debugging info:', pathResult);
            }
            
        } else {
            console.error('❌ API call failed:', result);
        }
        
        console.log('🔍 Step 4: Testing other certification (391)...');
        
        const response391 = await fetch('/api/update-certification-goal', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            credentials: 'include',
            body: JSON.stringify({
                certificationGoal: '391'
            })
        });
        
        const result391 = await response391.json();
        console.log('📋 391 Response:', result391);
        
    } catch (error) {
        console.error('💥 Error during test:', error);
    }
}

// Run the test
testCertificationSystem();
