const fs=require('node:fs');
const path=require('node:path');
const crypto=require('node:crypto');
const root=path.join(__dirname,'..','cases');
const counts={files:0,emails:0,homePaths:0};
function sanitize(value){
  if(typeof value==='string')return value
    .replace(/\/Users\/[^\s/"'\\<>`]+/g,()=>{counts.homePaths++;return '/redacted-home';})
    .replace(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/gi,email=>{
      if(/^anon-[0-9a-f]{12}@example\.invalid$/.test(email))return email;
      counts.emails++;
      return 'anon-'+crypto.createHash('sha256').update(email.toLowerCase()).digest('hex').slice(0,12)+'@example.invalid';
    });
  if(Array.isArray(value))return value.map(sanitize);
  if(value&&typeof value==='object')return Object.fromEntries(Object.entries(value).map(([k,v])=>[k,sanitize(v)]));
  return value;
}
function walk(dir){for(const entry of fs.readdirSync(dir,{withFileTypes:true})){const file=path.join(dir,entry.name);if(entry.isDirectory())walk(file);else if(entry.name.endsWith('.json')){const original=JSON.parse(fs.readFileSync(file));const data=sanitize(original);data.privacy={email_addresses:'consistent pseudonyms',home_paths:'redacted'};fs.writeFileSync(file,JSON.stringify(data)+'\n');counts.files++;}}}
walk(root);
const indexFile=path.join(root,'..','data','index.json');
fs.writeFileSync(indexFile,JSON.stringify(sanitize(JSON.parse(fs.readFileSync(indexFile))))+'\n');
console.log(JSON.stringify(counts));
