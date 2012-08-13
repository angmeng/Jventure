/*=======Ver: 6.3.51115========*/
function stisL(h,t,c,w){	var t=stgtW(t,w);var u=t?t.location.href:"";if(!c){u=u.toLowerCase();h=h.toLowerCase();}return 	u&&h&&(u==h||u==h+"/"||u==h+"#"||STM_ILINK&&u==h.substr(0,Math.max(0,h.indexOf("?")))||STM_ILOC&&h==u.substr(0,Math.max(0,u.indexOf("?"))));}
function stshlp(p){var m=st_ms[p.mid];if(m.lits&0x08000000){for(var j=0;j<m.lnks.length;j++){var i=m.lnks[j].dat,pp=[],sn=0;if(i.ishl){do{pp.push(i.parP);i=i.parP.parI;}while(i)}if(m.lits&0x10000000)sn=Math.max(pp.length-m.litl,0);for(var q=pp.length-1;q>=sn;q--){if(pp[q].parI) pp[q].parI.parP.cIt=pp[q].parI;if(!pp[q].isSh)stshP(pp[q]);}}}}
function stgtW(t,w){if(t=="_self")return w;else if(t=="_parent")return w.parent;else if(t=="_top")return w.top;else return parent.frames[t];return 0;}
