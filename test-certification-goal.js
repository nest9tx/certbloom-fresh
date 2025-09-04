// 🧪 BROWSER CONSOLE TEST - Copy and paste this into your browser console
// This will test the certification goal update and show detailed logging

console.log('🧪 Starting certification goal test...');

async function testCertificationGoalUpdate() {
    try {
        console.log('📝 Updating certification goal to Math 902...');
        
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
        
        const result = await response.json();
        console.log('📋 Full response:', result);

        if (response.ok) {
            console.log('✅ Certification goal updated successfully!');
            console.log('📊 Study Plan ID:', result.studyPlanId);
            console.log('🎯 Has Structured Content:', result.hasStructuredContent);
            
            // Now test the learning path bridge
            console.log('🔗 Testing learning path bridge...');
            
            // This simulates what happens in the dashboard
            const pathResponse = await fetch('/api/learning-path-bridge', {
                method: 'GET',
                credentials: 'include'
            });
            
            console.log('🔍 Learning path response status:', pathResponse.status);
            const pathResult = await pathResponse.json();
            console.log('🔍 Learning path result:', pathResult);
            
        } else {
            console.error('❌ Failed to update certification goal:', result);
        }
    } catch (error) {
        console.error('💥 Error during test:', error);
    }
}

// Run the test
testCertificationGoalUpdate();
