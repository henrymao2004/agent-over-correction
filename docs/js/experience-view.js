(async function () {
  const C=window.CAVE, X=window.CAVE_EXPERIENCE;
  C.boot('gallery',{footer:false});
  const $=id=>document.getElementById(id), esc=C.esc;
  const icon=name=>`<i data-lucide="${name}"></i>`;
  const icons=()=>window.lucide.createIcons({attrs:{'stroke-width':1.7,'aria-hidden':'true'}});
  const state={index:null,meta:null,full:null,events:[],chapters:[],highlights:new Map(),visible:[],cursor:0,filter:'all',view:'excerpts',outcome:'all',model:null,playing:false,timer:null,request:0};
  const names={phase:'Stage',input:'What I see',message:'What I say',call:'What I call',result:'What comes back',judge:'Evaluation',gap:'Missing record'};
  const eventLabel=e=>e.actor==='delegate'?({input:'Delegate input',message:'Delegate response',call:'Delegate tool call',result:'Delegate tool return'}[e.kind] || names[e.kind]):names[e.kind];
  const short=(s,n=110)=>{const value=String(s||'').replace(/\s+/g,' ').trim();return value.length>n?value.slice(0,n)+'…':value;};
  function mobile(which){['left','center','right'].forEach(p=>$('panel'+p[0].toUpperCase()+p.slice(1)).classList.toggle('mobile-on',which===p));document.querySelectorAll('#mobileTabs button').forEach(b=>b.classList.toggle('on',b.dataset.panel===which));}
  function pause(){clearTimeout(state.timer);state.timer=null;state.playing=false;$('play').innerHTML=icon('play');$('play').setAttribute('aria-label','Play');$('play').title='Play';icons();}
  function play(){
    if(state.playing){pause();return;}if(!state.visible.length)return;
    if(state.cursor===state.visible.length-1)state.cursor=0;
    state.playing=true;$('play').innerHTML=icon('pause');$('play').setAttribute('aria-label','Pause');$('play').title='Pause';icons();renderEvent();
    const tick=()=>{if(!state.playing)return;if(state.cursor>=state.visible.length-1){pause();return;}state.cursor++;renderEvent();state.timer=setTimeout(tick,Number($('speed').value));};
    state.timer=setTimeout(tick,Number($('speed').value));
  }
  function rows(){const q=$('directorySearch').value.toLowerCase(),family=$('familyFilter').value;return state.index.cases.filter(c=>(family==='all'||c.family===family)&&(state.outcome==='all'||(state.outcome==='harm'?c.harm:!c.harm))&&(!q||`${c.model} ${c.title} ${c.task_id} ${c.path}`.toLowerCase().includes(q)));}
  function directory(){
    const cases=rows();
    $('directoryList').innerHTML=state.index.models.map(m=>{const group=cases.filter(c=>c.model===m.id);if(!group.length)return '';return `<section class="dir-product ${state.model===m.id?'open':''}"><button class="dir-product-btn" data-model="${esc(m.id)}" aria-expanded="${state.model===m.id}">${C.logo(m.id)}<span class="dir-info"><strong>${esc(m.id)}</strong><small>${group.length} cases</small></span>${icon(state.model===m.id?'chevron-down':'chevron-right')}</button><div class="dir-cases">${group.map(c=>`<button class="dir-case ${state.meta?.id===c.id?'on':''}" data-id="${esc(c.id)}"><span class="outcome-dot ${c.harm?'harm':'held'}"></span><span><strong>${esc(c.title)}</strong><small>${c.family==='selfbuilt'?'Self-built':'Inherited'} · ${esc(c.domain)}</small></span></button>`).join('')}</div></section>`;}).join('')||'<p class="notes-empty">No matching cases.</p>';
    icons();
  }
  function evaluationHTML(evaluation) {
    const reward=evaluation?.reward || {}, details=evaluation?.reward_details || {};
    const shown=X.metrics.filter(([key])=>reward[key]!==undefined || details[key]);
    const entries=shown.length?shown:Object.keys(reward).map(key=>[key,key.replaceAll('_',' '),'Recorded verifier']);
    return entries.map(([key,label,method])=>{
      const part=details[key] || {}, value=part.score ?? reward[key];
      const criteria=Array.isArray(part.criteria)?part.criteria:[];
      return `<section class="judgment"><header><span>${esc(label)}</span><strong>${typeof value==='number'?value.toFixed(2):esc(X.text(value))}</strong></header><small>${esc(part.kind || method)}</small>${typeof value==='number'&&value>=0&&value<=1?`<meter min="0" max="1" value="${value}" aria-label="${esc(label)}"></meter>`:''}${criteria.map(c=>`<div class="criterion"><strong>${esc(c.name || 'Criterion')}</strong><span class="criterion-value">${c.value===undefined?'':esc(X.text(c.value))}</span>${c.reasoning?`<p>${esc(c.reasoning)}</p>`:''}</div>`).join('')}${!criteria.some(c=>c.reasoning)?'<p class="record-note">No textual rationale stored for this measure.</p>':''}</section>`;
    }).join('') || '<p class="record-note">No evaluation details stored.</p>';
  }
  function contentHTML(e){
    if(e.kind==='judge')return `<p class="scope-label">Evaluator-only record · ${esc(e.phase)}</p>${evaluationHTML(e.evaluation)}`;
    if(e.kind==='phase')return `<div class="phase-scene">${icon(e.icon)}<h2>${esc(e.title)}</h2><p>${esc(e.body)}</p><small>${esc(e.detail)}</small>${e.reused?`<p class="record-note">${e.reused} previously shown steps retained as session history.</p>`:''}${e.evidence==='messages-only'?'<p class="record-note">Tool details were not recoverable for this stage.</p>':''}</div>`;
    if(e.kind==='call' && e.args && typeof e.args==='object' && ('old_string' in e.args || 'new_string' in e.args))return `<div class="file-target">${icon('file-pen-line')}<code>${esc(e.args.file_path || e.args.path || '')}</code></div><div class="tool-diff"><section class="diff-before"><h3>${icon('minus')}Before</h3><pre>${esc(X.text(e.args.old_string))}</pre></section><section class="diff-after"><h3>${icon('plus')}Proposed replacement</h3><pre>${esc(X.text(e.args.new_string))}</pre></section></div><details class="raw-arguments"><summary>All arguments</summary><pre>${esc(e.body)}</pre></details>`;
    if(e.kind==='call' && e.args && typeof e.args==='object')return `<dl class="argument-list">${Object.entries(e.args).map(([key,value])=>`<div><dt>${esc(key)}</dt><dd><pre>${esc(X.text(value))}</pre></dd></div>`).join('')}</dl>`;
    return `<pre class="event-text">${esc(e.body || '(empty result)')}</pre>`;
  }
  function pathHTML(e){
    const active={input:0,message:1,call:2,result:3,judge:4,phase:1,gap:1}[e.kind];
    return [['inbox',e.actor==='delegate'?'Delegate input':'My context'],['bot',e.actor==='delegate'?'Delegate response':'My response'],[e.kind==='call'?e.icon:'terminal','Tool call'],[e.kind==='result'?e.icon:'corner-down-left','Tool return'],['scale','Evaluation']].map(([name,label],i)=>`${i?'<span class="path-connector" aria-hidden="true"><span></span></span>':''}<div class="path-station ${i===active?'active':''}" data-lane="${i}">${icon(name)}<span>${label}</span></div>`).join('');
  }
  function renderEvent(){
    const e=state.visible[state.cursor];if(!e)return;
    const chapter=state.chapters.find(c=>c.id===e.phase);
    $('position').textContent=`${state.cursor+1} / ${state.visible.length}`;$('scrubber').value=state.cursor;
    $('previous').disabled=state.cursor===0;$('next').disabled=state.cursor===state.visible.length-1;
    $('centerContent').dataset.eventTone=e.kind==='judge'||e.error?'red':'default';
    $('notes').className=`notes ${e.kind} ${e.error?'error':''}`;
    $('agentPath').className=`agent-path mode-${e.kind} ${e.error?'error':''}`;$('agentPath').innerHTML=pathHTML(e);
    $('eventFocus').className=`event-focus ${e.kind} ${e.tone || ''} ${e.error?'error':''}`;
    const status=e.kind==='result'?`<span class="return-status ${e.error?'error':''}">${icon(e.error?'circle-x':'corner-down-left')}${e.error?'Reported error':e.hasStatus?'Returned without error flag':'Returned'}</span>`:'';
    $('eventFocus').innerHTML=`<header class="event-heading"><span class="event-symbol">${icon(e.icon)}</span><div><div class="eyebrow">${esc(eventLabel(e))}${e.step!=null?' · Step '+esc(e.step):''}</div><h2>${esc(e.kind==='call'||e.kind==='result'?e.title:e.kind==='phase'?chapter?.title:((e.kind==='input'||e.kind==='message')?eventLabel(e):e.title))}</h2></div>${status}<button class="icon-btn copy-event" title="Copy event" aria-label="Copy event">${icon('copy')}</button></header>${e.batch?`<p class="batch-note">${esc(e.batch)}</p>`:''}<div class="event-content">${contentHTML(e)}</div>`;
    $('eventFocus').classList.remove('arrive');void $('eventFocus').offsetWidth;$('eventFocus').classList.add('arrive');
    const pair=e.callId?state.events.find(r=>r.phase===e.phase&&r.callId===e.callId&&r.kind===(e.kind==='call'?'result':'call')):null;
    $('notes').innerHTML=`<div class="inspector-label">${esc(chapter?.title || e.phase)}</div><dl class="provenance"><div><dt>Record</dt><dd>${esc(eventLabel(e))}</dd></div>${e.step!=null?`<div><dt>Step</dt><dd>${esc(e.step)}</dd></div>`:''}${e.timestamp?`<div><dt>Time</dt><dd>${esc(e.timestamp)}</dd></div>`:''}${e.callId?`<div><dt>Call ID</dt><dd>${esc(e.callId)}</dd></div>`:''}</dl>${state.highlights.has(e.position)?`<p class="selection-reason">${icon('bookmark-check')}${esc(state.highlights.get(e.position))}</p>`:''}${pair?`<button class="paired-event" data-jump="${pair.position}">${icon(pair.icon)}<span>${e.kind==='call'?'View tool return':'View tool call'}</span>${icon('arrow-right')}</button>`:''}${e.kind==='judge'?evaluationHTML(e.evaluation):`<div class="evaluation-boundary">${icon('scale')}<p>Evaluation follows the recorded agent interaction.</p><button class="text-action" data-jump="${state.events.length-1}">View final evaluation ${icon('arrow-right')}</button></div>`}`;
    document.querySelectorAll('[data-event]').forEach(row=>{const on=Number(row.dataset.event)===e.position;row.classList.toggle('selected',on);row.setAttribute('aria-current',on?'step':'false');});
    document.querySelectorAll('[data-chapter]').forEach(b=>b.classList.toggle('on',b.dataset.chapter===e.phase));
    icons();
  }
  function refreshView(position=0){
    pause();
    state.visible=state.events.filter(e=>(state.view==='full'||state.highlights.has(e.position))&&(state.filter==='all'||(state.filter==='tools'?['call','result'].includes(e.kind):e.kind===state.filter)));
    state.cursor=Math.max(0,state.visible.findIndex(e=>e.position===position));
    $('scrubber').max=Math.max(0,state.visible.length-1);$('eventCount').textContent=`${state.visible.length} of ${state.events.length} events`;
    $('eventList').innerHTML=state.visible.map((e,i)=>`<li><button data-event="${e.position}" class="event-row ${e.kind} ${e.error?'error':''}"><span class="event-number">${String(i+1).padStart(2,'0')}</span><span class="timeline-icon">${icon(e.icon)}</span><span class="event-summary"><strong>${esc(eventLabel(e))}${e.kind==='call'||e.kind==='result'?' · '+esc(e.title):''}</strong><span>${esc(short(e.kind==='judge'?e.title:e.kind==='phase'?e.title:e.body))}</span></span>${e.error?icon('circle-x'):''}</button></li>`).join('');
    if(!state.visible.length){$('eventFocus').innerHTML='<p class="notes-empty">No events in this view.</p>';$('agentPath').innerHTML='';$('position').textContent='0 / 0';$('notes').innerHTML='';}
    $('play').disabled=!state.visible.length;$('scrubber').disabled=!state.visible.length;
    renderEvent();icons();
  }
  function jump(position){
    pause();let i=state.visible.findIndex(e=>e.position===position);
    if(i<0){state.filter='all';state.view='full';syncControls();refreshView(position);}else{state.cursor=i;renderEvent();}
    mobile('center');const top=$('agentPath').offsetTop-$('doc').offsetTop;$('doc').scrollTo({top:Math.max(0,top-12),behavior:matchMedia('(prefers-reduced-motion: reduce)').matches?'instant':'smooth'});
  }
  function syncControls(){document.querySelectorAll('[data-span-filter]').forEach(b=>b.classList.toggle('on',b.dataset.spanFilter===state.filter));document.querySelectorAll('[data-view]').forEach(b=>b.classList.toggle('on',b.dataset.view===state.view));}
  async function selectCase(id){
    const meta=state.index.cases.find(c=>c.id===id);if(!meta)return;
    const request=++state.request;pause();state.meta=meta;state.model=meta.model;state.filter='all';state.view='excerpts';state.full=null;
    document.body.dataset.caseOutcome=meta.harm?'harm':'held';
    syncControls();directory();
    $('centerEmpty').style.display='none';$('centerContent').style.display='flex';$('centerContent').setAttribute('aria-busy','true');$('eventFocus').innerHTML='<p class="notes-empty">Loading recorded case...</p>';
    mobile('center');
    try{const full=await C.loadCase(id);if(request!==state.request)return;state.full=full;Object.assign(state,X.normalize(full));$('centerContent').setAttribute('aria-busy','false');
      $('caseHeader').innerHTML=`${C.logo(meta.model)}<div class="case-header-info"><div class="eyebrow">${esc(meta.model)} · ${esc(meta.domain)}</div><h1>${esc(meta.title)}</h1><span class="family-label">${meta.family==='selfbuilt'?'Self-built':'Inherited-resume'}</span></div><button id="shareCase" class="icon-btn" title="Copy case link" aria-label="Copy case link">${icon('link')}</button>`;
      $('chapters').innerHTML=state.chapters.map((c,i)=>`<button data-chapter="${esc(c.id)}" data-jump="${c.start}"><span>${String(i+1).padStart(2,'0')}</span>${esc(c.title)}</button>`).join('');
      $('essentials').innerHTML=X.essentials(state,full).map(row=>{const e=row.event;const scores=full.judge?.reward || {};const summary=e.kind==='judge'?`Harm ${scores.c1_downstream ?? 'N/A'} · Confession ${scores.c2_false_confession ?? 'N/A'} · Evidence miss ${scores.c3_recognition ?? 'N/A'}`:X.excerpt(e);return `<button class="essential ${e.kind} ${e.error?'error':''}" data-jump="${e.position}"><span class="essential-label">${icon(e.icon)}${esc(row.label)}</span><p>${esc(short(summary,180))}</p><small>${esc(e.phase)}${e.step!=null?' · step '+esc(e.step):''}${icon('arrow-up-right')}</small></button>`;}).join('');
      history.replaceState(null,'','#case='+encodeURIComponent(id));refreshView();$('doc').scrollTop=0;
    }catch(error){if(request===state.request){$('centerContent').setAttribute('aria-busy','false');$('eventFocus').innerHTML=`<p class="notes-empty">Could not load this case. ${esc(error.message)}</p>`;}}
  }
  $('directoryList').addEventListener('click',event=>{const caseButton=event.target.closest('[data-id]');if(caseButton)return selectCase(caseButton.dataset.id);const modelButton=event.target.closest('[data-model]');if(modelButton){state.model=state.model===modelButton.dataset.model?null:modelButton.dataset.model;directory();}});
  $('directorySearch').addEventListener('input',directory);$('familyFilter').addEventListener('change',directory);
  $('dirFilters').addEventListener('click',event=>{const b=event.target.closest('[data-filter]');if(!b)return;state.outcome=b.dataset.filter;document.querySelectorAll('[data-filter]').forEach(el=>el.classList.toggle('on',el===b));directory();});
  $('evidenceFilter').addEventListener('click',event=>{const b=event.target.closest('[data-span-filter]');if(!b)return;state.filter=b.dataset.spanFilter;syncControls();refreshView(state.visible[state.cursor]?.position);});
  $('viewSwitcher').addEventListener('click',event=>{const b=event.target.closest('[data-view]');if(!b)return;state.view=b.dataset.view;syncControls();refreshView(state.visible[state.cursor]?.position);});
  $('play').addEventListener('click',play);$('previous').addEventListener('click',()=>{pause();state.cursor=Math.max(0,state.cursor-1);renderEvent();});$('next').addEventListener('click',()=>{pause();state.cursor=Math.min(state.visible.length-1,state.cursor+1);renderEvent();});
  $('restart').addEventListener('click',()=>{pause();state.cursor=0;renderEvent();});$('scrubber').addEventListener('input',()=>{pause();state.cursor=Number($('scrubber').value);renderEvent();});
  $('download').addEventListener('click',()=>{if(!state.full)return;const url=URL.createObjectURL(new Blob([JSON.stringify(state.full,null,2)],{type:'application/json'}));const a=document.createElement('a');a.href=url;a.download=state.meta.task_id+'.json';a.click();setTimeout(()=>URL.revokeObjectURL(url),1000);});
  document.addEventListener('click',async event=>{
    const jumpButton=event.target.closest('[data-jump]');if(jumpButton)return jump(Number(jumpButton.dataset.jump));
    const row=event.target.closest('[data-event]');if(row)return jump(Number(row.dataset.event));
    const copy=event.target.closest('.copy-event,#shareCase');if(copy){try{await navigator.clipboard.writeText(copy.id==='shareCase'?location.href:state.visible[state.cursor]?.body || JSON.stringify(state.visible[state.cursor]?.evaluation,null,2));copy.innerHTML=icon('check');icons();}catch{copy.title='Copy unavailable';}}
  });
  $('mobileTabs').addEventListener('click',event=>{const b=event.target.closest('[data-panel]');if(b)mobile(b.dataset.panel);});
  document.addEventListener('visibilitychange',()=>{if(document.hidden)pause();});
  window.addEventListener('hashchange',()=>{const id=new URLSearchParams(location.hash.slice(1)).get('case');if(id&&id!==state.meta?.id)selectCase(id);});
  try{state.index=await C.loadIndex();$('auditStats').innerHTML=`<span><strong>${state.index.n_models}</strong> models</span><span><strong>${state.index.n_cases}</strong> recorded cases</span>`;directory();const id=new URLSearchParams(location.hash.slice(1)).get('case');if(id)await selectCase(id);else mobile('left');}
  catch(error){$('directoryList').innerHTML=`<p class="notes-empty">Unable to load cases. ${esc(error.message)}</p>`;}
  icons();
})();
