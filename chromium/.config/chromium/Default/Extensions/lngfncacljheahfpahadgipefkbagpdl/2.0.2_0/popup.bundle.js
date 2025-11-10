(()=>{"use strict";function e(e){const t=e||document
;t.querySelectorAll("[data-e7n]").forEach((e=>{
const t=e.getAttribute("data-e7n");if(!t)return
;const n="undefined"!=typeof chrome&&chrome?.i18n?.getMessage?chrome.i18n.getMessage(t):""
;n&&(e.textContent=n)}));t.querySelectorAll("[data-e7n-html]").forEach((e=>{
const t=e.getAttribute("data-e7n-html");if(!t)return
;const n="undefined"!=typeof chrome&&chrome?.i18n?.getMessage?chrome.i18n.getMessage(t):""
;n&&(e.innerHTML=n)}))}const t="chrome",n={chrome:"G-P95JFE4HCB"},o={
chrome:"doGbQLi2Rp6nqq1jezESkw"
},s="uwBehavior",a="uwScale",c="uwApplyEverywhere",r="zoom",i=1,l=!0,u=[{
value:1,label:"16:9"},{value:1.13,label:"18:9"},{value:1.31,label:"21:9"},{
value:1.5,label:"24:9"},{value:2,label:"32:9"}];let d,m,h;!async function(){
d=await async function(){
let e=(await chrome.storage.local.get("clientId")).clientId
;return e||(e=self.crypto.randomUUID(),await chrome.storage.local.set({
clientId:e})),e}(),m=n[t],h=o[t]}();const f=new class{constructor(e=!1){
this.debug=e}async getOrCreateSessionId(){
let{sessionData:e}=await chrome.storage.session.get("sessionData")
;const t=Date.now();if(e&&e.timestamp){
(t-e.timestamp)/6e4>30?e=null:(e.timestamp=t,await chrome.storage.session.set({
sessionData:e}))}return e||(e={session_id:t.toString(),timestamp:t.toString()
},await chrome.storage.session.set({sessionData:e})),e.session_id}
sanitizeName(e){return e?e.replace(/[^a-zA-Z0-9_]/g,"_").substring(0,40):""}
sanitizeParameters(e){if(!e||"object"!=typeof e)return{};const t={}
;for(const n in e)if(e.hasOwnProperty(n)){t[this.sanitizeName(n)]=e[n]}return t}
async fireEvent(e,t={}){
t.session_id||(t.session_id=await this.getOrCreateSessionId()),
t.engagement_time_msec||(t.engagement_time_msec=100);try{
await fetch(`${this.debug?"https://www.google-analytics.com/debug/mp/collect":"https://www.google-analytics.com/mp/collect"}?measurement_id=${m}&api_secret=${h}`,{
method:"POST",body:JSON.stringify({client_id:d,events:[{
name:this.sanitizeName(e),params:this.sanitizeParameters(t)}]})})
;if(!this.debug)return}catch(e){}}async firePageViewEvent(e){
return this.fireEvent(`page_view_${e}`)}async fireErrorEvent(e,t={}){
return this.fireEvent("extension_error",{...e,...t})}}
;window.onload=async function(){e(),function(){
const e=document.getElementById("uwBehaviorOff"),t=document.getElementById("uwBehaviorZoom"),n=document.getElementById("uwBehaviorStretch"),o=document.getElementById("uwScale"),d=document.getElementById("uwScaleValue"),m=document.getElementById("uwApplyEverywhere"),h=document.querySelectorAll(".presets button"),g=(u||[]).map((e=>Number(e.value))),p=.015,y=document.getElementById("uwTicks"),E=document.getElementById("customControls")
;function v(){
const e=parseFloat(o.min),t=parseFloat(o.max),n=(parseFloat(o.value)-e)/(t-e)*100
;o.style.setProperty("--p",n+"%")}function w(e,t=!0){const n=Number(e)
;o.value=n.toFixed(2),
d.textContent=n.toFixed(2)+"×",v(),chrome.storage.local.set({[a]:n
},(function(){})),t&&f.fireEvent("set_scale")}function b(e){
if(!g.length)return e;let t=g[0],n=Math.abs(e-t);for(let o=1;o<g.length;o++){
const s=Math.abs(e-g[o]);s<n&&(n=s,t=g[o])}return n<=p?t:e}function _(o){
const a="off"===o?"off":"zoom"===o?"zoom":"stretch"
;e.checked="off"===a,t.checked="zoom"===a,
n.checked="stretch"===a,chrome.storage.local.set({[s]:a
},(function(){})),f.fireEvent(`set_behavior_${a}`),k(a)}function k(e){
const t="off"===e
;E.querySelectorAll(".slider-row, .presets, .apply-toggle").forEach((e=>{
e.style.display=t?"none":""}))}function L(e){
m.checked=!e,chrome.storage.local.set({[c]:!!e
},(function(){})),f.fireEvent("set_apply_"+(e?"everywhere":"fullscreen"))}
function S(){if(!y)return;const e=parseFloat(o.min),t=parseFloat(o.max)
;y.innerHTML="",(u||[]).forEach((n=>{
const o=(n.value-e)/(t-e)*100,s=document.createElement("div")
;s.className="tick",s.style.left=`calc(${o}% - 1px)`,y.appendChild(s)
;const a=document.createElement("div")
;a.className="tick-label",a.style.left=o+"%",
a.textContent=n.label,y.appendChild(a)}))}
chrome.storage.local.get([s,a,c],(function(e){
const t=e[s]||r,n=Number(e[a]||i),o="boolean"==typeof e[c]?e[c]:l
;_(t),w(n,!1),L(o),S()})),e?.addEventListener("change",(function(){
this.checked&&_("off")})),t?.addEventListener("change",(function(){
this.checked&&_("zoom")})),n?.addEventListener("change",(function(){
this.checked&&_("stretch")})),o?.addEventListener("input",(function(){
w(b(Number(this.value)))})),m?.addEventListener("change",(function(){
L(!this.checked)})),h.forEach((e=>e.addEventListener("click",(function(){
w(Number(this.getAttribute("data-scale")))
})))),chrome.storage.onChanged.addListener((function(r,i){if("local"===i){
if(r[s]){const o=r[s].newValue
;e.checked="off"===o,t.checked="zoom"===o,n.checked="stretch"===o,k(o)}if(r[a]){
const e=Number(r[a].newValue)
;o.value=e.toFixed(2),d.textContent=e.toFixed(2)+"×",v()}
r[c]&&(m.checked=!r[c].newValue)}}))}(),function(){
const e=document.getElementById("shortcutsToggle"),t=document.getElementById("shortcutsPanel"),n=document.getElementById("shortcutsList"),o=document.getElementById("openShortcutsSettings")
;if(!(e&&t&&n&&o))return;let s=!1;function a(n){
n?(t.classList.add("is-open"),t.setAttribute("aria-hidden","false"),
e.setAttribute("aria-expanded","true"),
s||(c(),s=!0)):(t.classList.remove("is-open"),
t.setAttribute("aria-hidden","true"),e.setAttribute("aria-expanded","false"))}
function c(){chrome?.commands?.getAll&&chrome.commands.getAll((function(e){
n.innerHTML="",(e||[]).reverse().forEach((e=>{
if("_execute_action"===e.name)return
;const t=chrome?.i18n?.getMessage&&chrome.i18n.getMessage("CommandLabel")||"Command",o=chrome?.i18n?.getMessage&&chrome.i18n.getMessage("ShortcutNotSet")||"Not set",s=e.description||e.name||t,a=e.shortcut||o,c=document.createElement("li"),r=document.createElement("span")
;r.className="shortcut-command",r.textContent=s
;const i=document.createElement("span")
;i.className="shortcut-keys",i.textContent=a,
c.appendChild(r),c.appendChild(i),n.appendChild(c)}))}))}
e.addEventListener("click",(function(){a(!t.classList.contains("is-open"))
})),o.addEventListener("click",(function(){chrome.tabs.create({
url:"chrome://extensions/shortcuts"})}))}()
;const t=document.querySelectorAll("a")
;for(let e=0,n=t.length;e<n;e++)"A"==t[e].tagName&&(t[e].onclick=function(){
chrome.tabs.create({url:this.href})});!function(){
const e=document.getElementById("rateUs"),t=document.getElementById("reviewUs"),n=document.getElementById("improveUs"),o=document.querySelectorAll(".star")
;chrome.storage.local.get(["userRating"],(function(t){
t.userRating||(e.style.display="flex",o.forEach(((e,n)=>{
n<t.userRating&&e.classList.add("selected")
})),f.fireEvent("show_rate_us_prompt"))})),o.forEach((s=>{
s.addEventListener("click",(async function(){
const s=parseInt(this.getAttribute("data-value"),10)
;o.forEach((e=>e.classList.remove("selected")))
;for(let e=0;e<s;e++)o[e].classList.add("selected")
;if(f.fireEvent(`rate_${s}_stars`),s>=4){
const o=document.querySelector("#reviewUs a"),s=o&&o.getAttribute("href")?o.getAttribute("href"):"https://chromewebstore.google.com/detail/lngfncacljheahfpahadgipefkbagpdl/reviews"
;chrome.tabs.create({url:s
}),f.fireEvent("open_cws"),e&&(e.style.display="none"),
t&&(t.style.display="none"),n&&(n.style.display="none")
}else t.style.display="none",n.style.display="block"
;await chrome.storage.local.set({userRating:s})}))
})),document.querySelector("#reviewUs a")?.addEventListener("click",(async function(){
await chrome.storage.local.set({userRating:5}),f.fireEvent("open_cws")}))
}(),f.firePageViewEvent("popup")}})();