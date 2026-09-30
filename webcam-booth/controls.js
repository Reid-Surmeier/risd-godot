// Original blue shutter; camera permission starts on load. Feedback remains available to screen readers.
window.addEventListener('DOMContentLoaded',()=>{
 const canvas=document.getElementById('canvas'),display=document.createElement('main');display.id='booth-display';display.setAttribute('aria-label','Webcam portrait booth');canvas.replaceWith(display);display.append(canvas);
 const shutter=document.createElement('button');shutter.id='booth-shutter';shutter.type='button';shutter.disabled=true;shutter.setAttribute('aria-label','Take picture');const icon=document.createElement('span');icon.setAttribute('aria-hidden','true');shutter.append(icon);display.append(shutter);
 const message=document.createElement('p');message.id='booth-announcement';message.setAttribute('role','status');message.setAttribute('aria-live','polite');display.append(message);
 shutter.onclick=()=>window.booth.action(window.boothState?.source==='camera'?'capture':'camera');
 window.addEventListener('keydown',event=>{if(event.key==='Escape'&&window.boothState&&window.boothState.state!=='camera')window.booth.action('reset')});
 const style=document.createElement('style');style.textContent=`
 html,body{width:100%;height:100%;background:#fff;color:#292929}
 body{display:flex;justify-content:center;height:100dvh;overflow:hidden;touch-action:auto}
 #booth-display{width:min(100%,1024px);height:100%;position:relative}
 #canvas{width:100%!important;height:100%!important;object-fit:contain;touch-action:none}
 #booth-announcement{position:absolute;width:1px;height:1px;overflow:hidden;clip-path:inset(50%);white-space:nowrap}
 button{cursor:pointer;touch-action:manipulation}button:focus-visible{outline:3px solid #7848b8;outline-offset:3px}button[hidden]{display:none!important}button:disabled{cursor:default}
 #booth-shutter{position:absolute;z-index:2;width:48px;height:49px;min-width:44px;min-height:44px;transform:translate(-50%,-50%);border:0;padding:0;background:transparent;border-radius:50%;display:grid;place-items:center}
 #booth-shutter span{display:block;width:48px;height:49px;background:url(camera-frame.png) -491px -536px;clip-path:circle(48%);transform:scale(var(--icon-scale,1));transition:transform .12s,filter .12s;pointer-events:none}
 #booth-shutter:hover:not(:disabled) span{transform:scale(calc(var(--icon-scale,1)*1.12));filter:brightness(1.12)}
 #booth-shutter:active:not(:disabled) span{transform:scale(calc(var(--icon-scale,1)*.88))}#booth-shutter:disabled span{opacity:.5}
 @media(prefers-reduced-motion:reduce){#booth-shutter span{transition:none}}
 `;document.head.append(style);
 function position(){const width=canvas.clientWidth,height=canvas.clientHeight,scale=Math.min(width/1024,height/700);shutter.style.left=((width-1024*scale)/2+515*scale)+'px';shutter.style.top=((height-700*scale)/2+560.5*scale)+'px';shutter.style.setProperty('--icon-scale',Math.max(44/48,scale));shutter.style.width=Math.max(44,48*scale)+'px';shutter.style.height=Math.max(44,49*scale)+'px'}
 new ResizeObserver(position).observe(canvas);position();window.booth.start();
 setInterval(()=>{const state=window.boothState;if(!state)return;shutter.hidden=state.state!=='camera';shutter.disabled=state.source==='requesting';shutter.setAttribute('aria-label',state.source==='camera'?'Take picture':'Enable camera');if(message.textContent!==state.message)message.textContent=state.message},100);
});
