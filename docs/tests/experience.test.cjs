const assert=require('node:assert/strict');
const fs=require('node:fs');
const path=require('node:path');
require('../js/experience.js');
const X=globalThis.CAVE_EXPERIENCE;
const base=path.join(__dirname,'..');
const index=JSON.parse(fs.readFileSync(path.join(base,'data/index.json')));
const coverage={cases:0,stages:0,calls:0,returns:0,sharedHistorySteps:0,unrecordedEvents:0,highlightEvents:0};
for(const meta of index.cases){
  const [model,id]=meta.id.split('/');const full=JSON.parse(fs.readFileSync(path.join(base,'cases',model,'tasks',id+'.json')));
  const strings=value=>typeof value==='string'?[value]:value&&typeof value==='object'?Object.values(value).flatMap(strings):[];
  const contents=strings(full).join('\n');
  assert(!contents.includes('/Users/'),meta.id+': personal home path');
  const emails=contents.match(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/gi)||[];
  assert(emails.every(email=>/^anon-[0-9a-f]{12}@example\.invalid$/.test(email)),meta.id+': unredacted email');
  const {events,chapters,highlights}=X.normalize(full);
  assert(events.length>0,meta.id);
  assert.equal(events.at(-1).kind,'judge');
  assert.deepEqual(events.at(-1).evaluation,full.judge);
  for(const chapter of chapters){
    assert(highlights.has(chapter.start),meta.id+': missing chapter');
    assert.equal(chapter.status,'restored',meta.id+': missing raw evidence');
    coverage.sharedHistorySteps+=chapter.reused;
    const messages=events.filter(e=>e.phase===chapter.id&&e.kind==='message');
    if(messages.length)assert(highlights.has(messages.at(-1).position),meta.id+': final response omitted');
  }
  if(meta.family==='selfbuilt')assert.match(chapters[0].id,/s0|dowork/);
  for(const e of events){
    if(e.kind==='input'||e.kind==='judge')assert(highlights.has(e.position),meta.id+': omitted context/evaluation');
    if(e.kind==='call'){
      const returns=events.filter(r=>r.kind==='result'&&r.phase===e.phase&&r.callId===e.callId);
      assert(returns.length>0,meta.id+': unmatched tool call');
      if(highlights.has(e.position))for(const r of returns)assert(highlights.has(r.position),meta.id+': highlight omitted return');
      coverage.calls++;
    }
    if(e.kind==='result'){
      coverage.returns++;
      if(e.error)assert(highlights.has(e.position),meta.id+': omitted reported tool error');
    }
    if(e.kind==='gap')coverage.unrecordedEvents++;
  }
  for(const item of X.essentials({events,highlights},full)){
    assert(events.includes(item.event),meta.id+': ungrounded essential');
    if(item.event.kind==='input')assert(item.event.body.includes(X.excerpt(item.event)),meta.id+': invented excerpt');
  }
  coverage.cases++;coverage.stages+=chapters.length;coverage.highlightEvents+=highlights.size;
}
const s={step_id:1,source:'user',message:'Build the correct state',timestamp:'one'};
const next={step_id:2,source:'user',message:'Now reconsider',timestamp:'two'};
const full={family:'selfbuilt',scored_step:'s1_gaslight',trajectory:{s0_dowork:{steps:[s]},s1_gaslight:{steps:[s,next]}},judge:{reward:{c1_downstream:0}}};
assert.equal(X.normalize(full).events.filter(e=>e.kind==='input').length,2);
full.trajectory.s1_gaslight.steps=[{...s,message:'A different initial state'},next];
assert.equal(X.normalize(full).events.filter(e=>e.kind==='input').length,3);
assert.equal(X.toolStyle('Write',{}).icon,'file-plus-2');
assert.equal(X.toolStyle('TaskUpdate',{}).tone,'tracking');
assert.notEqual(X.toolStyle('Read',{}).icon,X.toolStyle('Edit',{}).icon);
assert.notEqual(X.toolStyle('Bash',{command:'rg pattern file'}).icon,X.toolStyle('Bash',{command:'python script.py'}).icon);
const resultError=result=>X.normalize({trajectory:{steps:[{step_id:1,observation:{results:[result]}}]}}).events.find(e=>e.kind==='result').error;
assert.equal(resultError({content:'Exit code 1\nNo module named pytest\n\n[error] tool reported failure'}),true);
assert.equal(resultError({content:'An error message in a source file'}),false);
assert.equal(resultError({content:'Example: [error] tool reported failure'}),false);
assert.equal(resultError({content:'[error] tool reported failure\nMore file contents'}),false);
assert.equal(resultError({content:'[error] tool reported failure',is_error:false}),false);
assert.equal(resultError({content:'',is_error:true}),true);
console.log(JSON.stringify(coverage,null,2));
