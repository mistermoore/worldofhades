// Run with scripts/dev.sh serve already listening on port 8000.
const { chromium } = require('playwright');
const { execFileSync } = require('node:child_process');
(async () => {
  const browser = await chromium.launch({executablePath:'/usr/bin/chromium',headless:true,args:['--no-sandbox','--enable-unsafe-swiftshader']});
  try {
    const page = await browser.newPage({viewport:{width:1280,height:720}});
    const errors = [];
    page.on('pageerror', e => errors.push(String(e)));
    page.on('console', m => { if (m.type()==='error') errors.push(m.text()); });
    await page.goto('http://127.0.0.1:8000');
    await page.waitForTimeout(5000);
    await page.keyboard.press('Space');
    await page.keyboard.press('Tab'); // The caster stays stationary, so distance measures player movement.
    async function distance(name) {
      await page.screenshot({path:`/tmp/${name}.png`,clip:{x:690,y:74,width:330,height:32}});
      const text=execFileSync('tesseract',[`/tmp/${name}.png`,'stdout','--psm','7'],{encoding:'utf8',stdio:['ignore','pipe','ignore']});
      const match=text.match(/Distance\s+(\d+(?:\.\d+)?)m/i);
      if (!match) throw Error('No distance in HUD: '+text);
      return Number(match[1]);
    }
    const initial = await distance('mouse-before');
    await page.mouse.move(640,360);
    await page.mouse.down({button:'right'});
    await page.waitForTimeout(250);
    if (!await page.evaluate(()=>!!document.pointerLockElement)) throw Error('Right-drag did not capture the pointer');
    await page.mouse.down({button:'left'});
    await page.waitForTimeout(1800);
    const moved = await distance('mouse-forward');
    if (moved >= initial-0.3) throw Error(`Both buttons did not move forward: ${initial} -> ${moved}`);
    console.log('PASS both mouse buttons move forward');
    await page.mouse.up({button:'left'});
    const stopped = await distance('mouse-stop');
    await page.waitForTimeout(1400);
    const still = await distance('mouse-still');
    if (Math.abs(still-stopped)>0.2) throw Error(`Releasing left did not stop movement: ${stopped} -> ${still}`);
    console.log('PASS releasing left stops movement while right remains held');
    await page.mouse.move(760,360);
    await page.waitForTimeout(200);
    await page.mouse.up({button:'right'});
    await page.waitForTimeout(250);
    if (await page.evaluate(()=>!!document.pointerLockElement)) throw Error('Pointer remained captured after right release');
    console.log('PASS right release restores pointer');
    await page.mouse.move(640,360);
    await page.mouse.down({button:'left'});
    await page.mouse.down({button:'right'});
    await page.waitForFunction(()=>!!document.pointerLockElement,{},{timeout:10000});
    await page.keyboard.press('p');
    await page.waitForFunction(()=>!document.pointerLockElement,{},{timeout:10000}).catch(async error=>{await page.screenshot({path:'/tmp/mouse-pause-failure.png'});throw error;});
    await page.mouse.up({button:'left'});
    await page.mouse.up({button:'right'});
    console.log('PASS pause releases pointer');
    if (errors.length) throw Error(errors.join('\n'));
    console.log('PASS no browser runtime errors');
  } finally { await browser.close(); }
})().catch(e=>{ console.error(e); process.exitCode=1; });
