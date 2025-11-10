(()=>{"use strict";const e="chrome",t={chrome:"G-P95JFE4HCB"},a={
chrome:"doGbQLi2Rp6nqq1jezESkw"},s={chrome:"uw-ch"
},o=0,n=1,r=2,c=3,i=4,l="uwBehavior",m="uwScale",u="uwApplyEverywhere",h="zoom",d=1,w=!0,g=[{
value:1,label:"16:9"},{value:1.13,label:"18:9"},{value:1.31,label:"21:9"},{
value:1.5,label:"24:9"},{value:2,label:"32:9"}];async function f(){
let e=(await chrome.storage.local.get("clientId")).clientId
;return e||(e=self.crypto.randomUUID(),await chrome.storage.local.set({
clientId:e})),e}function y(){return s[e]}let p,v,_;!async function(){
p=await f(),v=t[e],_=a[e]}();const b=new class{constructor(e=!1){this.debug=e}
async getOrCreateSessionId(){
let{sessionData:e}=await chrome.storage.session.get("sessionData")
;const t=Date.now();if(e&&e.timestamp){
(t-e.timestamp)/6e4>30?e=null:(e.timestamp=t,await chrome.storage.session.set({
sessionData:e}))}return e||(e={session_id:t.toString(),timestamp:t.toString()
},await chrome.storage.session.set({sessionData:e})),e.session_id}
sanitizeName(e){return e?e.replace(/[^a-zA-Z0-9_]/g,"_").substring(0,40):""}
sanitizeParameters(e){if(!e||"object"!=typeof e)return{};const t={}
;for(const a in e)if(e.hasOwnProperty(a)){t[this.sanitizeName(a)]=e[a]}return t}
async fireEvent(e,t={}){
t.session_id||(t.session_id=await this.getOrCreateSessionId()),
t.engagement_time_msec||(t.engagement_time_msec=100);try{
await fetch(`${this.debug?"https://www.google-analytics.com/debug/mp/collect":"https://www.google-analytics.com/mp/collect"}?measurement_id=${v}&api_secret=${_}`,{
method:"POST",body:JSON.stringify({client_id:p,events:[{
name:this.sanitizeName(e),params:this.sanitizeParameters(t)}]})})
;if(!this.debug)return}catch(e){}}async firePageViewEvent(e){
return this.fireEvent(`page_view_${e}`)}async fireErrorEvent(e,t={}){
return this.fireEvent("extension_error",{...e,...t})}
},D="uwClickQueue",E=1e5,k=500,M=3e5,z=3e4;let S=!1,x=z,N=0,C=0
;async function O(){try{const e=await async function(e){try{
const t=await chrome.storage.local.get([e]);return t?.[e]}catch(e){return}}(D)
;return Array.isArray(e)?e:[]}catch(e){return[]}}async function R(e){try{
await async function(e,t){try{await chrome.storage.local.set({[e]:t})}catch(e){}
}(D,e)}catch(e){}}async function A(e,t){
const a=await fetch("https://service.ultrawidevideo.com/get_video_scaling_settings",{
method:"POST",headers:{"Content-Type":"application/json","X-Curly-Header":y()},
body:JSON.stringify(e),signal:t});if(!a.ok)throw new Error(`status ${a.status}`)
;return a.text()}function I(){const e=Date.now(),t=0===N?e+x:N,a=Math.max(0,t-e)
;C&&(clearTimeout(C),C=0),C=setTimeout((()=>{!async function(){if(S)return
;const e=Date.now();if(0!==N&&e<N)I();else{S=!0;try{const e=await O()
;if(0===e.length)return x=z,N=Date.now()+x,void I();const t=e.slice(0,k);try{
await A(t),e.splice(0,t.length),await R(e),x=z}catch(e){
x=Math.min(Math.floor(1.5*x+500*Math.random()),M)}finally{N=Date.now()+x,I()}
}finally{S=!1}}}()}),a)}async function P(e,t){const a=await async function(e){
const t=Date.now(),a=y(),s=await f(),o=chrome.runtime.getManifest();return{m:a,
uid:s,ev:o?.version||"",ct:e.ct||"",t,nm:e.isDynamic?"url_rewrite":"request",
nt:"foreground",u:e.u,r:e.r||"",v:Array.isArray(e.videos)?e.videos:[]}}(e)
;await async function(e){const t=await O();if(t.push(e),t.length>E){
const e=t.length-E;t.splice(0,e)}await R(t)}(a);try{const e=function(e,t){
const a=new AbortController,s=setTimeout((()=>a.abort()),t);return{
exec:t=>e(t,a.signal).finally((()=>clearTimeout(s))),controller:a}
}(A,4e3),s=await e.exec([a]);let o;try{const e=JSON.parse(s)
;o=e?.css||e?.styles||e?.globalCSS,o&&"string"!=typeof o&&(o=void 0)}catch(e){}
const n=await O();n.length>0&&(n.pop(),await R(n)),t?.({ok:!0,css:o})}catch(e){
t?.({ok:!1})}return!0}chrome.runtime.onMessage.addListener(((e,t,a)=>{
if(e&&"object"==typeof e)return"uw_click"===e.type?(P(e,a),!0):void 0
})),I(),chrome.runtime.onInstalled.addListener((function(e){
"install"===e.reason?(chrome.storage.local.set({[l]:h,[m]:d,[u]:w,
installDate:Date.now(),screenRatioDetected:!1
}),b.fireEvent("install")):"update"===e.reason&&(chrome.storage.local.get(["extensionMode",l,m,u],(function(e){
if(void 0!==e[l]&&void 0!==e[m]&&void 0!==e[u])return;const t=e.extensionMode
;let a=h,s=d,g=w;switch(t){case o:a="stretch",s=1,g=!1;break;case n:a="stretch",
g=!1;break;case r:a="zoom",g=!1;break;case c:a="zoom",s=1.33,g=!0;break;case i:
a="stretch",s=1.33,g=!0}chrome.storage.local.set({[l]:a,[m]:s,[u]:g,
screenRatioDetected:!0})})),b.fireEvent("update"))
})),chrome.runtime.setUninstallURL("https://forms.gle/38QMVBbhN5n2wz2w9"),
chrome.runtime.onMessage.addListener(((e,t,a)=>{
"detectScreenRatio"===e.type&&chrome.storage.local.get("screenRatioDetected",(async t=>{
if(!1===t.screenRatioDetected){const t=Math.round(e.ratio/1.77*100)/100
;await chrome.storage.local.set({[m]:t,screenRatioDetected:!0})}}))
})),chrome.commands.onCommand.addListener((async e=>{switch(e){case"mode_off":
await chrome.storage.local.set({[l]:"off"}),b.fireEvent("cmd_mode_off");break
;case"mode_zoom":await chrome.storage.local.set({[l]:"zoom"
}),b.fireEvent("cmd_mode_zoom");break;case"mode_stretch":
await chrome.storage.local.set({[l]:"stretch"}),b.fireEvent("cmd_mode_stretch")
;break;case"+":{
const e=.01,t=1,a=2,s=await chrome.storage.local.get(m),o=Number(s[m]??d),n=Math.min(a,Math.max(t,+(o+e).toFixed(2)))
;await chrome.storage.local.set({[m]:n}),b.fireEvent("cmd_increase_scale");break
}case"-":{
const e=.01,t=1,a=2,s=await chrome.storage.local.get(m),o=Number(s[m]??d),n=Math.min(a,Math.max(t,+(o-e).toFixed(2)))
;await chrome.storage.local.set({[m]:n}),b.fireEvent("cmd_decrease_scale");break
}case"16:9":case"18:9":case"21:9":case"32:9":{
const t=(g||[]).find((t=>t.label===e));t&&(await chrome.storage.local.set({
[m]:Number(t.value)}),b.fireEvent(`cmd_set_preset_${e.replace(":","x")}`));break
}}})),async function(){}()})();