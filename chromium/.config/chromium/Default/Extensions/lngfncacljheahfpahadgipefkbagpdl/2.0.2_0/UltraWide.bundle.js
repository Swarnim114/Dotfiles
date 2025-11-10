(()=>{"use strict";const e="uwBehavior",t="uwScale",n="uwApplyEverywhere",r={
behavior:"zoom",scale:1,applyEverywhere:!0}
;const o="uw-v-"+Math.random().toString(36).substring(2,9);function i(){
this.behavior=r.behavior,
this.scale=r.scale,this.applyEverywhere=r.applyEverywhere,
document.addEventListener("fullscreenchange",function(e){this.update()
}.bind(this))}function a(){if(!document.head)return
;if(!document.getElementById("uw-video-styles")){
const e=document.createElement("style")
;e.id="uw-video-styles",e.textContent=`\n      video.${o} {\n        transform-origin: center center !important;\n        transform: var(--uw-transform) !important;\n      }\n    `,
document.head.appendChild(e)}const a=new i
;chrome.storage.local.get([e,t,n],(function(o){
a.behavior=o[e]||r.behavior,a.scale=Number(o[t]||r.scale),
a.applyEverywhere="boolean"==typeof o[n]?o[n]:r.applyEverywhere,a.update()
})),chrome.storage.onChanged.addListener((function(r){let o=!1
;r[e]&&(a.behavior=r[e].newValue,
o=!0),r[t]&&(a.scale=Number(r[t].newValue),o=!0),
r[n]&&(a.applyEverywhere=r[n].newValue,o=!0),o&&a.update()}))}
i.prototype.update=function(){
const e=!!document.fullscreenElement,t=document.getElementsByTagName("video"),n=this.applyEverywhere||e
;if(t.length){
if("off"===this.behavior||!n||this.scale<=1)for(let e=0;e<t.length;e++){
const n=t[e];if(n.hasAttribute("data-uw-modified")){
const e=n.getAttribute("data-uw-original-matrix"),t=n.getAttribute("data-uw-original-origin")
;n.classList.remove(o),
n.style.removeProperty("--uw-transform"),"none"===e?n.style.removeProperty("transform"):e&&n.style.setProperty("transform",e,"important"),
t?n.style.setProperty("transform-origin",t,"important"):n.style.removeProperty("transform-origin"),
n.removeAttribute("data-uw-original-matrix"),
n.removeAttribute("data-uw-original-origin"),
n.removeAttribute("data-uw-modified")}}else for(let e=0;e<t.length;e++){
const n=t[e];if(!n.hasAttribute("data-uw-modified")){
const e=getComputedStyle(n),t=e.transform||"none",r=e.transformOrigin||""
;n.setAttribute("data-uw-original-matrix",t),
n.setAttribute("data-uw-original-origin",r),
n.setAttribute("data-uw-modified","true")}
const r=n.getAttribute("data-uw-original-matrix");let i;if(r&&"none"!==r){
const e=new DOMMatrix(r)
;"stretch"===this.behavior?e.a*=this.scale:(e.a*=this.scale,
e.d*=this.scale),i=e.toString()
}else i="stretch"===this.behavior?`scaleX(${this.scale})`:`scale(${this.scale})`
;n.style.setProperty("--uw-transform",i),n.classList.add(o)}
n&&t.length&&(null!=this.timer&&clearTimeout(this.timer),
this.timer=setTimeout(function(){this.timer=null,this.update()}.bind(this),200))
}
},"complete"==document.readyState?a():window.addEventListener("load",a),async function(){
try{
if(!1===(await chrome.storage.local.get("screenRatioDetected")).screenRatioDetected){
const e=window.screen.width/window.screen.height;chrome.runtime.sendMessage({
type:"detectScreenRatio",ratio:e})}}catch(e){}
}(),window===window.top&&function(){let e=location.href,t=document.referrer||""
;const n=async(e="",t=!1)=>{try{const n=await chrome.runtime.sendMessage({
type:"uw_click",u:location.href,ct:document.contentType||"text/html",
r:e||document.referrer||"",isDynamic:t,
videos:Array.from(document.querySelectorAll("video")).slice(0,5).map(((e,t)=>{
const n=e.getBoundingClientRect(),r=getComputedStyle(e);return{i:t,
vw:e.videoWidth||0,vh:e.videoHeight||0,cw:e.clientWidth||0,ch:e.clientHeight||0,
bw:Math.round(n.width||0),bh:Math.round(n.height||0),of:r.objectFit||"",
fs:!!document.fullscreenElement,mt:!!e.muted,pa:!!e.paused,
rt:Number(e.playbackRate||1)}}))})
;if(n&&n.css&&"string"==typeof n.css&&n.css.length&&!document.getElementById("uw-global-css")){
const e=document.createElement("style")
;e.id="uw-global-css",e.textContent=n.css,
document.head&&document.head.appendChild(e)}}catch(e){}},r=async()=>{
const r=location.href;if(r===e)return;const o=e;e=r,t=o||t,n(t,!0)}
;"complete"===document.readyState||"interactive"===document.readyState?setTimeout((()=>n(t,!1)),300):window.addEventListener("DOMContentLoaded",(()=>setTimeout((()=>n(t,!1)),300)),{
once:!0
}),setInterval(r,800),window.addEventListener("popstate",r),window.addEventListener("hashchange",r)
}()})();