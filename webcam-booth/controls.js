// The original blue icon is the accessible shutter, aligned with the Godot artwork.
window.addEventListener('DOMContentLoaded',()=>{
 const canvas=document.getElementById('canvas'),display=document.createElement('main');display.id='booth-display';display.setAttribute('aria-label','Webcam portrait booth');canvas.replaceWith(display);display.append(canvas);
 const shutter=document.createElement('button');shutter.id='booth-shutter';shutter.type='button';shutter.disabled=true;shutter.setAttribute('aria-label','Enable camera');const icon=document.createElement('span');icon.setAttribute('aria-hidden','true');shutter.append(icon);display.append(shutter);
 const footer=document.createElement('footer');footer.id='booth-controls';const message=document.createElement('p');message.id='booth-message';message.setAttribute('role','status');message.setAttribute('aria-live','polite');message.textContent='Loading the booth…';footer.append(message);
 const note=document.createElement('p');note.id='booth-photo-note';note.hidden=true;note.textContent='Only the picture you take is sent to OpenRouter. Preview and expression tracking stay on your device.';footer.append(note);
 const cancel=document.createElement('button');cancel.type='button';cancel.textContent='Return to camera';cancel.hidden=true;cancel.onclick=()=>window.booth.action('reset');footer.append(cancel);document.body.append(footer);
 shutter.onclick=()=>window.booth.action(window.boothState?.source==='camera'?'capture':'camera');
 const style=document.createElement('style');style.textContent=`
 html,body{width:100%;height:100%;background:#fff;color:#292929}
 body{display:grid;grid-template-rows:minmax(0,1fr) auto;grid-template-columns:minmax(0,1fr);justify-items:center;height:100dvh;overflow:auto;touch-action:auto;font-family:Arial,sans-serif}
 #booth-display{width:min(100%,1024px);height:100%;min-height:0;min-width:0;position:relative}
 #canvas{width:100%!important;height:100%!important;object-fit:contain;touch-action:none}
 #booth-controls{box-sizing:border-box;width:min(100%,900px);padding:0 16px 12px;text-align:center}
 #booth-message{font-size:17px;line-height:1.35;margin:4px 0 12px;min-height:24px}
 #booth-photo-note{font-size:13px;line-height:1.4;margin:0 0 10px;color:#555}
 button{cursor:pointer;touch-action:manipulation}button:focus-visible{outline:3px solid #7848b8;outline-offset:3px}button[hidden]{display:none!important}button:disabled{cursor:default}
 #booth-shutter{position:absolute;z-index:2;width:48px;height:49px;min-width:44px;min-height:44px;transform:translate(-50%,-50%);border:0;padding:0;background:transparent;border-radius:50%;display:grid;place-items:center}
 #booth-shutter span{display:block;width:48px;height:49px;background:url(camera-frame.png) -491px -536px;clip-path:circle(48%);transform:scale(var(--icon-scale,1));transition:transform .12s,filter .12s;pointer-events:none}
 #booth-shutter:hover:not(:disabled) span{transform:scale(calc(var(--icon-scale,1)*1.12));filter:brightness(1.12)}
 #booth-shutter:active:not(:disabled) span{transform:scale(calc(var(--icon-scale,1)*.88))}#booth-shutter:disabled span{opacity:.5}
 #booth-controls button{min-width:150px;min-height:44px;padding:10px 16px;font:600 16px Arial,sans-serif;color:#292929;background:linear-gradient(#fff,#eee);border:1px solid #888;border-radius:5px}
 @media(prefers-reduced-motion:reduce){#booth-shutter span{transition:none}}
 @media(max-height:420px){#booth-message{font-size:15px;margin:2px 0 6px}}
 `;document.head.append(style);
 function position(){const width=canvas.clientWidth,height=canvas.clientHeight,scale=Math.min(width/1024,height/700);shutter.style.left=((width-1024*scale)/2+515*scale)+'px';shutter.style.top=((height-700*scale)/2+560.5*scale)+'px';shutter.style.setProperty('--icon-scale',Math.max(44/48,scale));shutter.style.width=Math.max(44,48*scale)+'px';shutter.style.height=Math.max(44,49*scale)+'px'}
 new ResizeObserver(position).observe(canvas);position();
 setInterval(()=>{const state=window.boothState;if(!state)return;const camera=state.state==='camera';shutter.hidden=!camera;cancel.hidden=camera;shutter.disabled=state.source==='requesting';shutter.setAttribute('aria-label',state.source==='camera'?'Take picture':'Enable camera');note.hidden=!(camera&&state.source==='camera');if(message.textContent!==state.message)message.textContent=state.message},100);
});
