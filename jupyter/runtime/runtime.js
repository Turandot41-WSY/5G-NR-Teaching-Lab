/* Same-origin Jupyter execution for the trusted local course. */
(async () => {
  'use strict';
  const main=document.querySelector('main.content');
  if(!main) return;
  const lab=document.querySelector('meta[name="uni-lab"]').content;
  const response=await fetch('/course-runtime/cells?lab='+encodeURIComponent(lab));
  if(!response.ok) throw new Error('Cannot load experiment cells: HTTP '+response.status);
  const config=await response.json();
  const {cells,kernel,name,variable}=config;
  let kernelId=null, socket=null, pending=null, running=false, interrupted=false;
  const states=cells.map(()=>({done:false,outputs:[],execution_count:null,code:null}));
  const panels=[];
  const esc=s=>s.replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
  function highlight(text) {
    return text.split('\n').map(line=>{
      const re=/%.*$|'(?:[^']|'')*'|\b(?:assert|disp|fprintf|figure|if|else|end|while|for|try|catch|function|true|false)\b|\b\d+(?:\.\d+)?(?:e[+-]?\d+)?\b/g;
      let result='',start=0;
      for(const m of line.matchAll(re)) {
        result+=esc(line.slice(start,m.index)); const t=m[0];
        const cls=t[0]==='%'?'comment':t[0]==="'"?'str':/^\d/.test(t)?'num':'kw';
        result+='<span class="'+cls+'">'+esc(t)+'</span>'; start=m.index+t.length;
      }
      return result+esc(line.slice(start));
    }).join('\n')+'\n';
  }
  const toolbar=document.createElement('div'); toolbar.className='uni-runtime-toolbar';
  toolbar.innerHTML='<strong>'+esc(name.toUpperCase())+' · LOCAL MATLAB</strong><p>Code runs on this computer with its MATLAB licence. Run cells in order and use one active experiment at a time; this server shares a MATLAB workspace. Edited inputs make later results stale. Reference figures elsewhere in the note remain the saved teaching evidence.</p><div class="uni-runtime-actions"><button id="uni-connect">Connect MATLAB</button><button id="uni-interrupt" disabled>Interrupt</button><button id="uni-reset" disabled>Reset experiment</button><button id="uni-download">Download notebook</button><span id="uni-session-status" role="status">Not connected</span></div>';
  (main.querySelector('#title-block-header')||main.firstElementChild).after(toolbar);
  const status=toolbar.querySelector('#uni-session-status');
  function refreshButtons() {
    document.querySelector('#uni-connect').disabled=running||!!socket;
    document.querySelector('#uni-interrupt').disabled=!running;
    document.querySelector('#uni-reset').disabled=running||!socket;
    document.querySelector('#uni-download').disabled=running;
    panels.forEach((p,i)=>{
      p.run.disabled=running||!socket||states.slice(0,i).some(s=>!s.done);
      p.input.readOnly=running;
    });
  }
  function invalidate(index) {
    states.forEach((s,i)=>{if(i>=index){s.done=false; if(panels[i]){panels[i].output.dataset.stale='true';panels[i].state.textContent=s.outputs.length?'Stale — run again':'Not run';}}});
    refreshButtons();
  }
  cells.forEach((cell,index)=>{
    const anchor=document.getElementById(cell.anchor);
    if(!anchor) throw new Error('Missing source section: '+cell.anchor);
    const heading=anchor.matches('section')?anchor.querySelector('h2,h3'):anchor;
    const panel=document.createElement('div'); panel.className='uni-runtime-cell'; panel.id='run-'+cell.id;
    panel.innerHTML='<div class="hm-code-label"><span>MATLAB CODE</span></div><h4>'+esc(cell.title)+'</h4><p>'+esc(cell.description)+'</p><div class="uni-editor"><pre aria-hidden="true"></pre><textarea spellcheck="false" aria-label="'+esc(cell.title)+' MATLAB code"></textarea></div><div class="uni-runtime-actions"><button disabled>Run cell '+(index+1)+'</button><span class="uni-runtime-state" role="status">Not run</span></div><div class="uni-runtime-output" aria-live="polite"></div>';
    const previous=[...heading.parentElement.querySelectorAll(':scope > .uni-runtime-cell')].filter(p=>p.dataset.anchor===cell.anchor).at(-1);
    (previous||heading).after(panel); panel.dataset.anchor=cell.anchor;
    const p={panel,input:panel.querySelector('textarea'),pre:panel.querySelector('pre'),run:panel.querySelector('button'),state:panel.querySelector('.uni-runtime-state'),output:panel.querySelector('.uni-runtime-output')};
    p.input.value=cell.code; p.pre.innerHTML=highlight(cell.code);
    p.input.addEventListener('input',()=>{p.pre.innerHTML=highlight(p.input.value);invalidate(index);});
    p.run.addEventListener('click',()=>run(index)); panels.push(p);
  });
  function xsrf() { const m=document.cookie.match(/(?:^|; )_xsrf=([^;]+)/); return m?decodeURIComponent(m[1]):''; }
  async function api(path,method='GET',data) {
    const response=await fetch(path,{method,headers:{'Content-Type':'application/json','X-XSRFToken':xsrf()},body:data?JSON.stringify(data):undefined});
    if(!response.ok) throw new Error('Jupyter HTTP '+response.status+': '+(await response.text()).slice(0,200));
    return response.status===204?null:response.json();
  }
  function send(code,onMessage) {
    if(pending) return Promise.reject(new Error('Wait for the current cell.'));
    return new Promise((resolve,reject)=>{
      const id=crypto.randomUUID();
      pending={id,resolve,reject,onMessage,error:null};
      socket.send(JSON.stringify({header:{msg_id:id,username:'student',session:kernelId,date:new Date().toISOString(),msg_type:'execute_request',version:'5.3'},parent_header:{},metadata:{},channel:'shell',content:{code,silent:false,store_history:true,user_expressions:{},allow_stdin:false,stop_on_error:true}}));
    });
  }
  function onMessage(event) {
    const m=JSON.parse(event.data);
    if(!pending||m.parent_header?.msg_id!==pending.id) return;
    const type=m.header.msg_type;
    if(type==='error'||(type==='execute_reply'&&m.content.status==='error')) pending.error=m.content.evalue||'MATLAB execution failed';
    // jupyter-matlab-proxy 0.19.1 can report MATLAB failures on stderr while
    // returning execute_reply status=ok. Do not unlock dependent cells.
    if(type==='stream'&&m.content.name==='stderr') pending.error=m.content.text||'MATLAB reported an error';
    pending.onMessage?.(m);
    if(type==='status'&&m.content.execution_state==='idle') {
      const p=pending; pending=null;
      p.error?p.reject(new Error(p.error)):p.resolve();
    }
  }
  function renderOutput(index,m) {
    const p=panels[index],s=states[index],c=m.content,type=m.header.msg_type;
    if(type==='clear_output') { p.output.replaceChildren(); s.outputs=[]; return; }
    if(type==='execute_input'||type==='execute_reply') {s.execution_count=c.execution_count??s.execution_count; return;}
    let output;
    if(type==='stream') output={output_type:'stream',name:c.name,text:c.text};
    else if(type==='error') output={output_type:'error',ename:c.ename,evalue:c.evalue,traceback:c.traceback||[]};
    else if(type==='execute_result'||type==='display_data') output={output_type:type,data:c.data,metadata:c.metadata||{},...(type==='execute_result'?{execution_count:c.execution_count}: {})};
    if(!output) return;
    s.outputs.push(output);
    if(c.data?.['image/png']) {
      const fig=document.createElement('figure'),img=document.createElement('img'),caption=document.createElement('figcaption');
      img.src='data:image/png;base64,'+c.data['image/png']; img.alt=cells[index].title+' — current MATLAB output';
      caption.textContent='Current MATLAB run · cell '+(index+1)+' · '+new Date().toLocaleTimeString();
      fig.append(img,caption);p.output.append(fig);
    } else {
      const last=p.output.lastElementChild;
      if(type==='stream' && last?.dataset.stream===c.name) {last.textContent+=c.text;return;}
      const pre=document.createElement('pre');
      if(type==='stream')pre.dataset.stream=c.name;
      const htmlText=c.data?.['text/html']?new DOMParser().parseFromString(c.data['text/html'],'text/html').body.textContent:'';
      pre.textContent=c.text||c.evalue||c.data?.['text/plain']||htmlText;
      p.output.append(pre);
    }
  }
  async function run(index) {
    if(running||!socket||states.slice(0,index).some(s=>!s.done)) return;
    invalidate(index); running=true;interrupted=false;refreshButtons();
    const p=panels[index],s=states[index];p.output.replaceChildren();s.outputs=[];s.code=p.input.value;
    p.output.dataset.stale='false';p.state.dataset.state='running';p.state.textContent='Running in local MATLAB…';status.textContent='Running cell '+(index+1);
    try {
      await send(s.code,m=>renderOutput(index,m));
      if(interrupted) throw new Error('Interrupt requested — this result is not accepted. Rerun the cell.');
      // The official kernel may return a startup failure as stream output.
      const text=s.outputs.filter(o=>o.output_type==='stream').map(o=>o.text).join('');
      if(/Error: MATLAB Kernel|Failed to start MATLAB/.test(text)) throw new Error(text);
      s.done=true;p.state.dataset.state='done';p.state.textContent='Completed · execution '+s.execution_count;status.textContent='MATLAB ready';
    } catch(e) {p.state.dataset.state='error';p.state.textContent=e.message;status.textContent='Check cell '+(index+1);}
    finally {running=false;refreshButtons();}
  }
  document.querySelector('#uni-connect').onclick=async()=>{
    status.textContent='Connecting to the local MATLAB kernel…';running=true;refreshButtons();
    try {
      const session=await api('/api/sessions','POST',{path:'jupyter/notebooks/'+name+'.ipynb',name,type:'notebook',kernel:{name:kernel}});
      kernelId=session.kernel.id;
      socket=new WebSocket(location.origin.replace(/^http/,'ws')+'/api/kernels/'+kernelId+'/channels');
      await new Promise((resolve,reject)=>{socket.onopen=resolve;socket.onerror=()=>reject(new Error('Jupyter socket connection failed'));});
      socket.onmessage=onMessage;
      socket.onclose=()=>{socket=null;if(pending){pending.reject(new Error('Connection closed; reconnect and initialize.'));pending=null;}running=false;invalidate(0);status.textContent='Disconnected';refreshButtons();};
      status.textContent='Connected · run cell 1 to initialize MATLAB';
    } catch(e) {status.textContent=e.message;socket=null;}
    finally {running=false;refreshButtons();}
  };
  document.querySelector('#uni-interrupt').onclick=async()=>{
    interrupted=true;status.textContent='Interrupt requested…';
    const target=pending;
    try {
      // A click can precede dispatch from the Python kernel to MATLAB. Retry
      // only while this exact execution is pending; never interrupt a new cell.
      for(let attempt=0;attempt<5&&target&&pending===target;attempt++) {
        await api('/api/kernels/'+kernelId+'/interrupt','POST');
        await new Promise(resolve=>setTimeout(resolve,750));
      }
    } catch(e){status.textContent=e.message;}
  };
  document.querySelector('#uni-reset').onclick=async()=>{
    if(!confirm('Clear the '+name+' experiment variables? Saved files and downloaded notebooks remain available.'))return;
    running=true;refreshButtons();
    try {await send('clear '+variable+';');invalidate(0);status.textContent='Experiment reset · run cell 1';}
    catch(e){status.textContent=e.message;}
    finally {running=false;refreshButtons();}
  };
  document.querySelector('#uni-download').onclick=async()=>{
    // Download the source snapshot loaded by this page, even if Obsidian was
    // edited meanwhile. Reload the page explicitly to load revised cells.
    const nb=structuredClone(config.notebook);
    nb.metadata.uni.source_sha256=config.source_sha256;
    nb.cells.filter(c=>c.cell_type==='code').forEach((c,i)=>{
      c.source=panels[i].input.value;
      c.execution_count=states[i].done?states[i].execution_count:null;
      c.outputs=states[i].done?states[i].outputs:[];
      c.metadata.uni={lab,stale:!states[i].done,executed_source:states[i].code};
    });
    const blob=new Blob([JSON.stringify(nb,null,2)],{type:'application/x-ipynb+json'}),a=document.createElement('a');
    a.href=URL.createObjectURL(blob);a.download=name+'-student.ipynb';a.click();setTimeout(()=>URL.revokeObjectURL(a.href),1000);
  };
  refreshButtons();
})().catch(e=>{const p=document.createElement('p');p.textContent='Uni runtime: '+e.message;document.querySelector('main.content')?.prepend(p);});
