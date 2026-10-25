// Requires the exported game served on port 8000, Playwright and Tesseract.
const {chromium}=require('playwright');
const {execFileSync}=require('node:child_process');
(async()=>{
const browser=await chromium.launch({executablePath:'/usr/bin/chromium',headless:true,args:['--no-sandbox','--enable-unsafe-swiftshader']});
try {
 const page=await browser.newPage({viewport:{width:1280,height:720}});const errors=[];
 page.on('pageerror',e=>errors.push(String(e)));page.on('console',m=>{if(m.type()==='error')errors.push(m.text())});
 await page.goto('http://127.0.0.1:8000');await page.waitForTimeout(5000);
 async function read(name){await page.screenshot({path:`/tmp/${name}.png`});return execFileSync('tesseract',[`/tmp/${name}.png`,'stdout'],{encoding:'utf8',stdio:['ignore','pipe','ignore']});}
 function check(ok,name,text){if(!ok)throw Error(name+': '+text);console.log('PASS '+name);}
 await page.keyboard.press('Space');await page.keyboard.press('3');await page.waitForTimeout(4000);
 let text=await read('auto-momentum');const momentum=text.match(/Momentum\s*(\d+)/);
 check(momentum&&Number(momentum[1])>=15,'automatic Strike generates Momentum without pressing 1 or Shift+1',text);
 await page.keyboard.press('Tab');await page.waitForTimeout(300);
 text=await read('auto-retarget');check(/Automatic Strike:.*Seer/i.test(text) && /TARGET:\s*Ember Seer/i.test(text),'Tab automatically arms Strike on the new target',text);
 await page.keyboard.press('p');await page.waitForTimeout(300);
 text=await read('auto-paused');check(/PAUSED/.test(text),'automatic combat can be paused',text);
 if(errors.length)throw Error(errors.join('\n'));console.log('PASS no browser runtime errors');
} finally {await browser.close();}
})().catch(e=>{console.error(e);process.exitCode=1});
