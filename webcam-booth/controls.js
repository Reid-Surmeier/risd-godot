// Native browser controls keep keyboard access and touch targets usable around the Godot canvas.
window.addEventListener('DOMContentLoaded',()=>{
 const canvas=document.getElementById('canvas');const display=document.createElement('main');display.id='booth-display';display.setAttribute('aria-label','Webcam portrait booth');canvas.replaceWith(display);display.append(canvas);
 const footer=document.createElement('footer');footer.id='booth-controls';
 const message=document.createElement('p');message.id='booth-message';message.setAttribute('role','status');message.setAttribute('aria-live','polite');message.setAttribute('aria-atomic','true');message.textContent='Loading the booth…';footer.append(message);
 const note=document.createElement('p');note.id='booth-photo-note';note.hidden=true;note.textContent='Only the picture you take is sent to OpenRouter. Preview and expression tracking stay on your device.';footer.append(note);
 const row=document.createElement('div');row.className='booth-buttons';footer.append(row);document.body.append(footer);
 const buttons={};for(const [action,label] of [['camera','Enable camera'],['fixture','Try sample photo'],['capture','Take picture'],['reset','Return to camera']]){
  const button=document.createElement('button');button.type='button';button.textContent=label;button.disabled=true;button.onclick=()=>window.booth.action(action);row.append(button);buttons[action]=button;
 }
 const style=document.createElement('style');style.textContent=`
 html,body{width:100%;height:100%;background:#fff;color:#292929}
 body{display:grid;grid-template-rows:minmax(0,1fr) auto;grid-template-columns:minmax(0,1fr);justify-items:center;height:100dvh;overflow:auto;touch-action:auto;font-family:Arial,sans-serif}
 #booth-display{width:min(100%,1024px);height:100%;min-height:0;min-width:0;position:relative}
 #canvas{width:100%!important;height:100%!important;object-fit:contain;touch-action:none}
 #booth-controls{box-sizing:border-box;width:min(100%,900px);padding:0 16px 12px;text-align:center}
 #booth-message{font-size:17px;line-height:1.35;margin:4px 0 12px;min-height:24px}
 #booth-photo-note{font-size:13px;line-height:1.4;margin:0 0 10px;color:#555}
 .booth-buttons{display:flex;justify-content:center;gap:8px;flex-wrap:wrap}
 .booth-buttons button{min-width:150px;min-height:44px;padding:10px 16px;font:600 16px Arial,sans-serif;color:#292929;background:linear-gradient(#fff,#eee);border:1px solid #888;border-radius:5px;cursor:pointer;touch-action:manipulation}
 .booth-buttons button:hover{background:#f9ecff}.booth-buttons button:focus-visible{outline:3px solid #7848b8;outline-offset:3px}
 .booth-buttons button:disabled{opacity:.5;cursor:default}.booth-buttons button[hidden]{display:none}
 @media(max-height:420px){#booth-message{font-size:15px;margin:2px 0 6px}.booth-buttons button{min-width:130px}}
 `;document.head.append(style);
 setInterval(()=>{
  const state=window.boothState;if(!state)return;
  const camera=state.state==='camera';note.hidden=!(camera&&state.source==='camera');
  for(const [action,button] of Object.entries(buttons)){button.hidden=action==='reset'?camera:!camera;button.disabled=false;}
  buttons.capture.disabled=!['camera','fixture'].includes(state.source);buttons.camera.disabled=state.source==='requesting';
  if(message.textContent!==state.message)message.textContent=state.message;
 },100);
});
