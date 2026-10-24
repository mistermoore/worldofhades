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
 await page.keyboard.press('Space');await page.keyboard.press('3');await page.waitForTimeout(300);
 await page.keyboard.press('Shift+Digit1');await page.waitForTimeout(300);
 let text=await read('auto-enabled');check(/Auto.attack ON/i.test(text),'Shift+1 enables auto mode',text);
 await page.waitForTimeout(4000);
 text=await read('auto-momentum');const momentum=text.match(/Momentum\s*(\d+)/);
 check(momentum&&Number(momentum[1])>=15,'automatic Strike generates Momentum without pressing 1',text);
 await page.keyboard.press('Tab');await page.waitForTimeout(300);
 text=await read('auto-retarget');check(/Auto.attack OFF/i.test(text),'Tab cancels auto mode',text);
 await page.keyboard.press('Shift+Digit1');await page.waitForTimeout(300);
 text=await read('auto-reenabled');check(/Auto.attack ON/i.test(text),'auto can be enabled on new target',text);
 await page.keyboard.press('Shift+Digit1');await page.waitForTimeout(300);
 text=await read('auto-disabled');check(/Auto.attack OFF/i.test(text),'Shift+1 toggles auto off',text);
 if(errors.length)throw Error(errors.join('\n'));console.log('PASS no browser runtime errors');
} finally {await browser.close();}
})().catch(e=>{console.error(e);process.exitCode=1});
