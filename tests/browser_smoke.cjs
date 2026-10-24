const {chromium}=require('playwright');
const {execFileSync}=require('node:child_process');
(async()=>{
const browser=await chromium.launch({executablePath:'/usr/bin/chromium',headless:true,args:['--no-sandbox','--enable-unsafe-swiftshader']});
const page=await browser.newPage({viewport:{width:1280,height:720}});const errors=[];
page.on('pageerror',e=>errors.push(String(e)));page.on('console',m=>{if(m.type()==='error')errors.push(m.text())});
await page.goto('http://127.0.0.1:8000');await page.waitForTimeout(5000);
async function sees(name,pattern){await page.screenshot({path:`/tmp/${name}.png`});const text=execFileSync('tesseract',[`/tmp/${name}.png`,'stdout'],{encoding:'utf8',stdio:['ignore','pipe','ignore']});if(!pattern.test(text))throw Error(name+' failed: '+text);console.log('PASS '+name);}
await page.keyboard.press('r');await page.waitForTimeout(150);await sees('hades-start',/Begin encounter/);
await page.keyboard.press('Space');await page.waitForTimeout(150);
await page.keyboard.press('3');await page.waitForTimeout(150);await sees('hades-charge',/Charge! (Target interrupted|In melee range)/);
await page.waitForTimeout(3500);await page.keyboard.press('1');await page.waitForTimeout(150);await sees('hades-strike',/Momentum\s*15/);
await page.keyboard.press('r');await page.waitForTimeout(150);await sees('hades-reset',/Begin encounter/);
await page.keyboard.press('Space');await page.waitForTimeout(150);
await page.keyboard.press('p');await page.waitForTimeout(150);await sees('hades-paused',/PAUSED/);
if(errors.length)throw Error(errors.join('\n'));console.log('PASS no browser runtime errors');await browser.close();
})().catch(e=>{console.error(e);process.exit(1)});
