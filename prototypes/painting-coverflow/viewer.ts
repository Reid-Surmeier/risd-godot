import { Effect } from 'effect';

type Painting = {id:string; title:string; artist:string; risdUrl:string; imageUrl:string; localImage:string; width:number; height:number};
const stage=document.querySelector<HTMLDivElement>('#stage')!;
const scene=document.querySelector<HTMLDivElement>('#scene')!;
const slider=document.querySelector<HTMLInputElement>('#scrubber')!;
const detail=document.querySelector<HTMLDialogElement>('#detail')!;
const reduced=matchMedia('(prefers-reduced-motion: reduce)');
let paintings:Painting[]=[],cards:HTMLButtonElement[]=[];
let target=0,position=0,velocity=0,frame=0,lastTime=0,selected=-1;
let drag:{pointer:number;x:number;start:number;moved:boolean;hit:number}|null=null;
let wheelEnd:ReturnType<typeof setTimeout>;
const clamp=(n:number)=>Math.max(0,Math.min(paintings.length-1,n));

function label() {
 const index=Math.round(target),p=paintings[index];if(!p)return;
 slider.value=String(index);slider.setAttribute('aria-valuetext',`${index+1} of ${paintings.length}: ${p.title}`);
 if(index===selected)return;selected=index;
 document.querySelector('#announcement')!.textContent=`${p.title} — ${p.artist}`;
 document.querySelector('#position')!.textContent=`${index+1} / ${paintings.length}`;
 document.querySelector<HTMLAnchorElement>('#museum-link')!.href=p.risdUrl;
 const cardHadFocus=cards.includes(document.activeElement as HTMLButtonElement);
 cards.forEach((card,i)=>{card.setAttribute('aria-current',String(i===index));card.tabIndex=i===index?0:-1;});
 if(cardHadFocus)cards[index].focus({preventScroll:true});
 stage.dataset.selected=String(index);
}
function render() {
 const width=stage.clientWidth,height=stage.clientHeight;
 const maxWidth=Math.min(width*(width<600?.66:.38),470),maxHeight=height-100;
 // The same fractional position drives the cards and their attached floor shadows.
 const spread=width<600?width*.43:Math.min(width*.31,440),stack=Math.min(width*.078,98);
 cards.forEach((card,i)=>{
  const p=paintings[i],ratio=p.width/p.height;
  const h=Math.min(maxHeight,maxWidth/ratio),w=h*ratio;
  const delta=i-position,abs=Math.abs(delta),turn=Math.min(1,abs);
  const x=Math.sign(delta)*(spread*turn+Math.max(0,abs-1)*stack);
  card.style.width=`${w}px`;card.style.height=`${h}px`;
  card.style.marginLeft=`${-w/2}px`;
  card.style.transform=`translate3d(${x}px,0,${-120*turn}px) rotateY(${-Math.sign(delta)*62*turn}deg)`;
  card.style.zIndex=String(100-Math.round(abs*10));
  card.style.visibility=abs>5?'hidden':'visible';
 });
 stage.dataset.position=position.toFixed(4);
}
function tick(time:number) {
 const dt=Math.min((time-lastTime)/1000||1/60,1/30);lastTime=time;
 if(reduced.matches){position=target;velocity=0;}
 else {
  // Critically damped spring: input can interrupt any transition without resetting it.
  const omega=18,difference=position-target,decay=Math.exp(-omega*dt);
  position=target+(difference+(velocity+omega*difference)*dt)*decay;
  velocity=(velocity-omega*(velocity+omega*difference)*dt)*decay;
 }
 render();
 if(Math.abs(position-target)>.0005||Math.abs(velocity)>.005)frame=requestAnimationFrame(tick);
 else{position=target;velocity=0;frame=0;render();}
}
function move(value:number) {
 if(!paintings.length)return;
 target=clamp(value);label();
 if(!frame){lastTime=performance.now();frame=requestAnimationFrame(tick);}
}
function step(amount:number){clearTimeout(wheelEnd);move(Math.round(target)+amount);}
function showPainting() {
 const p=paintings[selected];if(!p)return;
 const img=document.querySelector<HTMLImageElement>('#large-image')!;
 img.src=p.localImage;img.alt=`${p.title} — ${p.artist}`;
 document.querySelector('#detail-title')!.textContent=p.title;
 document.querySelector('#detail-artist')!.textContent=p.artist;
 document.querySelector<HTMLAnchorElement>('#detail-link')!.href=p.risdUrl;
 detail.showModal();
}
slider.oninput=()=>{clearTimeout(wheelEnd);move(Number(slider.value));};
document.querySelector<HTMLButtonElement>('#close')!.onclick=()=>detail.close();
detail.addEventListener('click',e=>{if(e.target===detail){const r=detail.getBoundingClientRect();if(e.clientX<r.left||e.clientX>r.right||e.clientY<r.top||e.clientY>r.bottom)detail.close();}});
stage.addEventListener('keydown',e=>{
 if(e.key==='ArrowLeft'){e.preventDefault();step(-1);}
 if(e.key==='ArrowRight'){e.preventDefault();step(1);}
 if(e.key==='Home'){e.preventDefault();clearTimeout(wheelEnd);move(0);}
 if(e.key==='End'){e.preventDefault();clearTimeout(wheelEnd);move(paintings.length-1);}
 if((e.key==='Enter'||e.key===' ')&&e.target===stage){e.preventDefault();showPainting();}
});
stage.addEventListener('wheel',e=>{
 if(e.ctrlKey||!paintings.length)return;
 e.preventDefault();clearTimeout(wheelEnd);
 const delta=(Math.abs(e.deltaX)>Math.abs(e.deltaY)?e.deltaX:e.deltaY)*(e.deltaMode===1?16:e.deltaMode===2?stage.clientWidth:1);
 move(target+Math.max(-240,Math.min(240,delta))/240);
 wheelEnd=setTimeout(()=>move(Math.round(target)),140);
},{passive:false});
stage.addEventListener('pointerdown',e=>{
 if(e.button!==0||!paintings.length)return;clearTimeout(wheelEnd);
 const hit=(e.target as HTMLElement).closest<HTMLButtonElement>('.painting');
 drag={pointer:e.pointerId,x:e.clientX,start:position,moved:false,hit:hit?Number(hit.dataset.index):-1};
 target=position;velocity=0;stage.setPointerCapture(e.pointerId);stage.focus({preventScroll:true});
});
stage.addEventListener('pointermove',e=>{
 if(!drag||drag.pointer!==e.pointerId)return;
 const dx=e.clientX-drag.x;
 if(Math.abs(dx)>6)drag.moved=true;
 if(drag.moved){target=clamp(drag.start-dx/Math.max(120,stage.clientWidth*.22));position=target;velocity=0;label();render();}
});
function finish(e:PointerEvent,cancelled=false) {
 if(!drag||drag.pointer!==e.pointerId)return;
 const ended=drag;drag=null;if(stage.hasPointerCapture(e.pointerId))stage.releasePointerCapture(e.pointerId);
 if(cancelled||ended.moved){move(Math.round(target));return;}
 if(ended.hit===selected)showPainting();else if(ended.hit>=0)move(ended.hit);else move(Math.round(target));
}
stage.addEventListener('pointerup',e=>finish(e));stage.addEventListener('pointercancel',e=>finish(e,true));
new ResizeObserver(()=>render()).observe(stage);
reduced.addEventListener('change',()=>move(target));

const load=Effect.tryPromise({try:async()=>{
 const response=await fetch('paintings.json');if(!response.ok)throw Error('Painting catalog unavailable');
 const raw:unknown=await response.json();
 if(!Array.isArray(raw)||raw.length>100)throw Error('Invalid painting catalog');
 return raw.map((p:Painting)=>{
  if(!p||!['id','title','artist','risdUrl','localImage'].every(k=>typeof p[k as keyof Painting]==='string')||!/^assets\/[a-zA-Z0-9_-]+\.(jpg|png|webp)$/.test(p.localImage)||!(Number.isFinite(p.width)&&Number.isFinite(p.height)&&p.width>0&&p.height>0))throw Error('Invalid painting record');
  const source=new URL(p.risdUrl);if(source.protocol!=='https:'||source.hostname!=='risdmuseum.org')throw Error('Invalid museum link');
  return p;
 });
},catch:e=>({message:e instanceof Error?e.message:'Could not load paintings'})});
Effect.runPromise(Effect.either(load)).then(result=>{
 const loading=document.querySelector<HTMLParagraphElement>('#loading')!;
 stage.dataset.loading='false';
 if(result._tag==='Left'||!result.right.length){loading.textContent=result._tag==='Left'?result.left.message:'No paintings available.';const retry=document.createElement('button');retry.textContent='Try again';retry.onclick=()=>location.reload();loading.append(' ',retry);return;}
 paintings=result.right;
 cards=paintings.map((p,i)=>{
  const card=document.createElement('button');card.className='painting';card.dataset.index=String(i);card.setAttribute('aria-label',`${p.title} by ${p.artist}`);
  const img=document.createElement('img');img.src=p.localImage;img.alt=p.title;img.draggable=false;img.decoding='async';
  img.onerror=()=>{img.hidden=true;const message=document.createElement('span');message.className='empty';message.textContent=`${p.title} — image unavailable`;card.append(message);};
  card.onclick=e=>{if(e.detail===0){if(i===selected)showPainting();else move(i);}};
  card.append(img);scene.append(card);return card;
 });
 loading.remove();slider.max=String(paintings.length-1);slider.disabled=false;
 position=target=Math.min(2,paintings.length-1);label();render();
});
