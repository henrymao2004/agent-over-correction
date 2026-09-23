/* Preserve observations as recorded; evaluations never become agent context. */
(function (root) {
  const metrics = [
    ['c1_downstream', 'Realized harm', 'Deterministic verifier'],
    ['c2_false_confession', 'False confession', 'Trajectory judge'],
    ['c3_recognition', 'Evidence recognition failure', 'Trajectory judge'],
  ];
  function text(value) {
    return typeof value === 'string' ? value : value == null ? '' : JSON.stringify(value, null, 2);
  }
  function toolStyle(name, args) {
    const n = String(name || '').toLowerCase();
    const command = typeof args === 'object' ? String(args.command || args.cmd || '') : '';
    if (/^task(create|update|list|get|stop|output)$/.test(n)) return {icon:({taskcreate:'list-plus',taskupdate:'list-checks',taskstop:'circle-stop',taskget:'file-search',tasklist:'clipboard-list',taskoutput:'scroll-text'})[n],label:'Task tracking',tone:'tracking'};
    if (/^agent$|delegate/.test(n)) return {icon:'bot',label:'Delegation',tone:'agent'};
    if (/^skill$/.test(n)) return {icon:'puzzle',label:'Skill',tone:'service'};
    if (/askuser/.test(n)) return {icon:'message-circle-question',label:'User question',tone:'service'};
    if (/cron/.test(n)) return {icon:'clock',label:'Schedule',tone:'service'};
    if(n==='toolsearch')return {icon:'package-search',label:'Tool discovery',tone:'search'};
    if(n==='websearch')return {icon:'radar',label:'Web search',tone:'web'};
    if(n==='glob')return {icon:'folder-search',label:'File search',tone:'search'};
    if (/^write$|patch|edit|replace|write.*file|create.*file/.test(n)) return {icon:n==='write'?'file-plus-2':'file-pen-line', label:'File edit', tone:'edit'};
    if (/read|view.*file|open.*file/.test(n)) return {icon:'file-text', label:'File read', tone:'read'};
    if (/search|grep|glob|find/.test(n)) return {icon:'search', label:'Search', tone:'search'};
    if (/browser|fetch|web|http/.test(n)) return {icon:'globe', label:'Web request', tone:'web'};
    if (/python|node|eval/.test(n)) return {icon:'code-xml', label:'Code execution', tone:'code'};
    if (/list.*dir|directory/.test(n)) return {icon:'folder-open', label:'Directory', tone:'read'};
    if (/bash|shell|exec|terminal|command/.test(n)) {
      if (/^\s*(cat|head|tail|sed\s+-n)\s/.test(command)) return {icon:'file-text', label:'Read via shell', tone:'read'};
      if (/^\s*(rg|grep|find)\s/.test(command)) return {icon:'search', label:'Search via shell', tone:'search'};
      if (/^\s*(ls|pwd)\b/.test(command)) return {icon:'folder-open', label:'Inspect via shell', tone:'read'};
      return {icon:'terminal', label:'Terminal', tone:'shell'};
    }
    if (/ticket/.test(n)) return {icon:'ticket', label:'Ticket operation', tone:'service'};
    if (/mail|message|slack/.test(n)) return {icon:'mail', label:'Message', tone:'service'};
    if (/sql|database|query/.test(n)) return {icon:'database', label:'Database', tone:'service'};
    return {icon:'wrench', label:'Tool', tone:'service'};
  }
  function phaseTitle(id, family) {
    if (/s0|dowork/i.test(id)) return 'First, I do the work';
    if (/insist|s2/i.test(id)) return 'I face renewed pressure';
    if (family === 'selfbuilt') return 'I revisit my work';
    return 'I inherit the workspace';
  }
  function fingerprint(step) {
    return JSON.stringify([step.step_id, step.source, step.message || '', step.timestamp || '']);
  }
  function changesWorkspace(event) {
    if(event.tone==='tracking'||event.kind!=='call')return false;
    if(event.tone==='edit')return true;
    const action=text(event.args?.command || event.args?.cmd || '').replace(/\d*>{1,2}\s*\/dev\/null|\d*>&\d/g,'');
    const verbs=[...action.matchAll(/run\.sh\s+([a-z_]+)/g)].map(m=>m[1]);
    if(verbs.some(v=>!/^(get|list|read|search|show|help|status|query|inspect|preview|check|diff|validate)(_|$)/.test(v)))return true;
    return /\b(?:apply_patch|amend_order|cancel_order|close_ticket|delete_message|edit_message|post_message|pin_message|set_config|set_replicas|delete_file|write_text|write_bytes|write_file|json\.dump|csv\.writer|shutil\.(?:copy|move|rmtree)|os\.remove|unlink|truncate|chmod|chown|rm|mv|cp|touch|tee)\b|sed\s+-i|git\s+(?:restore|reset|checkout)|(?<![<>=])>{1,2}(?![=])/i.test(action);
  }
  function normalize(full) {
    const tr=full.trajectory || {};
    const phases=Array.isArray(tr.steps) ? [[full.scored_step || 'single',tr]] : Object.entries(tr)
      .filter(([,v])=>Array.isArray(v?.steps)).sort(([a],[b])=>a.localeCompare(b,undefined,{numeric:true}));
    const events=[], chapters=[];
    let previous=[];
    function add(event) {event.id='event-'+events.length;event.position=events.length;events.push(event);}
    phases.forEach(([phase,traj],phaseIndex)=>{
      const steps=traj.steps || [];let prefix=0;
      while(prefix<previous.length && prefix<steps.length && fingerprint(previous[prefix])===fingerprint(steps[prefix])) prefix++;
      // Only remove an exact complete prior history, never a partial resemblance.
      if(prefix!==previous.length)prefix=0;
      const chapter={id:phase,title:phaseTitle(phase,full.family),start:events.length,reused:prefix,status:traj.evidence_status};
      chapters.push(chapter);
      add({kind:'phase',phase,title:chapter.title,icon:/s0|dowork/.test(phase)?'hammer':'folder-clock',
        body:/s0|dowork/.test(phase)?'Task construction stage':full.family==='selfbuilt'?'Continuation after the construction stage':'Existing workspace at the start of this recorded stage',
        detail:phase, reused:prefix,evidence:traj.evidence_status});
      const callMap=new Map();
      steps.forEach(s=>(s.tool_calls || []).forEach(c=>callMap.set(c.tool_call_id,c)));
      steps.slice(prefix).forEach(step=>{
        const common={phase,step:step.step_id,timestamp:step.timestamp,actor:step.is_sidechain?'delegate':'main'};
        const message=text(step.message);
        if(message) {
          const incoming=step.source==='user'||step.source==='system';
          add({...common,kind:incoming?'input':'message',title:incoming?'What I see':'What I say',
            icon:incoming?'inbox':'message-square',body:message,source:step.source});
        }
        const calls=step.tool_calls || [];
        calls.forEach((call,i)=>add({...common,kind:'call',title:call.function_name || 'Tool call',
          ...toolStyle(call.function_name,call.arguments),body:text(call.arguments),args:call.arguments,
          callId:call.tool_call_id,batch:calls.length>1?`${i+1} of ${calls.length} calls in this step`:''}));
        (step.observation?.results || []).forEach(result=>{
          const callId=result.source_call_id || result.tool_call_id;const call=callMap.get(callId);
          const body=text(result.content),hasStatus=typeof result.is_error==='boolean';
          // Some exporters retain the wrapper's failure footer instead of is_error.
          const error=hasStatus?result.is_error:/(?:^|\n)\[error\] tool reported failure\s*$/.test(body);
          add({...common,kind:'result',title:call?.function_name || 'Tool return',...toolStyle(call?.function_name,call?.arguments),
            body,callId,error,hasStatus});
        });
        if(!message&&!calls.length&&!step.observation?.results?.length) add({...common,kind:'gap',title:'Unrecorded event content',icon:'file-question',body:'This exported step has no message, tool call, or tool result.'});
      });
      const evaluation=full.phase_judges?.[phase];
      if(evaluation && phase!==full.scored_step) add({kind:'judge',phase,title:/s0|dowork/.test(phase)?'Construction-stage evaluation':'Stage evaluation',icon:'clipboard-check',evaluation});
      previous=steps;
    });
    add({kind:'judge',phase:full.scored_step || phases.at(-1)?.[0],title:'Final evaluation',icon:'scale',evaluation:full.judge || {}});
    const highlights = selectHighlights(events, full);
    return {events,chapters,highlights};
  }
  function selectHighlights(events, full) {
    const selected=new Map();
    const mark=(event,reason)=>{if(event)selected.set(event.position,reason);};
    const judgeText=JSON.stringify(full.judge?.reward_details || {}).toLowerCase();
    const artifacts=[...new Set((judgeText.match(/[\w./-]+\.(?:py|json|md|yaml|yml|sh|csv|txt|toml|conf|ini|js|sql)\b/g)||[]))];
    const taskWords=String(full.task_id || '').replace(/task_\d+_|selfbuilt|gaslight/g,'').split('_').filter(w=>w.length>3);
    const phases=[...new Set(events.map(e=>e.phase))];
    const mutation=/\b(apply_patch|amend_order|cancel_order|close_ticket|delete|remove|revert|unlink|truncate|overwrite|chmod|chown|rm|mv|cp|touch|tee|write_text|write_file|set_policy|set_config|update_record)\b|sed\s+-i|git\s+(?:restore|reset|checkout)|\bopen\([^\n]*["'](?:w|a)["']|(?<![<>=])>{1,2}(?![=])/i;
    for(const phase of phases) {
      const rows=events.filter(e=>e.phase===phase);
      rows.filter(e=>['phase','input','judge'].includes(e.kind)).forEach(e=>mark(e,e.kind==='input'?'Agent-visible context':e.kind==='judge'?'Recorded evaluation':'Stage boundary'));
        const messages=rows.filter(e=>e.kind==='message'&&e.actor!=='delegate');
      mark(messages.at(-1),'Final recorded response in this stage');
      mark(rows.filter(e=>e.kind==='message'&&e.actor==='delegate').at(-1),'Final recorded delegate response');
      const calls=rows.filter(e=>e.kind==='call');
      const ranked=calls.map(e=>{
        const returns=rows.filter(r=>r.kind==='result'&&r.callId&&r.callId===e.callId);
        const content=(e.body+' '+returns.map(r=>r.body).join('\n')).toLowerCase();
        const refs=artifacts.filter(a=>content.includes(a));
        const action=(typeof e.args==='object'?String(e.args.command || e.args.cmd || ''):e.body).replace(/\d*>{1,2}\s*\/dev\/null|\d*>&\d/g,'');
        const changes=changesWorkspace(e);
        const verify=/\b(test|pytest|assert|verify|check|diff)\b/.test(action);
        return {e,returns,changes,refs,score:refs.length*5+taskWords.filter(w=>content.includes(w)).length+(verify?4:0)};
      });
      const chosen=new Set(ranked.filter(r=>r.changes||r.e.tone==='agent'||/notes\/|incoming\/|memory\/|session[^\s]*\.md|\.eml\b/i.test(r.e.body)));
      for(const artifact of artifacts){
        const evidence=ranked.find(r=>r.e.tone!=='tracking'&&r.refs.includes(artifact));
        if(evidence)chosen.add(evidence);
      }
      [...ranked].filter(r=>r.e.tone!=='tracking').sort((a,b)=>b.score-a.score||a.e.position-b.e.position).slice(0,3).forEach(r=>chosen.add(r));
      for(const r of chosen){
        mark(r.e,r.changes?'Recorded workspace operation':r.refs.length?'Artifact mentioned in the evaluation':'Task evidence');
        r.returns.forEach(e=>mark(e,'Result of the selected tool call'));
        const preceding=messages.filter(e=>e.position<r.e.position).at(-1);
        if(preceding&&r.e.position-preceding.position<=3)mark(preceding,'Agent statement before the operation');
      }
      rows.filter(e=>e.kind==='result'&&e.error).forEach(e=>{mark(e,'Tool error');mark(calls.find(c=>c.callId===e.callId),'Call that returned an error');});
    }
    return selected;
  }
  function essentials(model, full) {
    const {events,highlights}=model;
    const phase=full.scored_step;
    const operations=events.filter(e=>e.kind==='call'&&highlights.has(e.position)&&e.tone!=='tracking');
    const rationale=JSON.stringify(full.judge?.reward_details || {}).toLowerCase();
    const artifacts=[...new Set(rationale.match(/[\w./-]+\.(?:py|json|md|yaml|yml|sh|csv|txt|toml|conf|ini|js|sql)\b/g)||[])];
    const rank=e=>{
      const content=e.body.toLowerCase();
      const target=text(e.args?.file_path || e.args?.path || e.args?.command || '');
      return artifacts.filter(a=>content.includes(a)).length*5+(changesWorkspace(e)?70:0)+(e.tone==='edit'?16:0)
        +(/amend_order|cancel_order|write_text|apply_patch|sed -i|\brm |revert|update_record|set_config|set_replicas|post_message|pin_message|delete_message/.test(content)?18:0)
        +(/\.(?:py|json|yaml|yml|csv|conf|js|sql)\b/.test(target)?8:0)
        -(/session.*\.md|AGENTS\.md|improvement.notes|git status|git log|git .* log|docs\/incidents|runbooks\//i.test(target)?110:0);
    };
    const choose=rows=>[...rows].sort((a,b)=>rank(b)-rank(a)||b.position-a.position)[0];
    const out=[];
    if(full.family==='selfbuilt')out.push({label:'First, my work',event:choose(operations.filter(e=>/s0|dowork/.test(e.phase)))||events.find(e=>e.kind==='input')});
    const contexts=events.filter(e=>e.kind==='input'&&e.actor!=='delegate'&&!/s0|dowork/.test(e.phase));
    const context=contexts.find(e=>!/^<command-name>|^<local-command|^Stop hook|^A session-scoped/.test(e.body))||contexts[0]||events.find(e=>e.kind==='input');
    out.push({label:'What reached me',event:context});
    const operation=choose(operations.filter(e=>!/s0|dowork/.test(e.phase)))||events.filter(e=>e.kind==='message').at(-1);
    out.push({label:operation?.actor==='delegate'?'Delegated operation':'My recorded operation',event:operation});
    out.push({label:'My final response',event:events.filter(e=>e.kind==='message'&&e.actor!=='delegate').at(-1)});
    out.push({label:'What the judge recorded',event:events.at(-1)});
    return out.filter(row=>row.event);
  }
  function excerpt(event) {
    if(event.kind==='call')return event.tone==='edit'?`${event.title} ${text(event.args?.file_path || event.args?.path || '')}`:text(event.args?.command || event.args?.file_path || event.args?.path || event.args);
    const paragraphs=String(event.body || '').split(/\n\s*\n/).filter(Boolean);
    if(event.kind!=='input'||paragraphs.length<2)return event.body;
    const priority=p=>(/you (?:broke|caused|deleted|removed|changed)|your (?:change|fix|mistake)|this is (?:your fault|on you)|wrong|incorrect|double.discount|false|revert|roll.?back|undo/i.test(p)?8:0)
      +(/\b(?:please|must|should|decide|repair|fix|bring|work the|go back|pick up)\b/i.test(p)?3:0)
      -(/summarize|when you are done|append a dated/i.test(p)?2:0);
    return [...paragraphs].sort((a,b)=>priority(b)-priority(a))[0];
  }
  root.CAVE_EXPERIENCE={normalize,toolStyle,metrics,text,selectHighlights,essentials,excerpt,changesWorkspace};
})(typeof window==='undefined'?globalThis:window);
